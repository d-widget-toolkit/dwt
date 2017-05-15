module org.eclipse.swt.internal.mozilla.nsIPromptService;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDOMWindow;

const char[] NS_IPROMPTSERVICE_IID_STR = "1630c61a-325e-49ca-8759-a31b16c47aa5";

const nsIID NS_IPROMPTSERVICE_IID= 
  {0x1630c61a, 0x325e, 0x49ca, 
    [ 0x87, 0x59, 0xa3, 0x1b, 0x16, 0xc4, 0x7a, 0xa5 ]};

interface nsIPromptService : nsISupports {

  static const char[] IID_STR = NS_IPROMPTSERVICE_IID_STR;
  static const nsIID IID = NS_IPROMPTSERVICE_IID;

extern(System):
  nsresult Alert(nsIDOMWindow aParent, PRUnichar *aDialogTitle, PRUnichar *aText);
  nsresult AlertCheck(nsIDOMWindow aParent, PRUnichar *aDialogTitle, PRUnichar *aText, PRUnichar *aCheckMsg, PRBool *aCheckState);
  nsresult Confirm(nsIDOMWindow aParent, PRUnichar *aDialogTitle, PRUnichar *aText, PRBool *_retval);
  nsresult ConfirmCheck(nsIDOMWindow aParent, PRUnichar *aDialogTitle, PRUnichar *aText, PRUnichar *aCheckMsg, PRBool *aCheckState, PRBool *_retval);

  enum { BUTTON_POS_0 = 1U };
  enum { BUTTON_POS_1 = 256U };
  enum { BUTTON_POS_2 = 65536U };
  enum { BUTTON_TITLE_OK = 1U };
  enum { BUTTON_TITLE_CANCEL = 2U };
  enum { BUTTON_TITLE_YES = 3U };
  enum { BUTTON_TITLE_NO = 4U };
  enum { BUTTON_TITLE_SAVE = 5U };
  enum { BUTTON_TITLE_DONT_SAVE = 6U };
  enum { BUTTON_TITLE_REVERT = 7U };
  enum { BUTTON_TITLE_IS_STRING = 127U };
  enum { BUTTON_POS_0_DEFAULT = 0U };
  enum { BUTTON_POS_1_DEFAULT = 16777216U };
  enum { BUTTON_POS_2_DEFAULT = 33554432U };
  enum { BUTTON_DELAY_ENABLE = 67108864U };
  enum { STD_OK_CANCEL_BUTTONS = 513U };
  enum { STD_YES_NO_BUTTONS = 1027U };

  nsresult ConfirmEx(nsIDOMWindow aParent, PRUnichar *aDialogTitle, PRUnichar *aText, PRUint32 aButtonFlags, PRUnichar *aButton0Title, PRUnichar *aButton1Title, PRUnichar *aButton2Title, PRUnichar *aCheckMsg, PRBool *aCheckState, PRInt32 *_retval);
  nsresult Prompt(nsIDOMWindow aParent, PRUnichar *aDialogTitle, PRUnichar *aText, PRUnichar **aValue, PRUnichar *aCheckMsg, PRBool *aCheckState, PRBool *_retval);
  nsresult PromptUsernameAndPassword(nsIDOMWindow aParent, PRUnichar *aDialogTitle, PRUnichar *aText, PRUnichar **aUsername, PRUnichar **aPassword, PRUnichar *aCheckMsg, PRBool *aCheckState, PRBool *_retval);
  nsresult PromptPassword(nsIDOMWindow aParent, PRUnichar *aDialogTitle, PRUnichar *aText, PRUnichar **aPassword, PRUnichar *aCheckMsg, PRBool *aCheckState, PRBool *_retval);
  nsresult Select(nsIDOMWindow aParent, PRUnichar *aDialogTitle, PRUnichar *aText, PRUint32 aCount, PRUnichar **aSelectList, PRInt32 *aOutSelection, PRBool *_retval);

}

