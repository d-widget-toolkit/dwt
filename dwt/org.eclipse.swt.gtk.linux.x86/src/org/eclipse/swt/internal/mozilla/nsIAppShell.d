module org.eclipse.swt.internal.mozilla.nsIAppShell;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIEventQueue;

const char[] NS_IAPPSHELL_IID_STR = "a0757c31-eeac-11d1-9ec1-00aa002fb821";

const nsIID NS_IAPPSHELL_IID= 
  {0xa0757c31, 0xeeac, 0x11d1, 
    [ 0x9e, 0xc1, 0x00, 0xaa, 0x00, 0x2f, 0xb8, 0x21 ]};

interface nsIAppShell : nsISupports {
  static const char[] IID_STR = NS_IAPPSHELL_IID_STR;
  static const nsIID IID = NS_IAPPSHELL_IID;

extern(System):
  nsresult Create(int *argc, char **argv);
  nsresult Run();
  nsresult Spinup();
  nsresult Spindown();
  nsresult ListenToEventQueue(nsIEventQueue * aQueue, PRBool aListen);
  nsresult GetNativeEvent(PRBool * aRealEvent, void * * aEvent);
  nsresult DispatchNativeEvent(PRBool aRealEvent, void * aEvent);
  nsresult Exit();
}

