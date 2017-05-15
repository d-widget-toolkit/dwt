module org.eclipse.swt.internal.mozilla.nsIDOMEvent;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIDOMEventTarget;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMEVENT_IID_STR = "a66b7b80-ff46-bd97-0080-5f8ae38add32";

const nsIID NS_IDOMEVENT_IID= 
  {0xa66b7b80, 0xff46, 0xbd97, 
    [ 0x00, 0x80, 0x5f, 0x8a, 0xe3, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMEvent : nsISupports {

  static const char[] IID_STR = NS_IDOMEVENT_IID_STR;
  static const nsIID IID = NS_IDOMEVENT_IID;

extern(System):
  enum { CAPTURING_PHASE = 1U };
  enum { AT_TARGET = 2U };
  enum { BUBBLING_PHASE = 3U };

  nsresult GetType(nsAString * aType);
  nsresult GetTarget(nsIDOMEventTarget  *aTarget);
  nsresult GetCurrentTarget(nsIDOMEventTarget  *aCurrentTarget);
  nsresult GetEventPhase(PRUint16 *aEventPhase);
  nsresult GetBubbles(PRBool *aBubbles);
  nsresult GetCancelable(PRBool *aCancelable);
  nsresult GetTimeStamp(DOMTimeStamp *aTimeStamp);
  nsresult StopPropagation();
  nsresult PreventDefault();
  nsresult InitEvent(nsAString * eventTypeArg, PRBool canBubbleArg, PRBool cancelableArg);

}

