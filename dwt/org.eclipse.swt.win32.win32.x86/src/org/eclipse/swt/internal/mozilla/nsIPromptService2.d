module org.eclipse.swt.internal.mozilla.nsIPromptService2;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsICancelable;
import org.eclipse.swt.internal.mozilla.nsIChannel;
import org.eclipse.swt.internal.mozilla.nsIAuthInformation;
import org.eclipse.swt.internal.mozilla.nsIAuthPromptCallback;
import org.eclipse.swt.internal.mozilla.nsIPromptService;

import org.eclipse.swt.internal.mozilla.nsIDOMWindow;

const char[] NS_IPROMPTSERVICE2_IID_STR = "cf86d196-dbee-4482-9dfa-3477aa128319";

const nsIID NS_IPROMPTSERVICE2_IID= 
  {0xcf86d196, 0xdbee, 0x4482, 
    [ 0x9d, 0xfa, 0x34, 0x77, 0xaa, 0x12, 0x83, 0x19 ]};

interface nsIPromptService2 : nsIPromptService {

  static const char[] IID_STR = NS_IPROMPTSERVICE2_IID_STR;
  static const nsIID IID = NS_IPROMPTSERVICE2_IID;

extern(System):
    public nsresult PromptAuth(nsIDOMWindow aParent, nsIChannel aChannel, PRUint32 level, nsIAuthInformation authInfo, PRUnichar* checkboxLabel, PRBool* checkValue, PRBool* _retval);

    public nsresult AsyncPromptAuth(nsIDOMWindow aParent, nsIChannel aChannel, nsIAuthPromptCallback aCallback, nsISupports aContext, PRUint32 level, nsIAuthInformation authInfo, PRUnichar* checkboxLabel, PRBool* checkValue, nsICancelable* _retval);

}
