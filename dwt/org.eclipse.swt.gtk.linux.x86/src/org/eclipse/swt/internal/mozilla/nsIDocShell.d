// FIXME; IID's are not consistant with SWT version

module org.eclipse.swt.internal.mozilla.nsIDocShell;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIURI;
import org.eclipse.swt.internal.mozilla.nsIChannel;
import org.eclipse.swt.internal.mozilla.nsIContentViewer;
import org.eclipse.swt.internal.mozilla.nsIURIContentListener;
import org.eclipse.swt.internal.mozilla.nsIChromeEventHandler;
import org.eclipse.swt.internal.mozilla.nsIDocShellLoadInfo;
import org.eclipse.swt.internal.mozilla.nsIDocumentCharsetInfo;
import org.eclipse.swt.internal.mozilla.nsIWebNavigation;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;
import org.eclipse.swt.internal.mozilla.nsIInputStream;
import org.eclipse.swt.internal.mozilla.nsIRequest;
import org.eclipse.swt.internal.mozilla.nsISHEntry;
import org.eclipse.swt.internal.mozilla.nsISecureBrowserUI;
import org.eclipse.swt.internal.mozilla.nsIDOMStorage;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

/******************************************************************************

******************************************************************************/

const char[] NS_IDOCSHELL_IID_STR = "69e5de00-7b8b-11d3-af61-00a024ffc08c";

const nsIID NS_IDOCSHELL_IID= 
  { 0x69e5de00, 0x7b8b, 0x11d3, [0xaf,0x61,0x00,0xa0,0x24,0xff,0xc0,0x8c] };
interface nsIDocShell : nsISupports {

  static const char[] IID_STR = NS_IDOCSHELL_IID_STR;
  static const nsIID IID = NS_IDOCSHELL_IID;

extern(System):
  nsresult LoadURI(nsIURI uri, nsIDocShellLoadInfo loadInfo, PRUint32 aLoadFlags, PRBool firstParty);
  nsresult LoadStream(nsIInputStream aStream, nsIURI aURI, nsACString * aContentType, nsACString * aContentCharset, nsIDocShellLoadInfo aLoadInfo);

  enum { INTERNAL_LOAD_FLAGS_NONE = 0 };
  enum { INTERNAL_LOAD_FLAGS_INHERIT_OWNER = 1 };
  enum { INTERNAL_LOAD_FLAGS_DONT_SEND_REFERRER = 2 };
  enum { INTERNAL_LOAD_FLAGS_ALLOW_THIRD_PARTY_FIXUP = 4 };
  enum { INTERNAL_LOAD_FLAGS_FIRST_LOAD = 8 };

  nsresult InternalLoad(nsIURI aURI, nsIURI aReferrer, nsISupports aOwner, PRUint32 aFlags, PRUnichar *aWindowTarget, char *aTypeHint, nsIInputStream aPostDataStream, nsIInputStream aHeadersStream, PRUint32 aLoadFlags, nsISHEntry aSHEntry, PRBool firstParty, nsIDocShell *aDocShell, nsIRequest *aRequest);

  nsresult CreateLoadInfo(nsIDocShellLoadInfo *loadInfo);
  nsresult PrepareForNewContentModel();
  nsresult SetCurrentURI(nsIURI aURI);
  nsresult FirePageHideNotification(PRBool isUnload);
  nsresult GetPresContext(nsPresContext * *aPresContext);
  nsresult GetPresShell(nsIPresShell * *aPresShell);
  nsresult GetEldestPresShell(nsIPresShell * *aEldestPresShell);
  nsresult GetContentViewer(nsIContentViewer  *aContentViewer);
  nsresult GetChromeEventHandler(nsIChromeEventHandler  *aChromeEventHandler);
  nsresult SetChromeEventHandler(nsIChromeEventHandler  aChromeEventHandler);
  nsresult GetDocumentCharsetInfo(nsIDocumentCharsetInfo  *aDocumentCharsetInfo);
  nsresult SetDocumentCharsetInfo(nsIDocumentCharsetInfo  aDocumentCharsetInfo);
  nsresult GetAllowPlugins(PRBool *aAllowPlugins);
  nsresult SetAllowPlugins(PRBool aAllowPlugins);
  nsresult GetAllowJavascript(PRBool *aAllowJavascript);
  nsresult SetAllowJavascript(PRBool aAllowJavascript);
  nsresult GetAllowMetaRedirects(PRBool *aAllowMetaRedirects);
  nsresult SetAllowMetaRedirects(PRBool aAllowMetaRedirects);
  nsresult GetAllowSubframes(PRBool *aAllowSubframes);
  nsresult SetAllowSubframes(PRBool aAllowSubframes);
  nsresult GetAllowImages(PRBool *aAllowImages);
  nsresult SetAllowImages(PRBool aAllowImages);

  enum { ENUMERATE_FORWARDS = 0 };
  enum { ENUMERATE_BACKWARDS = 1 };

  nsresult GetDocShellEnumerator(PRInt32 aItemType, PRInt32 aDirection, nsISimpleEnumerator *_retval);

