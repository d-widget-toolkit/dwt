module org.eclipse.swt.internal.mozilla.nsIDirectoryService;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIFile;

/******************************************************************************

******************************************************************************/

const char[] NS_IDIRECTORYSERVICEPROVIDER_IID_STR = "bbf8cab0-d43a-11d3-8cc2-00609792278c";

const nsIID NS_IDIRECTORYSERVICEPROVIDER_IID= 
  {0xbbf8cab0, 0xd43a, 0x11d3, 
    [ 0x8c, 0xc2, 0x00, 0x60, 0x97, 0x92, 0x27, 0x8c ]};

interface nsIDirectoryServiceProvider : nsISupports {

  static const char[] IID_STR = NS_IDIRECTORYSERVICEPROVIDER_IID_STR;
  static const nsIID IID = NS_IDIRECTORYSERVICEPROVIDER_IID;

extern(System):
  nsresult GetFile(char *prop, PRBool *persistent, nsIFile *_retval);

}

/******************************************************************************

******************************************************************************/

const char[] NS_IDIRECTORYSERVICEPROVIDER2_IID_STR = "2f977d4b-5485-11d4-87e2-0010a4e75ef2";

const nsIID NS_IDIRECTORYSERVICEPROVIDER2_IID= 
  {0x2f977d4b, 0x5485, 0x11d4, 
    [ 0x87, 0xe2, 0x00, 0x10, 0xa4, 0xe7, 0x5e, 0xf2 ]};

interface nsIDirectoryServiceProvider2 : nsIDirectoryServiceProvider {

  static const char[] IID_STR = NS_IDIRECTORYSERVICEPROVIDER2_IID_STR;
  static const nsIID IID = NS_IDIRECTORYSERVICEPROVIDER2_IID;

extern(System):
  nsresult GetFiles(char *prop, nsISimpleEnumerator *_retval);

}

/******************************************************************************

******************************************************************************/

const char[] NS_IDIRECTORYSERVICE_IID_STR = "57a66a60-d43a-11d3-8cc2-00609792278c";

const nsIID NS_IDIRECTORYSERVICE_IID= 
  {0x57a66a60, 0xd43a, 0x11d3, 
    [ 0x8c, 0xc2, 0x00, 0x60, 0x97, 0x92, 0x27, 0x8c ]};

interface nsIDirectoryService : nsISupports {

  static const char[] IID_STR = NS_IDIRECTORYSERVICE_IID_STR;
  static const nsIID IID = NS_IDIRECTORYSERVICE_IID;

extern(System):
  nsresult Init();
  nsresult RegisterProvider(nsIDirectoryServiceProvider prov);
  nsresult UnregisterProvider(nsIDirectoryServiceProvider prov);
}

