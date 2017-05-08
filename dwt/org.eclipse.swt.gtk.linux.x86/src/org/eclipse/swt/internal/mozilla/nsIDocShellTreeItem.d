module org.eclipse.swt.internal.mozilla.nsIDocShellTreeItem;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDocShellTreeOwner;

const char[] NS_IDOCSHELLTREEITEM_IID_STR = "7d935d63-6d2a-4600-afb5-9a4f7d68b825";

const nsIID NS_IDOCSHELLTREEITEM_IID= 
  {0x7d935d63, 0x6d2a, 0x4600, 
    [ 0xaf, 0xb5, 0x9a, 0x4f, 0x7d, 0x68, 0xb8, 0x25 ]};

interface nsIDocShellTreeItem : nsISupports {

  static const char[] IID_STR = NS_IDOCSHELLTREEITEM_IID_STR;
  static const nsIID IID = NS_IDOCSHELLTREEITEM_IID;

extern(System):
  nsresult GetName(PRUnichar * *aName);
  nsresult SetName(PRUnichar * aName);
  nsresult NameEquals(PRUnichar *name, PRBool *_retval);

  enum { typeChrome = 0 };
  enum { typeContent = 1 };
  enum { typeContentWrapper = 2 };
  enum { typeChromeWrapper = 3 };
  enum { typeAll = 2147483647 };

  nsresult GetItemType(PRInt32 *aItemType);
  nsresult SetItemType(PRInt32 aItemType);
  nsresult GetParent(nsIDocShellTreeItem  *aParent);
  nsresult GetSameTypeParent(nsIDocShellTreeItem  *aSameTypeParent);
  nsresult GetRootTreeItem(nsIDocShellTreeItem  *aRootTreeItem);
  nsresult GetSameTypeRootTreeItem(nsIDocShellTreeItem  *aSameTypeRootTreeItem);
  nsresult FindItemWithName(PRUnichar *name, nsISupports aRequestor, nsIDocShellTreeItem aOriginalRequestor, nsIDocShellTreeItem *_retval);
  nsresult GetTreeOwner(nsIDocShellTreeOwner  *aTreeOwner);
  nsresult SetTreeOwner(nsIDocShellTreeOwner treeOwner);
  nsresult GetChildOffset(PRInt32 *aChildOffset);
  nsresult SetChildOffset(PRInt32 aChildOffset);

}

