module org.eclipse.swt.internal.mozilla.nsIFilePicker_1_8;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsILocalFile;
import org.eclipse.swt.internal.mozilla.nsIFileURL; 
import org.eclipse.swt.internal.mozilla.nsIDOMWindow; 
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IFILEPICKER_IID_STR = "80faf095-c807-4558-a2cc-185ed70754ea";

const nsIID NS_IFILEPICKER_IID= 
  {0x80faf095, 0xc807, 0x4558, 
    [ 0xa2, 0xcc, 0x18, 0x5e, 0xd7, 0x07, 0x54, 0xea ]};

//extern(System)
interface nsIFilePicker_1_8 : nsISupports {

  static const char[] IID_STR = NS_IFILEPICKER_IID_STR;
  static const nsIID IID = NS_IFILEPICKER_IID;

  enum { modeOpen = 0 };
  enum { modeSave = 1 };
  enum { modeGetFolder = 2 };
  enum { modeOpenMultiple = 3 };
  enum { returnOK = 0 };
  enum { returnCancel = 1 };
  enum { returnReplace = 2 };
  enum { filterAll = 1 };
  enum { filterHTML = 2 };
  enum { filterText = 4 };
  enum { filterImages = 8 };
  enum { filterXML = 16 };
  enum { filterXUL = 32 };
  enum { filterApps = 64 };

extern(System):
  nsresult Init(nsIDOMWindow parent, nsAString * title, PRInt16 mode);
  nsresult AppendFilters(PRInt32 filterMask);
  nsresult AppendFilter(nsAString * title, nsAString * filter);
  nsresult GetDefaultString(nsAString * aDefaultString);
  nsresult SetDefaultString(nsAString * aDefaultString);
  nsresult GetDefaultExtension(nsAString * aDefaultExtension);
  nsresult SetDefaultExtension(nsAString * aDefaultExtension);
  nsresult GetFilterIndex(PRInt32 *aFilterIndex);
  nsresult SetFilterIndex(PRInt32 aFilterIndex);
  nsresult GetDisplayDirectory(nsILocalFile  *aDisplayDirectory);
  nsresult SetDisplayDirectory(nsILocalFile  aDisplayDirectory);
  nsresult GetFile(nsILocalFile  *aFile);
  nsresult GetFileURL(nsIFileURL  *aFileURL);
  nsresult GetFiles(nsISimpleEnumerator  *aFiles);
  nsresult Show(PRInt16 *_retval);

}
