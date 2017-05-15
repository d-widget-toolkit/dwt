module org.eclipse.swt.internal.mozilla.nsIFile;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IFILE_IID_STR = "c8c0a080-0868-11d3-915f-d9d889d48e3c";

const nsIID NS_IFILE_IID= 
  {0xc8c0a080, 0x0868, 0x11d3, 
    [ 0x91, 0x5f, 0xd9, 0xd8, 0x89, 0xd4, 0x8e, 0x3c ]};

interface nsIFile : nsISupports {
  static const char[] IID_STR = NS_IFILE_IID_STR;
  static const nsIID IID = NS_IFILE_IID;

  enum { NORMAL_FILE_TYPE = 0U };
  enum { DIRECTORY_TYPE = 1U };

extern(System):
  nsresult Append(nsAString * node);
  nsresult AppendNative(nsACString * node);
  nsresult Normalize();
  nsresult Create(PRUint32 type, PRUint32 permissions);
  nsresult GetLeafName(nsAString * aLeafName);
  nsresult SetLeafName(nsAString * aLeafName);
  nsresult GetNativeLeafName(nsACString * aNativeLeafName);
  nsresult SetNativeLeafName(nsACString * aNativeLeafName);
  nsresult CopyTo(nsIFile newParentDir, nsAString * newName);
  nsresult CopyToNative(nsIFile newParentDir, nsACString * newName);
  nsresult CopyToFollowingLinks(nsIFile newParentDir, nsAString * newName);
  nsresult CopyToFollowingLinksNative(nsIFile newParentDir, nsACString * newName);
  nsresult MoveTo(nsIFile newParentDir, nsAString * newName);
  nsresult MoveToNative(nsIFile newParentDir, nsACString * newName);
  nsresult Remove(PRBool recursive);
  nsresult GetPermissions(PRUint32 *aPermissions);
  nsresult SetPermissions(PRUint32 aPermissions);
  nsresult GetPermissionsOfLink(PRUint32 *aPermissionsOfLink);
  nsresult SetPermissionsOfLink(PRUint32 aPermissionsOfLink);
  nsresult GetLastModifiedTime(PRInt64 *aLastModifiedTime);
  nsresult SetLastModifiedTime(PRInt64 aLastModifiedTime);
  nsresult GetLastModifiedTimeOfLink(PRInt64 *aLastModifiedTimeOfLink);
  nsresult SetLastModifiedTimeOfLink(PRInt64 aLastModifiedTimeOfLink);
  nsresult GetFileSize(PRInt64 *aFileSize);
  nsresult SetFileSize(PRInt64 aFileSize);
  nsresult GetFileSizeOfLink(PRInt64 *aFileSizeOfLink);
  nsresult GetTarget(nsAString * aTarget);
  nsresult GetNativeTarget(nsACString * aNativeTarget);
  nsresult GetPath(nsAString * aPath);
  nsresult GetNativePath(nsACString * aNativePath);
  nsresult Exists(PRBool *_retval);
  nsresult IsWritable(PRBool *_retval);
  nsresult IsReadable(PRBool *_retval);
  nsresult IsExecutable(PRBool *_retval);
  nsresult IsHidden(PRBool *_retval);
  nsresult IsDirectory(PRBool *_retval);
  nsresult IsFile(PRBool *_retval);
  nsresult IsSymlink(PRBool *_retval);
  nsresult IsSpecial(PRBool *_retval);
  nsresult CreateUnique(PRUint32 type, PRUint32 permissions);
  nsresult Clone(nsIFile *_retval);
  nsresult Equals(nsIFile inFile, PRBool *_retval);
  nsresult Contains(nsIFile inFile, PRBool recur, PRBool *_retval);
  nsresult GetParent(nsIFile  *aParent);
  nsresult GetDirectoryEntries(nsISimpleEnumerator  *aDirectoryEntries);
}