  enum { APP_TYPE_UNKNOWN = 0U };
  enum { APP_TYPE_MAIL = 1U };
  enum { APP_TYPE_EDITOR = 2U };

  nsresult GetAppType(PRUint32 *aAppType);
  nsresult SetAppType(PRUint32 aAppType);
  nsresult GetAllowAuth(PRBool *aAllowAuth);
  nsresult SetAllowAuth(PRBool aAllowAuth);
  nsresult GetZoom(float *aZoom);
  nsresult SetZoom(float aZoom);
  nsresult GetMarginWidth(PRInt32 *aMarginWidth);
  nsresult SetMarginWidth(PRInt32 aMarginWidth);
  nsresult GetMarginHeight(PRInt32 *aMarginHeight);
  nsresult SetMarginHeight(PRInt32 aMarginHeight);
  nsresult GetHasFocus(PRBool *aHasFocus);
  nsresult SetHasFocus(PRBool aHasFocus);
  nsresult GetCanvasHasFocus(PRBool *aCanvasHasFocus);
  nsresult SetCanvasHasFocus(PRBool aCanvasHasFocus);
  nsresult TabToTreeOwner(PRBool forward, PRBool *tookFocus);

  enum { BUSY_FLAGS_NONE = 0U };
  enum { BUSY_FLAGS_BUSY = 1U };
  enum { BUSY_FLAGS_BEFORE_PAGE_LOAD = 2U };
  enum { BUSY_FLAGS_PAGE_LOADING = 4U };
  enum { LOAD_CMD_NORMAL = 1U };
  enum { LOAD_CMD_RELOAD = 2U };
  enum { LOAD_CMD_HISTORY = 4U };

  nsresult GetBusyFlags(PRUint32 *aBusyFlags);
  nsresult GetLoadType(PRUint32 *aLoadType);
  nsresult SetLoadType(PRUint32 aLoadType);
  nsresult IsBeingDestroyed(PRBool *_retval);
  nsresult GetIsExecutingOnLoadHandler(PRBool *aIsExecutingOnLoadHandler);
  nsresult GetLayoutHistoryState(nsILayoutHistoryState  *aLayoutHistoryState);
  nsresult SetLayoutHistoryState(nsILayoutHistoryState  aLayoutHistoryState);
  nsresult GetShouldSaveLayoutState(PRBool *aShouldSaveLayoutState);
  nsresult GetSecurityUI(nsISecureBrowserUI  *aSecurityUI);
  nsresult SetSecurityUI(nsISecureBrowserUI  aSecurityUI);
  nsresult SuspendRefreshURIs();
  nsresult ResumeRefreshURIs();
  nsresult BeginRestore(nsIContentViewer viewer, PRBool top);
  nsresult FinishRestore();
  nsresult GetRestoringDocument(PRBool *aRestoringDocument);
  nsresult GetUseErrorPages(PRBool *aUseErrorPages);
  nsresult SetUseErrorPages(PRBool aUseErrorPages);
  nsresult GetPreviousTransIndex(PRInt32 *aPreviousTransIndex);
  nsresult GetLoadedTransIndex(PRInt32 *aLoadedTransIndex);
  nsresult HistoryPurged(PRInt32 numEntries);
}

/******************************************************************************

******************************************************************************/

const char[] NS_IDOCSHELL_1_8_IID_STR = "9f0c7461-b9a4-47f6-b88c-421dce1bce66";

const nsIID NS_IDOCSHELL_1_8_IID= 
    { 0x9f0c7461, 0xb9a4, 0x47f6, 
       [ 0xb8,0x8c,0x42,0x1d,0xce,0x1b,0xce,0x66 ] }; 

interface nsIDocShell_1_8 : nsIDocShell {

  static const char[] IID_STR = NS_IDOCSHELL_1_8_IID_STR;
  static const nsIID IID = NS_IDOCSHELL_1_8_IID;

extern(System):
  nsresult GetSessionStorageForURI(nsIURI uri, nsIDOMStorage *_retval);
  nsresult AddSessionStorage(nsACString * aDomain, nsIDOMStorage storage);
  nsresult GetCurrentDocumentChannel(nsIChannel  *aCurrentDocumentChannel);
}

/******************************************************************************

******************************************************************************/

const char[] NS_IDOCSHELL_1_9_IID_STR = "10ed386d-8598-408c-b571-e75ad18edeb0";

const nsIID NS_IDOCSHELL_1_9_IID = 
    {0x10ed386d, 0x8598, 0x408c, [ 0xb5, 0x71, 0xe7, 0x5a, 0xd1, 0x8e, 0xde, 0xb0 ] };

interface nsIDocShell_1_9 : nsIDocShell_1_8 {

  static const char[] IID_STR = NS_IDOCSHELL_1_9_IID_STR;
  static const nsIID IID = NS_IDOCSHELL_1_9_IID;

extern(System):
  nsresult GetSessionStorageForURI(nsIURI uri, nsIDOMStorage *_retval);
  nsresult AddSessionStorage(nsACString * aDomain, nsIDOMStorage storage);
  nsresult GetCurrentDocumentChannel(nsIChannel  *aCurrentDocumentChannel);
}
