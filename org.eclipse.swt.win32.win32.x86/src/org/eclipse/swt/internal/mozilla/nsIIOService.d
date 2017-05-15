module org.eclipse.swt.internal.mozilla.nsIIOService;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIProtocolHandler;
import org.eclipse.swt.internal.mozilla.nsIChannel; 
import org.eclipse.swt.internal.mozilla.nsIURI; 
import org.eclipse.swt.internal.mozilla.nsIFile; 
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IIOSERVICE_IID_STR = "bddeda3f-9020-4d12-8c70-984ee9f7935e";

const nsIID NS_IIOSERVICE_IID= 
  {0xbddeda3f, 0x9020, 0x4d12, 
    [ 0x8c, 0x70, 0x98, 0x4e, 0xe9, 0xf7, 0x93, 0x5e ]};

interface nsIIOService : nsISupports {

  static const char[] IID_STR = NS_IIOSERVICE_IID_STR;
  static const nsIID IID = NS_IIOSERVICE_IID;

extern(System):
  nsresult GetProtocolHandler(char *aScheme, nsIProtocolHandler *_retval);
  nsresult GetProtocolFlags(char *aScheme, PRUint32 *_retval);
  nsresult NewURI(nsACString * aSpec, char *aOriginCharset, nsIURI aBaseURI, nsIURI *_retval);
  nsresult NewFileURI(nsIFile aFile, nsIURI *_retval);
  nsresult NewChannelFromURI(nsIURI aURI, nsIChannel *_retval);
  nsresult NewChannel(nsACString * aSpec, char *aOriginCharset, nsIURI aBaseURI, nsIChannel *_retval);
  nsresult GetOffline(PRBool *aOffline);
  nsresult SetOffline(PRBool aOffline);
  nsresult AllowPort(PRInt32 aPort, char *aScheme, PRBool *_retval);
  nsresult ExtractScheme(nsACString * urlString, nsACString * _retval);

}

