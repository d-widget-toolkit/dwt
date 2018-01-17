module org.eclipse.swt.internal.mozilla.nsIStreamListener;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIRequestObserver;
import org.eclipse.swt.internal.mozilla.nsIRequest;
import org.eclipse.swt.internal.mozilla.nsIInputStream;

const char[] NS_ISTREAMLISTENER_IID_STR = "1a637020-1482-11d3-9333-00104ba0fd40";

const nsIID NS_ISTREAMLISTENER_IID= 
  {0x1a637020, 0x1482, 0x11d3, 
    [ 0x93, 0x33, 0x00, 0x10, 0x4b, 0xa0, 0xfd, 0x40 ]};

interface nsIStreamListener : nsIRequestObserver {

  static const char[] IID_STR = NS_ISTREAMLISTENER_IID_STR;
  static const nsIID IID = NS_ISTREAMLISTENER_IID;

extern(System):
  nsresult OnDataAvailable(nsIRequest aRequest, nsISupports aContext, nsIInputStream aInputStream, PRUint32 aOffset, PRUint32 aCount);

}

