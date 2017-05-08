module org.eclipse.swt.internal.mozilla.nsIURL;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIURI;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IURL_IID_STR = "d6116970-8034-11d3-9399-00104ba0fd40";

const nsIID NS_IURL_IID= 
  {0xd6116970, 0x8034, 0x11d3, 
    [ 0x93, 0x99, 0x00, 0x10, 0x4b, 0xa0, 0xfd, 0x40 ]};

interface nsIURL : nsIURI {

  static const char[] IID_STR = NS_IURL_IID_STR;
  static const nsIID IID = NS_IURL_IID;

extern(System):
  nsresult GetFilePath(nsACString * aFilePath);
  nsresult SetFilePath(nsACString * aFilePath);
  nsresult GetParam(nsACString * aParam);
  nsresult SetParam(nsACString * aParam);
  nsresult GetQuery(nsACString * aQuery);
  nsresult SetQuery(nsACString * aQuery);
  nsresult GetRef(nsACString * aRef);
  nsresult SetRef(nsACString * aRef);
  nsresult GetDirectory(nsACString * aDirectory);
  nsresult SetDirectory(nsACString * aDirectory);
  nsresult GetFileName(nsACString * aFileName);
  nsresult SetFileName(nsACString * aFileName);
  nsresult GetFileBaseName(nsACString * aFileBaseName);
  nsresult SetFileBaseName(nsACString * aFileBaseName);
  nsresult GetFileExtension(nsACString * aFileExtension);
  nsresult SetFileExtension(nsACString * aFileExtension);
  nsresult GetCommonBaseSpec(nsIURI aURIToCompare, nsACString * _retval);
  nsresult GetRelativeSpec(nsIURI aURIToCompare, nsACString * _retval);

}

