module org.eclipse.swt.internal.mozilla.nsIEventQueue;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIEventTarget;

const char[] NS_IEVENTQUEUE_IID_STR = "176afb41-00a4-11d3-9f2a-00400553eef0";
const nsIID NS_IEVENTQUEUE_IID= 
  {0x176afb41, 0x00a4, 0x11d3, 
    [ 0x9f, 0x2a, 0x00, 0x40, 0x05, 0x53, 0xee, 0xf0 ]};

interface nsIEventQueue : nsIEventTarget {
  static const char[] IID_STR = NS_IEVENTQUEUE_IID_STR;
  static const nsIID IID = NS_IEVENTQUEUE_IID;

extern(System):
  nsresult InitEvent(PLEvent * aEvent, void * owner, PLHandleEventProc handler, PLDestroyEventProc destructor);
  nsresult PostSynchronousEvent(PLEvent * aEvent, void * *aResult);
  nsresult PendingEvents(PRBool *_retval);
  nsresult ProcessPendingEvents();
  nsresult EventLoop();
  nsresult EventAvailable(PRBool * aResult);
  nsresult GetEvent(PLEvent * *_retval);
  nsresult HandleEvent(PLEvent * aEvent);
  nsresult WaitForEvent(PLEvent * *_retval);
  PRInt32  GetEventQueueSelectFD();
  nsresult Init(PRBool aNative);
  nsresult InitFromPRThread(PRThread * thread, PRBool aNative);
  nsresult InitFromPLQueue(PLEventQueue * aQueue);
  nsresult EnterMonitor();
  nsresult ExitMonitor();
  nsresult RevokeEvents(void * owner);
  nsresult GetPLEventQueue(PLEventQueue * *_retval);
  nsresult IsQueueNative(PRBool *_retval);
  nsresult StopAcceptingEvents();

}

