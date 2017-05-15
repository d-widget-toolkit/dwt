module org.eclipse.swt.internal.mozilla.nsIPrompt;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_IPROMPT_IID_STR = "a63f70c0-148b-11d3-9333-00104ba0fd40";

const nsIID NS_IPROMPT_IID= 
  {0xa63f70c0, 0x148b, 0x11d3, 
    [ 0x93, 0x33, 0x00, 0x10, 0x4b, 0xa0, 0xfd, 0x40 ]};

interface nsIPrompt : nsISupports {

  static const char[] IID_STR = NS_IPROMPT_IID_STR;
  static const nsIID IID = NS_IPROMPT_IID;

extern(System):
  nsresult Alert(PRUnichar *dialogTitle, PRUnichar *text);
  nsresult AlertCheck(PRUnichar *dialogTitle, PRUnichar *text, PRUnichar *checkMsg, PRBool *checkValue);
  nsresult Confirm(PRUnichar *dialogTitle, PRUnichar *text, PRBool *_retval);
  nsresult ConfirmCheck(PRUnichar *dialogTitle, PRUnichar *text, PRUnichar *checkMsg, PRBool *checkValue, PRBool *_retval);

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

  nsresult ConfirmEx(PRUnichar *dialogTitle, PRUnichar *text, PRUint32 buttonFlags, PRUnichar *button0Title, PRUnichar *button1Title, PRUnichar *button2Title, PRUnichar *checkMsg, PRBool *checkValue, PRInt32 *_retval);
  nsresult Prompt(PRUnichar *dialogTitle, PRUnichar *text, PRUnichar **value, PRUnichar *checkMsg, PRBool *checkValue, PRBool *_retval);
  nsresult PromptPassword(PRUnichar *dialogTitle, PRUnichar *text, PRUnichar **password, PRUnichar *checkMsg, PRBool *checkValue, PRBool *_retval);
  nsresult PromptUsernameAndPassword(PRUnichar *dialogTitle, PRUnichar *text, PRUnichar **username, PRUnichar **password, PRUnichar *checkMsg, PRBool *checkValue, PRBool *_retval);
  nsresult Select(PRUnichar *dialogTitle, PRUnichar *text, PRUint32 count, PRUnichar **selectList, PRInt32 *outSelection, PRBool *_retval);

}

