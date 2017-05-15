module org.eclipse.swt.internal.mozilla.nsISupportsArray;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsICollection;

typedef PRBool function(nsISupports, void*) nsISupportsArrayEnumFunc;

const char[] NS_ISUPPORTSARRAY_IID_STR = "791eafa0-b9e6-11d1-8031-006008159b5a";

const nsIID NS_ISUPPORTSARRAY_IID= 
  {0x791eafa0, 0xb9e6, 0x11d1, 
    [ 0x80, 0x31, 0x00, 0x60, 0x08, 0x15, 0x9b, 0x5a ]};

interface nsISupportsArray : nsICollection {

  static const char[] IID_STR = NS_ISUPPORTSARRAY_IID_STR;
  static const nsIID IID = NS_ISUPPORTSARRAY_IID;

extern(System):
  PRBool Equals(nsISupportsArray other);
  nsISupports  ElementAt(PRUint32 aIndex);
  PRInt32 IndexOf(nsISupports aPossibleElement);
  PRInt32 IndexOfStartingAt(nsISupports aPossibleElement, PRUint32 aStartIndex);
  PRInt32 LastIndexOf(nsISupports aPossibleElement);
  nsresult GetIndexOf(nsISupports aPossibleElement, PRInt32 *_retval);
  nsresult GetIndexOfStartingAt(nsISupports aPossibleElement, PRUint32 aStartIndex, PRInt32 *_retval);
  nsresult GetLastIndexOf(nsISupports aPossibleElement, PRInt32 *_retval);
  PRBool InsertElementAt(nsISupports aElement, PRUint32 aIndex);
  PRBool ReplaceElementAt(nsISupports aElement, PRUint32 aIndex);
  PRBool RemoveElementAt(PRUint32 aIndex);
  PRBool RemoveLastElement(nsISupports aElement);
  nsresult DeleteLastElement(nsISupports aElement);
  nsresult DeleteElementAt(PRUint32 aIndex);
  PRBool AppendElements(nsISupportsArray aElements);
  nsresult Compact();
  PRBool EnumerateForwards(nsISupportsArrayEnumFunc aFunc, void * aData);
  PRBool EnumerateBackwards(nsISupportsArrayEnumFunc aFunc, void * aData);
  nsresult Clone(nsISupportsArray *_retval);
  PRBool MoveElement(PRInt32 aFrom, PRInt32 aTo);
  PRBool InsertElementsAt(nsISupportsArray aOther, PRUint32 aIndex);
  PRBool RemoveElementsAt(PRUint32 aIndex, PRUint32 aCount);
  PRBool SizeTo(PRInt32 aSize);

}

