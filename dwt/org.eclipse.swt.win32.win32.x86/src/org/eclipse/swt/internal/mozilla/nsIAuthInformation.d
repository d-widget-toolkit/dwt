module org.eclipse.swt.internal.mozilla.nsIAuthInformation;



import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsID;

import org.eclipse.swt.internal.mozilla.Common;

import org.eclipse.swt.internal.mozilla.nsStringAPI;



const char[] NS_IAUTHINFORMATION_IID_STR =  "0d73639c-2a92-4518-9f92-28f71fea5f20";



const nsIID NS_IAUTHINFORMATION_IID =

   {0x0d73639c, 0x2a92, 0x4518, 

    [ 0x9f, 0x92, 0x28, 0xf7, 0x1f, 0xea, 0x5f, 0x20 ] };



interface nsIAuthInformation : nsISupports {



  static const char[] IID_STR = NS_IAUTHINFORMATION_IID_STR;

  static const nsIID IID = NS_IAUTHINFORMATION_IID;



  enum { AUTH_HOST = 1U }

  enum { AUTH_PROXY = 2U }

  enum { NEED_DOMAIN = 4U }

  enum { ONLY_PASSWORD = 8U }



extern(System):

  nsresult GetFlags(PRUint32 *aFlags);

  nsresult GetRealm(nsAString * aRealm);

  nsresult GetAuthenticationScheme(nsACString * aAuthenticationScheme);

  nsresult GetUsername(nsAString * aUsername);

  nsresult SetUsername(nsAString * aUsername);

  nsresult GetPassword(nsAString * aPassword);

  nsresult SetPassword(nsAString * aPassword);

  nsresult GetDomain(nsAString * aDomain);

  nsresult SetDomain(nsAString * aDomain);



};

