module org.eclipse.swt.internal.mozilla.nsIURI;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IURI_IID_STR = "07a22cc0-0ce5-11d3-9331-00104ba0fd40";

const nsIID NS_IURI_IID= 
  {0x07a22cc0, 0x0ce5, 0x11d3, 
    [ 0x93, 0x31, 0x00, 0x10, 0x4b, 0xa0, 0xfd, 0x40 ]};

interface nsIURI : nsISupports {

  static const char[] IID_STR = NS_IURI_IID_STR;
  static const nsIID IID = NS_IURI_IID;

extern(System):
  nsresult GetSpec(nsACString * aSpec);
  nsresult SetSpec(nsACString * aSpec);
  nsresult GetPrePath(nsACString * aPrePath);
  nsresult GetScheme(nsACString * aScheme);
  nsresult SetScheme(nsACString * aScheme);
  nsresult GetUserPass(nsACString * aUserPass);
  nsresult SetUserPass(nsACString * aUserPass);
  nsresult GetUsername(nsACString * aUsername);
  nsresult SetUsername(nsACString * aUsername);
  nsresult GetPassword(nsACString * aPassword);
  nsresult SetPassword(nsACString * aPassword);
  nsresult GetHostPort(nsACString * aHostPort);
  nsresult SetHostPort(nsACString * aHostPort);
  nsresult GetHost(nsACString * aHost);
  nsresult SetHost(nsACString * aHost);
  nsresult GetPort(PRInt32 *aPort);
  nsresult SetPort(PRInt32 aPort);
  nsresult GetPath(nsACString * aPath);
  nsresult SetPath(nsACString * aPath);
  nsresult Equals(nsIURI other, PRBool *_retval);
  nsresult SchemeIs(char *scheme, PRBool *_retval);
  nsresult Clone(nsIURI *_retval);
  nsresult Resolve(nsACString * relativePath, nsACString * _retval);
  nsresult GetAsciiSpec(nsACString * aAsciiSpec);
  nsresult GetAsciiHost(nsACString * aAsciiHost);
  nsresult GetOriginCharset(nsACString * aOriginCharset);

}

