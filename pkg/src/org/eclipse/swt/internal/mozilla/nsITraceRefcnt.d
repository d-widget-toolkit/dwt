module org.eclipse.swt.internal.mozilla.nsITraceRefcnt;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_ITRACEREFCNT_IID_STR = "273dc92f-0fe6-4545-96a9-21be77828039";

const nsIID NS_ITRACEREFCNT_IID= 
  {0x273dc92f, 0x0fe6, 0x4545, 
    [ 0x96, 0xa9, 0x21, 0xbe, 0x77, 0x82, 0x80, 0x39 ]};

interface nsITraceRefcnt : nsISupports {
  static const char[] IID_STR = NS_ITRACEREFCNT_IID_STR;
  static const nsIID IID = NS_ITRACEREFCNT_IID;

extern(System):
  nsresult LogAddRef(void * aPtr, nsrefcnt aNewRefcnt, char *aTypeName, PRUint32 aInstanceSize);
  nsresult LogRelease(void * aPtr, nsrefcnt aNewRefcnt, char *aTypeName);
  nsresult LogCtor(void * aPtr, char *aTypeName, PRUint32 aInstanceSize);
  nsresult LogDtor(void * aPtr, char *aTypeName, PRUint32 aInstanceSize);
  nsresult LogAddCOMPtr(void * aPtr, nsISupports aObject);
  nsresult LogReleaseCOMPtr(void * aPtr, nsISupports aObject);
}

