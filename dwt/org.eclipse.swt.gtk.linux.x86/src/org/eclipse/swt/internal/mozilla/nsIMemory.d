module org.eclipse.swt.internal.mozilla.nsIMemory;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_IMEMORY_IID_STR = "59e7e77a-38e4-11d4-8cf5-0060b0fc14a3";

const nsIID NS_IMEMORY_IID= 
  {0x59e7e77a, 0x38e4, 0x11d4, 
    [ 0x8c, 0xf5, 0x00, 0x60, 0xb0, 0xfc, 0x14, 0xa3 ]};

interface nsIMemory : nsISupports {
  static const char[] IID_STR = NS_IMEMORY_IID_STR;
  static const nsIID IID = NS_IMEMORY_IID;
  
extern(System):
  void *    Alloc(size_t size);
  void *    Realloc(void * ptr, size_t newSize);
  void      Free(void * ptr);
  nsresult  HeapMinimize(PRBool immediate);
  nsresult  IsLowMemory(PRBool *_retval);
}

