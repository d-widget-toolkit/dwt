module org.eclipse.swt.internal.mozilla.nsILoadGroup;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIRequest;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;
import org.eclipse.swt.internal.mozilla.nsIRequestObserver; 
import org.eclipse.swt.internal.mozilla.nsIInterfaceRequestor;

const char[] NS_ILOADGROUP_IID_STR = "3de0a31c-feaf-400f-9f1e-4ef71f8b20cc";

const nsIID NS_ILOADGROUP_IID= 
  {0x3de0a31c, 0xfeaf, 0x400f, 
    [ 0x9f, 0x1e, 0x4e, 0xf7, 0x1f, 0x8b, 0x20, 0xcc ]};

interface nsILoadGroup : nsIRequest {

  static const char[] IID_STR = NS_ILOADGROUP_IID_STR;
  static const nsIID IID = NS_ILOADGROUP_IID;

extern(System):
  nsresult GetGroupObserver(nsIRequestObserver  *aGroupObserver);
  nsresult SetGroupObserver(nsIRequestObserver  aGroupObserver);
  nsresult GetDefaultLoadRequest(nsIRequest  *aDefaultLoadRequest);
  nsresult SetDefaultLoadRequest(nsIRequest  aDefaultLoadRequest);
  nsresult AddRequest(nsIRequest aRequest, nsISupports aContext);
  nsresult RemoveRequest(nsIRequest aRequest, nsISupports aContext, nsresult aStatus);
  nsresult GetRequests(nsISimpleEnumerator  *aRequests);
  nsresult GetActiveCount(PRUint32 *aActiveCount);
  nsresult GetNotificationCallbacks(nsIInterfaceRequestor  *aNotificationCallbacks);
  nsresult SetNotificationCallbacks(nsIInterfaceRequestor  aNotificationCallbacks);

}

