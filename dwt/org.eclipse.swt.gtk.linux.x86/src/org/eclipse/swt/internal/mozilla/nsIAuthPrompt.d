module org.eclipse.swt.internal.mozilla.nsIAuthPrompt;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

// import org.eclipse.swt.internal.mozilla.nsIPrompt;

const char[] NS_IAUTHPROMPT_IID_STR = "2f977d45-5485-11d4-87e2-0010a4e75ef2";

const nsIID NS_IAUTHPROMPT_IID= 
  {0x2f977d45, 0x5485, 0x11d4, 
    [ 0x87, 0xe2, 0x00, 0x10, 0xa4, 0xe7, 0x5e, 0xf2 ]};

interface nsIAuthPrompt : nsISupports {

  static const char[] IID_STR = NS_IAUTHPROMPT_IID_STR;
  static const nsIID IID = NS_IAUTHPROMPT_IID;

  enum { SAVE_PASSWORD_NEVER = 0U };
  enum { SAVE_PASSWORD_FOR_SESSION = 1U };
  enum { SAVE_PASSWORD_PERMANENTLY = 2U };

extern(System):
  nsresult Prompt(PRUnichar *dialogTitle, PRUnichar *text, PRUnichar *passwordRealm, PRUint32 savePassword, PRUnichar *defaultText, PRUnichar **result, PRBool *_retval);
  nsresult PromptUsernameAndPassword(PRUnichar *dialogTitle, PRUnichar *text, PRUnichar *passwordRealm, PRUint32 savePassword, PRUnichar **user, PRUnichar **pwd, PRBool *_retval);
  nsresult PromptPassword(PRUnichar *dialogTitle, PRUnichar *text, PRUnichar *passwordRealm, PRUint32 savePassword, PRUnichar **pwd, PRBool *_retval);

}

