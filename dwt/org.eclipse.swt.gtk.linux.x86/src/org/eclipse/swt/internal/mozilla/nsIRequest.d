module org.eclipse.swt.internal.mozilla.nsIRequest;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsILoadGroup;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

alias PRUint32 nsLoadFlags;

const char[] NS_IREQUEST_IID_STR = "ef6bfbd2-fd46-48d8-96b7-9f8f0fd387fe";

const nsIID NS_IREQUEST_IID= 
  {0xef6bfbd2, 0xfd46, 0x48d8, 
    [ 0x96, 0xb7, 0x9f, 0x8f, 0x0f, 0xd3, 0x87, 0xfe ]};

interface nsIRequest : nsISupports {

  static const char[] IID_STR = NS_IREQUEST_IID_STR;
  static const nsIID IID = NS_IREQUEST_IID;

extern(System):
  nsresult GetName(nsACString * aName);
  nsresult IsPending(PRBool *_retval);
  nsresult GetStatus(nsresult *aStatus);
  nsresult Cancel(nsresult aStatus);
  nsresult Suspend();
  nsresult Resume();
  nsresult GetLoadGroup(nsILoadGroup  *aLoadGroup);
  nsresult SetLoadGroup(nsILoadGroup  aLoadGroup);
  nsresult GetLoadFlags(nsLoadFlags *aLoadFlags);
  nsresult SetLoadFlags(nsLoadFlags aLoadFlags);

  enum { LOAD_NORMAL = 0U };
  enum { LOAD_BACKGROUND = 1U };
  enum { INHIBIT_CACHING = 128U };
  enum { INHIBIT_PERSISTENT_CACHING = 256U };
  enum { LOAD_BYPASS_CACHE = 512U };
  enum { LOAD_FROM_CACHE = 1024U };
  enum { VALIDATE_ALWAYS = 2048U };
  enum { VALIDATE_NEVER = 4096U };
  enum { VALIDATE_ONCE_PER_SESSION = 8192U };

}

