module org.eclipse.swt.internal.mozilla.nsIObserver;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_IOBSERVER_IID_STR = "db242e01-e4d9-11d2-9dde-000064657374";

const nsIID NS_IOBSERVER_IID= 
  {0xdb242e01, 0xe4d9, 0x11d2, 
    [ 0x9d, 0xde, 0x00, 0x00, 0x64, 0x65, 0x73, 0x74 ]};

interface nsIObserver : nsISupports {

  static const char[] IID_STR = NS_IOBSERVER_IID_STR;
  static const nsIID IID = NS_IOBSERVER_IID;

extern(System):
  nsresult Observe(nsISupports aSubject, char *aTopic, PRUnichar *aData);

}

