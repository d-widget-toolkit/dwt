module org.eclipse.swt.internal.mozilla.nsIRequestObserver;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIRequest; 

const char[] NS_IREQUESTOBSERVER_IID_STR = "fd91e2e0-1481-11d3-9333-00104ba0fd40";

const nsIID NS_IREQUESTOBSERVER_IID= 
  {0xfd91e2e0, 0x1481, 0x11d3, 
    [ 0x93, 0x33, 0x00, 0x10, 0x4b, 0xa0, 0xfd, 0x40 ]};

interface nsIRequestObserver : nsISupports {

  static const char[] IID_STR = NS_IREQUESTOBSERVER_IID_STR;
  static const nsIID IID = NS_IREQUESTOBSERVER_IID;

extern(System):
  nsresult OnStartRequest(nsIRequest aRequest, nsISupports aContext);
  nsresult OnStopRequest(nsIRequest aRequest, nsISupports aContext, nsresult aStatusCode);

}

