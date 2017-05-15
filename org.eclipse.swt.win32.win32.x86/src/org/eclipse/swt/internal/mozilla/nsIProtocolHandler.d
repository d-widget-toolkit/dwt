module org.eclipse.swt.internal.mozilla.nsIProtocolHandler;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIURI; 
import org.eclipse.swt.internal.mozilla.nsIChannel;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IPROTOCOLHANDLER_IID_STR = "15fd6940-8ea7-11d3-93ad-00104ba0fd40";

const nsIID NS_IPROTOCOLHANDLER_IID= 
  {0x15fd6940, 0x8ea7, 0x11d3, 
    [ 0x93, 0xad, 0x00, 0x10, 0x4b, 0xa0, 0xfd, 0x40 ]};

interface nsIProtocolHandler : nsISupports {

  static const char[] IID_STR = NS_IPROTOCOLHANDLER_IID_STR;
  static const nsIID IID = NS_IPROTOCOLHANDLER_IID;

extern(System):
  nsresult GetScheme(nsACString * aScheme);
  nsresult GetDefaultPort(PRInt32 *aDefaultPort);
  nsresult GetProtocolFlags(PRUint32 *aProtocolFlags);
  nsresult NewURI(nsACString * aSpec, char *aOriginCharset, nsIURI aBaseURI, nsIURI *_retval);
  nsresult NewChannel(nsIURI aURI, nsIChannel *_retval);
  nsresult AllowPort(PRInt32 port, char *scheme, PRBool *_retval);

  enum { URI_STD = 0U };
  enum { URI_NORELATIVE = 1U };
  enum { URI_NOAUTH = 2U };
  enum { ALLOWS_PROXY = 4U };
  enum { ALLOWS_PROXY_HTTP = 8U };

}

