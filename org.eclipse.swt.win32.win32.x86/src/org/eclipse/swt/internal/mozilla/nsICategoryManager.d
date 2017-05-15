module org.eclipse.swt.internal.mozilla.nsICategoryManager;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;

const char[] NS_ICATEGORYMANAGER_IID_STR = "3275b2cd-af6d-429a-80d7-f0c5120342ac";

const nsIID NS_ICATEGORYMANAGER_IID= 
  {0x3275b2cd, 0xaf6d, 0x429a, 
    [ 0x80, 0xd7, 0xf0, 0xc5, 0x12, 0x03, 0x42, 0xac ]};

interface nsICategoryManager : nsISupports {

  static const char[] IID_STR = NS_ICATEGORYMANAGER_IID_STR;
  static const nsIID IID = NS_ICATEGORYMANAGER_IID;

extern(System):
  nsresult GetCategoryEntry(char *aCategory, char *aEntry, char **_retval);
  nsresult AddCategoryEntry(char *aCategory, char *aEntry, char *aValue, PRBool aPersist, PRBool aReplace, char **_retval);
  nsresult DeleteCategoryEntry(char *aCategory, char *aEntry, PRBool aPersist);
  nsresult DeleteCategory(char *aCategory);
  nsresult EnumerateCategory(char *aCategory, nsISimpleEnumerator *_retval);
  nsresult EnumerateCategories(nsISimpleEnumerator *_retval);
}

