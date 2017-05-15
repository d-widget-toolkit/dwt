module org.eclipse.swt.internal.mozilla.nsIDocumentCharsetInfo;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIAtom;

const char[] NS_IDOCUMENTCHARSETINFO_IID_STR = "2d40b291-01e1-11d4-9d0e-0050040007b2";

const nsIID NS_IDOCUMENTCHARSETINFO_IID= 
  {0x2d40b291, 0x01e1, 0x11d4, 
    [ 0x9d, 0x0e, 0x00, 0x50, 0x04, 0x00, 0x07, 0xb2 ]};

interface nsIDocumentCharsetInfo : nsISupports {

  static const char[] IID_STR = NS_IDOCUMENTCHARSETINFO_IID_STR;
  static const nsIID IID = NS_IDOCUMENTCHARSETINFO_IID;

extern(System):
  nsresult GetForcedCharset(nsIAtom  *aForcedCharset);
  nsresult SetForcedCharset(nsIAtom  aForcedCharset);
  nsresult GetForcedDetector(PRBool *aForcedDetector);
  nsresult SetForcedDetector(PRBool aForcedDetector);
  nsresult GetParentCharset(nsIAtom  *aParentCharset);
  nsresult SetParentCharset(nsIAtom  aParentCharset);
  nsresult GetParentCharsetSource(PRInt32 *aParentCharsetSource);
  nsresult SetParentCharsetSource(PRInt32 aParentCharsetSource);

}

