module org.eclipse.swt.internal.mozilla.nsIURIContentListener;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIRequest;
import org.eclipse.swt.internal.mozilla.nsIStreamListener;
import org.eclipse.swt.internal.mozilla.nsIURI; 

const char[] NS_IURICONTENTLISTENER_IID_STR = "94928ab3-8b63-11d3-989d-001083010e9b";

const nsIID NS_IURICONTENTLISTENER_IID= 
  {0x94928ab3, 0x8b63, 0x11d3, 
    [ 0x98, 0x9d, 0x00, 0x10, 0x83, 0x01, 0x0e, 0x9b ]};

interface nsIURIContentListener : nsISupports {

  static const char[] IID_STR = NS_IURICONTENTLISTENER_IID_STR;
  static const nsIID IID = NS_IURICONTENTLISTENER_IID;

extern(System):
  nsresult OnStartURIOpen(nsIURI aURI, PRBool *_retval);
  nsresult DoContent(char *aContentType, PRBool aIsContentPreferred, nsIRequest aRequest, nsIStreamListener *aContentHandler, PRBool *_retval);
  nsresult IsPreferred(char *aContentType, char **aDesiredContentType, PRBool *_retval);
  nsresult CanHandleContent(char *aContentType, PRBool aIsContentPreferred, char **aDesiredContentType, PRBool *_retval);
  nsresult GetLoadCookie(nsISupports  *aLoadCookie);
  nsresult SetLoadCookie(nsISupports  aLoadCookie);
  nsresult GetParentContentListener(nsIURIContentListener  *aParentContentListener);
  nsresult SetParentContentListener(nsIURIContentListener  aParentContentListener);

}

