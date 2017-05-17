module org.eclipse.swt.internal.ole.win32.EXDISP;
//+-------------------------------------------------------------------------
//
//  Microsoft Windows
//  Copyright 1995 - 1998 Microsoft Corporation. All Rights Reserved.
//
//--------------------------------------------------------------------------
//private import std.c.windows.windows;
//private import std.c.windows.com;
private import org.eclipse.swt.internal.ole.win32.OAIDL;
private import org.eclipse.swt.internal.ole.win32.OLEIDL;
private import org.eclipse.swt.internal.ole.win32.DOCOBJ;
private import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.win32.WINTYPES;

extern (Windows) {

        enum BrowserNavConstants {
            navOpenInNewWindow = 0x0001,
            navNoHistory = 0x0002,
            navNoReadFromCache = 0x0004,
            navNoWriteToCache = 0x0008,
            navAllowAutosearch = 0x0010,
            navBrowserBar = 0x0020,
        };
        enum RefreshConstants {                                         // must map to these in sdk\inc\docobj.h
            REFRESH_NORMAL     = 0,  //== OLECMDIDF_REFRESH_NORMAL
            REFRESH_IFEXPIRED  = 1,  //== OLECMDIDF_REFRESH_IFEXPIRED
            REFRESH_COMPLETELY = 3   //== OLECMDIDF_REFRESH_COMPLETELY
        };

interface IWebBrowser : IDispatch
{
        HRESULT GoBack();
        HRESULT GoForward();
        HRESULT GoHome();
        HRESULT GoSearch();

        HRESULT Navigate( BSTR URL,
                         VARIANT * Flags,
                         VARIANT * TargetFrameName,
                         VARIANT * PostData,
                         VARIANT * Headers);

        HRESULT Refresh();

        HRESULT Refresh2(VARIANT * Level);

        HRESULT Stop();

        HRESULT Application( IDispatch* ppDisp);

        HRESULT Parent( IDispatch* ppDisp);

        HRESULT Container( IDispatch* ppDisp);

        HRESULT Document( IDispatch* ppDisp);

        HRESULT TopLevelContainer( VARIANT_BOOL* pBool);

        HRESULT Type( BSTR* Type);

        // Window stuff...
        HRESULT Left( LONG *pl);
        HRESULT Put_Left( LONG Left);
        HRESULT Top( LONG *pl);
        HRESULT Put_Top( LONG Top);
        HRESULT Width(LONG *pl);
        HRESULT Put_Width(LONG Width);
        HRESULT Height(LONG *pl);
        HRESULT Put_Height(LONG Height);

        // WebBrowser stuff...
        HRESULT LocationName( BSTR *LocationName);

        HRESULT LocationURL( BSTR * LocationURL);

        HRESULT Busy( VARIANT_BOOL *pBool);
    }

/* //not sure how to process this
    dispinterface DWebBrowserEvents
    {
        properties:
        methods:
        [id(DISPID_BEFORENAVIGATE), helpstring("Fired when a new hyperlink is being navigated to."), helpcontext(0x0000)]
        void BeforeNavigate([in] BSTR URL, long Flags, BSTR TargetFrameName, VARIANT * PostData, BSTR Headers, [in, out]VARIANT_BOOL * Cancel);

        [id(DISPID_NAVIGATECOMPLETE), helpstring("Fired when the document being navigated to becomes visible and enters the navigation stack."), helpcontext(0x0000)]
        void NavigateComplete([in] BSTR URL );

        [id(DISPID_STATUSTEXTCHANGE), helpstring("Statusbar text changed."), helpcontext(0x0000)]
        void StatusTextChange([in]BSTR Text);

        [id(DISPID_PROGRESSCHANGE), helpstring("Fired when download progress is updated."), helpcontext(0x0000)]
        void ProgressChange([in] long Progress, [in] long ProgressMax);

        [id(DISPID_DOWNLOADCOMPLETE), helpstring("Download of page complete."), helpcontext(0x0000)]
        void DownloadComplete();

        [id(DISPID_COMMANDSTATECHANGE), helpstring("The enabled state of a command changed"), helpcontext(0x0000)]
        void CommandStateChange([in] long Command, [in] VARIANT_BOOL Enable);

        [id(DISPID_DOWNLOADBEGIN), helpstring("Download of a page started."), helpcontext(0x000)]
        void DownloadBegin();

        [id(DISPID_NEWWINDOW), helpstring("Fired when a new window should be created."), helpcontext(0x0000)]
        void NewWindow([in] BSTR URL, [in] long Flags, [in] BSTR TargetFrameName, [in] VARIANT * PostData, [in] BSTR Headers, [in,out] VARIANT_BOOL * Processed);

        [id(DISPID_TITLECHANGE), helpstring("Document title changed."), helpcontext(0x0000)]
        void TitleChange([in]BSTR Text);

        [id(DISPID_FRAMEBEFORENAVIGATE), helpstring("Fired when a new hyperlink is being navigated to in a frame."), helpcontext(0x0000)]
        void FrameBeforeNavigate([in] BSTR URL, long Flags, BSTR TargetFrameName, VARIANT * PostData, BSTR Headers, [in, out]VARIANT_BOOL * Cancel);

        [id(DISPID_FRAMENAVIGATECOMPLETE), helpstring("Fired when a new hyperlink is being navigated to in a frame."), helpcontext(0x0000)]
        void FrameNavigateComplete([in] BSTR URL );

        [id(DISPID_FRAMENEWWINDOW), helpstring("Fired when a new window should be created."), helpcontext(0x0000)]
        void FrameNewWindow([in] BSTR URL, [in] long Flags, [in] BSTR TargetFrameName, [in] VARIANT * PostData, [in] BSTR Headers, [in,out] VARIANT_BOOL * Processed);

        // The following are IWebBrowserApp specific:
        //
        [id(DISPID_QUIT), helpstring("Fired when application is quiting."), helpcontext(0x0000)]
        void Quit([in, out] VARIANT_BOOL * Cancel);

        [id(DISPID_WINDOWMOVE), helpstring("Fired when window has been moved."), helpcontext(0x0000)]
        void WindowMove();

        [id(DISPID_WINDOWRESIZE), helpstring("Fired when window has been sized."), helpcontext(0x0000)]
        void WindowResize();

        [id(DISPID_WINDOWACTIVATE), helpstring("Fired when window has been activated."), helpcontext(0x0000)]
        void WindowActivate();

        [id(DISPID_PROPERTYCHANGE), helpstring("Fired when the PutProperty method has been called."), helpcontext(0x0000)]
        void PropertyChange([in] BSTR Property);
    }
   */

    enum CommandStateChangeConstants : uint {
        CSC_UPDATECOMMANDS  = 0xFFFFFFFF,
        CSC_NAVIGATEFORWARD = 0x00000001,
        CSC_NAVIGATEBACK    = 0x00000002,
    }

    interface IWebBrowserApp : IWebBrowser
    {
        HRESULT Quit();

        HRESULT ClientToWindow( int* pcx,  int* pcy);

        HRESULT PutProperty( BSTR Property, VARIANT vtValue);
        HRESULT GetProperty( BSTR Property, VARIANT *pvtValue);

        HRESULT Name( BSTR* Name);

        HRESULT HWND(LONG *pHWND);

        HRESULT FullName( BSTR* FullName);

        HRESULT Path( BSTR* Path);

        HRESULT Visible( VARIANT_BOOL* pBool);
        HRESULT Visible( VARIANT_BOOL Value);

        HRESULT StatusBar( VARIANT_BOOL* pBool);
        HRESULT StatusBar( VARIANT_BOOL Value);

        HRESULT StatusText( BSTR *StatusText);
        HRESULT StatusText( BSTR StatusText);

        HRESULT ToolBar( int * Value);
        HRESULT ToolBar( int Value);

        HRESULT MenuBar( VARIANT_BOOL * Value);
        HRESULT MenuBar( VARIANT_BOOL Value);

        HRESULT FullScreen( VARIANT_BOOL * pbFullScreen);
        HRESULT FullScreen( VARIANT_BOOL bFullScreen);
    }

    interface IWebBrowser2 : IWebBrowserApp
    {
        HRESULT Navigate2( VARIANT * URL,
                          VARIANT * Flags,
                          VARIANT * TargetFrameName,
                          VARIANT * PostData,
                          VARIANT * Headers);


        HRESULT QueryStatusWB( OLECMDID cmdID,  OLECMDF * pcmdf);
        HRESULT ExecWB( OLECMDID cmdID,  OLECMDEXECOPT cmdexecopt, VARIANT * pvaIn, VARIANT * pvaOut);
        HRESULT ShowBrowserBar( VARIANT * pvaClsid,
                                VARIANT * pvarShow,
                                VARIANT * pvarSize );

        HRESULT ReadyState(READYSTATE * plReadyState);

        HRESULT Offline(VARIANT_BOOL * pbOffline);
        HRESULT Offline( VARIANT_BOOL bOffline);

        HRESULT Silent(VARIANT_BOOL * pbSilent);
        HRESULT Silent(VARIANT_BOOL bSilent);

        HRESULT RegisterAsBrowser(VARIANT_BOOL * pbRegister);
        HRESULT RegisterAsBrowser(VARIANT_BOOL bRegister);

        HRESULT RegisterAsDropTarget(VARIANT_BOOL * pbRegister);
        HRESULT RegisterAsDropTarget(VARIANT_BOOL bRegister);

        HRESULT TheaterMode(VARIANT_BOOL * pbRegister);
        HRESULT TheaterMode(VARIANT_BOOL bRegister);

        HRESULT AddressBar(VARIANT_BOOL * Value);
        HRESULT AddressBar(VARIANT_BOOL Value);

        HRESULT Resizable(VARIANT_BOOL * Value);
        HRESULT Resizable(VARIANT_BOOL Value);
    }

	 /*
    dispinterface DWebBrowserEvents2
    {
        properties:
        methods:
        [id(DISPID_STATUSTEXTCHANGE), helpstring("Statusbar text changed."), helpcontext(0x0000)]
        void StatusTextChange([in]BSTR Text);

        [id(DISPID_PROGRESSCHANGE), helpstring("Fired when download progress is updated."), helpcontext(0x0000)]
        void ProgressChange([in] long Progress, [in] long ProgressMax);

        [id(DISPID_COMMANDSTATECHANGE), helpstring("The enabled state of a command changed."), helpcontext(0x0000)]
        void CommandStateChange([in] long Command, [in] VARIANT_BOOL Enable);

        [id(DISPID_DOWNLOADBEGIN), helpstring("Download of a page started."), helpcontext(0x000)]
        void DownloadBegin();

        [id(DISPID_DOWNLOADCOMPLETE), helpstring("Download of page complete."), helpcontext(0x0000)]
        void DownloadComplete();

        [id(DISPID_TITLECHANGE), helpstring("Document title changed."), helpcontext(0x0000)]
        void TitleChange([in] BSTR Text);

        [id(DISPID_PROPERTYCHANGE), helpstring("Fired when the PutProperty method has been called."), helpcontext(0x0000)]
        void PropertyChange([in] BSTR szProperty);

        // New events for IE40:
        //
        [id(DISPID_BEFORENAVIGATE2), helpstring("Fired before navigate occurs in the given WebBrowser (window or frameset element). The processing of this navigation may be modified."), helpcontext(0x0000)]
        void BeforeNavigate2([in] IDispatch* pDisp,
                             [in] VARIANT * URL, [in] VARIANT * Flags, [in] VARIANT * TargetFrameName, [in] VARIANT * PostData, [in] VARIANT * Headers,
                             [in,out] VARIANT_BOOL * Cancel);

        [id(DISPID_NEWWINDOW2), helpstring("A new, hidden, non-navigated WebBrowser window is needed."), helpcontext(0x0000)]
        void NewWindow2([in, out] IDispatch** ppDisp, [in, out] VARIANT_BOOL * Cancel);

        [id(DISPID_NAVIGATECOMPLETE2), helpstring("Fired when the document being navigated to becomes visible and enters the navigation stack."), helpcontext(0x0000)]
        void NavigateComplete2([in] IDispatch* pDisp, [in] VARIANT * URL );

        [id(DISPID_DOCUMENTCOMPLETE), helpstring("Fired when the document being navigated to reaches ReadyState_Complete."), helpcontext(0x0000)]
        void DocumentComplete([in] IDispatch* pDisp, [in] VARIANT * URL );

        [id(DISPID_ONQUIT), helpstring("Fired when application is quiting."), helpcontext(0x0000)]
        void OnQuit();

        [id(DISPID_ONVISIBLE), helpstring("Fired when the window should be shown/hidden"), helpcontext(0x0000)]
        void OnVisible([in] VARIANT_BOOL Visible);

        [id(DISPID_ONTOOLBAR), helpstring("Fired when the toolbar  should be shown/hidden"), helpcontext(0x0000)]
        void OnToolBar([in] VARIANT_BOOL ToolBar);

        [id(DISPID_ONMENUBAR), helpstring("Fired when the menubar should be shown/hidden"), helpcontext(0x0000)]
        void OnMenuBar([in] VARIANT_BOOL MenuBar);

        [id(DISPID_ONSTATUSBAR), helpstring("Fired when the statusbar should be shown/hidden"), helpcontext(0x0000)]
        void OnStatusBar([in] VARIANT_BOOL StatusBar);

        [id(DISPID_ONFULLSCREEN), helpstring("Fired when fullscreen mode should be on/off"), helpcontext(0x0000)]
        void OnFullScreen([in] VARIANT_BOOL FullScreen);

        [id(DISPID_ONTHEATERMODE), helpstring("Fired when theater mode should be on/off"), helpcontext(0x0000)]
        void OnTheaterMode([in] VARIANT_BOOL TheaterMode);
    }
    */

    /*

    [
        uuid(EAB22AC3-30C1-11CF-A7EB-0000C05BAE0B), // v.1 clsid CLSID_WebBrowser_V1
        control,
        helpstring("WebBrowser Control")
    ]
    coclass WebBrowser_V1
    {
                          interface     IWebBrowser2;
        [default]         interface     IWebBrowser;
        [source]          dispinterface DWebBrowserEvents2;
        [default, source] dispinterface DWebBrowserEvents;
    }

    [
        uuid(8856F961-340A-11D0-A96B-00C04FD705A2), // v.2 clsid CLSID_WebBrowser
        control,
        helpstring("WebBrowser Control")
    ]
    coclass WebBrowser
    {
        [default]         interface     IWebBrowser2;
                          interface     IWebBrowser;
        [default, source] dispinterface DWebBrowserEvents2;
        [source]          dispinterface DWebBrowserEvents;
    }

    [
        uuid(0002DF01-0000-0000-C000-000000000046), // CLSID_InternetExplorer
        helpstring("Internet Explorer Application."),
    ]
    coclass InternetExplorer
    {
        [default]         interface     IWebBrowser2;
                          interface     IWebBrowserApp;
        [default, source] dispinterface DWebBrowserEvents2;
        [source]          dispinterface DWebBrowserEvents;
    }

	 */


    interface IFolderViewOC : IDispatch
    {
        HRESULT SetFolderView(IDispatch pdisp);
    }

    interface DShellFolderViewEvents
    {
        void SelectionChanged();
    }

/*    [
        uuid(9BA05971-F6A8-11CF-A442-00A0C90A8F39), // CLSID_ShellFolderViewOC
        helpstring("Shell Folder View Events Router."),
        hidden
    ]
    coclass ShellFolderViewOC
    {
        [default]         interface     IFolderViewOC;
        [default, source] dispinterface DShellFolderViewEvents;
    }*/
    enum ShellWindowTypeConstants {
        SWC_EXPLORER    = 0x0,
        SWC_BROWSER     = 0x00000001,
        SWC_3RDPARTY    = 0x00000002,
        SWC_CALLBACK    = 0x00000004,
    }

    enum ShellWindowFindWindowOptions {
        SWFO_NEEDDISPATCH   = 0x00000001,
        SWFO_INCLUDEPENDING = 0x00000002,
        SWFO_COOKIEPASSED   = 0x00000004,
    }

    interface DShellWindowsEvents
    {
        void WindowRegistered(LONG lCookie);

        void WindowRevoked(LONG lCookie);
    }

    interface IShellWindows : IDispatch
    {
        //Properties
        HRESULT Count(LONG *Count);

        HRESULT Item(VARIANT index, IDispatch *Folder);

        HRESULT _NewEnum(IUnknown *ppunk);

        // Some private hidden members to allow shell windows to add and
        // remove themself from the list.  We mark them hidden to keep
        // random VB apps from trying to Register...
        HRESULT Register( IDispatch pid,
                         LONG hwnd,
                         int swClass,
                         LONG *plCookie);

        HRESULT RegisterPending(LONG lThreadId,
                         VARIANT* pvarloc,     // will hold pidl that is being opened.
                         VARIANT* pvarlocRoot, // Optional root pidl
                         int swClass,
                         LONG *plCookie);

        HRESULT Revoke(LONG lCookie);
        // As an optimization, each window notifies the new location
        // only when
        //  (1) it's being deactivated
        //  (2) getFullName is called (we overload it to force update)
        HRESULT OnNavigate(LONG lCookie, VARIANT* pvarLoc);
        HRESULT OnActivated(LONG lCookie, VARIANT_BOOL fActive);
        HRESULT FindWindow(VARIANT* pvarLoc,
                           VARIANT* pvarLocRoot,
                           int swClass,
                           LONG * phwnd,
                            int swfwOptions,
                           IDispatch* ppdispOut);
        HRESULT OnCreated(LONG lCookie,IUnknown punk);

        HRESULT ProcessAttachDetach(VARIANT_BOOL fAttach);
    }

	 /*
    [
        uuid(9BA05972-F6A8-11CF-A442-00A0C90A8F39),     // CLSID_ShellWindows
        helpstring("ShellDispatch Load in Shell Context")
    ]
    coclass ShellWindows
    {
        [default] interface IShellWindows;
        [default, source] dispinterface DShellWindowsEvents;
    }
    */

    /*

    [
        uuid(88A05C00-F000-11CE-8350-444553540000), // IID_IShellLinkDual
        helpstring("Definition of Shell Link IDispatch interface"),
        oleautomation,
        dual,
        odl,
        hidden,
    ]
    interface IShellLinkDual : IDispatch
    {
        [propget, helpstring("Get the path of the link")]
        HRESULT Path([out, retval] BSTR *pbs);

        [propput, helpstring("Set the path of the link")]
        HRESULT Path([in] BSTR bs);

        [propget, helpstring("Get the description for the link")]
        HRESULT Description([out, retval] BSTR *pbs);

        [propput, helpstring("Set the description for the link")]
        HRESULT Description([in] BSTR bs);

        [propget, helpstring("Get the working directory for the link")]
        HRESULT WorkingDirectory([out, retval] BSTR *pbs);

        [propput, helpstring("Set the working directory for the link")]
        HRESULT WorkingDirectory([in] BSTR bs);

        [propget, helpstring("Get the arguments for the link")]
        HRESULT Arguments([out, retval] BSTR *pbs);

        [propput, helpstring("Set the arguments for the link")]
        HRESULT Arguments([in] BSTR bs);


        [propget, helpstring("Get the Hotkey for the link")]
        HRESULT Hotkey([out, retval] int *piHK);

        [propput, helpstring("Set the Hotkey for the link")]
        HRESULT Hotkey([in] int iHK);

        [propget, helpstring("Get the Show Command for the link")]
        HRESULT ShowCommand([out, retval] int *piShowCommand);

        [propput, helpstring("Set the Show Command for the link")]
        HRESULT ShowCommand([in] int iShowCommand);

        // STDMETHOD(SetRelativePath)(THIS_ LPCSTR pszPathRel, DWORD dwReserved) PURE;
        //Methods
        [helpstring("Tell the link to resolve itself")]
        HRESULT Resolve([in] int fFlags);

        [helpstring("Get the IconLocation for the link")]
        HRESULT GetIconLocation([out] BSTR *pbs, [out,retval] int *piIcon);

        [helpstring("Set the IconLocation for the link")]
        HRESULT SetIconLocation([in] BSTR bs, [in] int iIcon);

        [helpstring("Tell the link to save the changes")]
        HRESULT Save ([in, optional] VARIANT vWhere);
    }

    [
        uuid(11219420-1768-11d1-95BE-00609797EA4F), // CLSID_ShellLinkObject
        helpstring("Shell Link object")
    ]
    coclass ShellLinkObject // funny name so we don't conflict with CLSID_ShellLink
    {
        [default] interface IShellLinkDual;
    }

    [
        uuid(08EC3E00-50B0-11CF-960C-0080C7F4EE85), // IID_FolderItemVerb
        helpstring("Definition of interface FolderItemVerb"),
        oleautomation,
        dual,
        odl,
    ]
    interface FolderItemVerb : IDispatch
    {
        [propget, helpstring("Get Application object")]
        HRESULT Application ([out, retval] IDispatch **ppid);

        [propget, helpstring("Get Parent object")]
        HRESULT Parent([out, retval] IDispatch **ppid);

        [id(0), propget, helpstring("Get display name for item")]
        HRESULT Name([out, retval] BSTR *pbs);

        [helpstring("Execute the verb")]
        HRESULT DoIt();
    }

    [
        uuid(1F8352C0-50B0-11CF-960C-0080C7F4EE85), // IID_FolderItemVerbs
        helpstring("Definition of interface FolderItemVerbs"),
        oleautomation,
        dual,
        odl,
    ]
    interface FolderItemVerbs : IDispatch
    {
        //Properties
        [propget, helpstring("Get count of open folder windows")]
        HRESULT Count([out, retval] long *plCount);

        [propget, helpstring("Get Application object")]
        HRESULT Application ([out, retval] IDispatch **ppid);

        [propget, helpstring("Get Parent object")]
        HRESULT Parent([out, retval] IDispatch **ppid);

        //Methods
        //Standard Methods
        [helpstring("Return the specified verb")]
        HRESULT Item([in,optional] VARIANT index, [out, retval]FolderItemVerb **ppid);

        [id(-4), helpstring("Enumerates the figures")]
        HRESULT _NewEnum([out, retval] IUnknown **ppunk);
    }

    interface Folder;   // forward reference

    [
        uuid(FAC32C80-CBE4-11CE-8350-444553540000), // IID_FolderItem
        helpstring("Definition of interface FolderItem"),
        oleautomation,
        dual,
        odl,
    ]
    interface FolderItem : IDispatch
    {
        [propget, helpstring("Get Application object")]
        HRESULT Application ([out, retval] IDispatch **ppid);

        [propget, helpstring("Get Parent object")]
        HRESULT Parent([out, retval] IDispatch **ppid);

        [id(0), propget, helpstring("Get display name for item")]
        HRESULT Name([out, retval] BSTR *pbs);

        [id(0), propput, helpstring("Set the name for the item")]
        HRESULT Name([in] BSTR bs);

        [propget, helpstring("Get the pathname to the item")]
        HRESULT Path([out, retval]BSTR *pbs);

        [propget, helpstring("If item is link return link object")]
        HRESULT GetLink([out, retval] IDispatch **ppid);

        [propget, helpstring("If item is a folder return folder object")]
        HRESULT GetFolder([out, retval] IDispatch **ppid);

        [propget, helpstring("Is the item a link?")]
        HRESULT IsLink([out, retval] VARIANT_BOOL *pb);

        [propget, helpstring("Is the item a Folder?")]
        HRESULT IsFolder([out, retval] VARIANT_BOOL *pb);

        [propget, helpstring("Is the item a file system object?")]
        HRESULT IsFileSystem([out, retval] VARIANT_BOOL *pb);

        [propget, helpstring("Is the item browsable?")]
        HRESULT IsBrowsable([out, retval] VARIANT_BOOL *pb);

        [propget, helpstring("Modification Date?")]
        HRESULT ModifyDate([out, retval] DATE *pdt);

        [propput, helpstring("Modification Date?")]
        HRESULT ModifyDate([in] DATE dt);

        [propget, helpstring("Size")]
        HRESULT Size([out, retval] LONG *pul);

        [propget, helpstring("Type")]
        HRESULT Type([out, retval] BSTR *pbs);

        [helpstring("Get the list of verbs for the object")]
        HRESULT Verbs([out, retval] FolderItemVerbs **ppfic);

        [helpstring("Execute a command on the item")]
        HRESULT InvokeVerb([in,optional] VARIANT vVerb);
    }

    [
        uuid(744129E0-CBE5-11CE-8350-444553540000), // IID_FolderItems
        helpstring("Definition of interface FolderItems"),
        oleautomation,
        dual,
        odl,
    ]
    interface FolderItems : IDispatch
    {
        //Properties
        [propget, helpstring("Get count of items in the folder")]
        HRESULT Count([out, retval] long *plCount);

        [propget, helpstring("Get Application object")]
        HRESULT Application ([out, retval] IDispatch **ppid);

        [propget, helpstring("Get Parent object")]
        HRESULT Parent([out, retval] IDispatch **ppid);

        //Methods
        //Standard Methods
        [helpstring("Return the figure for the given index")]
        HRESULT Item([in,optional] VARIANT index, [out, retval]FolderItem **ppid);

        [id(-4), helpstring("Enumerates the figures")]
        HRESULT _NewEnum([out, retval] IUnknown **ppunk);
    }

    [
        uuid(BBCBDE60-C3FF-11CE-8350-444553540000), // IID_Folder
        helpstring("Definition of interface Folder"),
        oleautomation,
        dual,
        odl,
    ]
    interface Folder : IDispatch
    {
        //Properties
        [id(0), propget, helpstring("Get the display name for the window")]
        HRESULT Title([out, retval] BSTR *pbs);

        [propget, helpstring("Get Application object")]
        HRESULT Application ([out, retval] IDispatch **ppid);

        [propget, helpstring("Get Parent object")]
        HRESULT Parent([out, retval] IDispatch **ppid);

        [propget, helpstring("Get Parent object")]
        HRESULT ParentFolder([out, retval] Folder **ppsf);

        //Methods
        [helpstring("The collection of Items in folder")]
        HRESULT Items([out, retval] FolderItems **ppid);

        [helpstring("Parse the name to get an item.")]
        HRESULT ParseName([in] BSTR bName, [out, retval] FolderItem **ppid);

        [helpstring("Create a new sub folder in this folder.")]
        HRESULT NewFolder([in] BSTR bName, [in, optional] VARIANT vOptions);

        [helpstring("Move Items to this folder.")]
        HRESULT MoveHere([in] VARIANT vItem, [in, optional] VARIANT vOptions);

        [helpstring("Copy Items to this folder.")]
        HRESULT CopyHere([in] VARIANT vItem, [in, optional] VARIANT vOptions);

        [helpstring("Get the details about an item.")]
        HRESULT GetDetailsOf([in] VARIANT vItem, [in] int iColumn, [out, retval]BSTR *pbs);
    }

    [
        uuid(E7A1AF80-4D96-11CF-960C-0080C7F4EE85), // IID_IShellFolderViewDual
        helpstring("definition of interface IShellFolderViewDual"),
        oleautomation,
        hidden,
        dual,
        odl,
    ]
    interface IShellFolderViewDual : IDispatch
    {
        [propget, helpstring("Get Application object")]
        HRESULT Application([out, retval] IDispatch **ppid);

        [propget, helpstring("Get Parent object")]
        HRESULT Parent([out, retval] IDispatch **ppid);

        [propget, helpstring("Get the folder being viewed")]
        HRESULT Folder([out, retval] Folder **ppid);

        [helpstring("The collection of Selected Items in folder")]
        HRESULT SelectedItems([out, retval] FolderItems **ppid);

        [propget, helpstring("The currently focused item in the folder")]
        HRESULT FocusedItem([out, retval] FolderItem **ppid);

        [helpstring("Select the item")]
        HRESULT SelectItem([in]VARIANT *pvfi, [in] int dwFlags);

        [helpstring("Show items menu and return command selected")]
        HRESULT PopupItemMenu([in]FolderItem *pfi, [in, optional]VARIANT vx, [in, optional]VARIANT vy, [out, retval] BSTR *pbs);

        [propget, helpstring("Returns the scripting automation model."), helpcontext(0x0000)]
        HRESULT Script([out,retval] IDispatch** ppDisp);

        [propget, helpstring("Returns the view options for showing a folder."), helpcontext(0x0000)]
        HRESULT ViewOptions([out,retval] long * plViewOptions);
    }

    [
        uuid(62112AA1-EBE4-11cf-A5FB-0020AFE7292D),  // CLSID_ShellFolderView
        helpstring("Shell Folder View Object")
    ]
    coclass ShellFolderView
    {
        [default] interface IShellFolderViewDual;
        [source,default] dispinterface DShellFolderViewEvents;
    }

    typedef
    [
        uuid(742A99A0-C77E-11D0-A32C-00A0C91EEDBA),
        helpstring("Constants for ViewOptions")
    ]
    enum ShellFolderViewOptions {
        [helpstring("Show All Objects")]                        SFVVO_SHOWALLOBJECTS = 0x00000001,
        [helpstring("Show File Extensions")]                    SFVVO_SHOWEXTENSIONS = 0x00000002,
        [helpstring("Color encode Compressed files")]           SFVVO_SHOWCOMPCOLOR = 0x00000008,
        [helpstring("Show System Files")]                       SFVVO_SHOWSYSFILES = 0x00000020,
        [helpstring("Use Windows 95 UI settings")]              SFVVO_WIN95CLASSIC = 0x00000040,
        [helpstring("User needs to double click in web View")]  SFVVO_DOUBLECLICKINWEBVIEW = 0x00000080,
        [helpstring("Is Desktop HTML enabled")]                 SFVVO_DESKTOPHTML = 0x00000200,
    } ShellFolderViewOptions;

    [
        uuid(D8F015C0-C278-11CE-A49E-444553540000), // IID_IShellDispatch
        helpstring("Definition of interface IShellDispatch"),
        oleautomation,
        hidden,
        dual,
        odl,
    ]
    interface IShellDispatch : IDispatch
    {
        [propget, helpstring("Get Application object")]
        HRESULT Application ([out, retval] IDispatch **ppid);

        [propget, helpstring("Get Parent object")]
        HRESULT Parent([out, retval] IDispatch **ppid);

        //=========================================================
        // Name Space methods and properties

        [helpstring("Enum the contents of a folder")]
        HRESULT NameSpace([in] VARIANT vDir, [out, retval] Folder **ppsdf);

        [helpstring("Browse the name space for a Folder")]
        HRESULT BrowseForFolder([in] long Hwnd,
            [in] BSTR Title,
            [in] long Options,
            [in,optional] VARIANT RootFolder,
            [out, retval] FOLDER **ppsdf);

        [helpstring("The collection of open folder windows")]
        HRESULT Windows([out, retval] IDispatch **ppid);

        [helpstring("Open a folder")]
        HRESULT Open([in] VARIANT vDir);

        [helpstring("Explore a folder")]
        HRESULT Explore([in] VARIANT vDir);

        [helpstring("Minimize all windows")]
        HRESULT MinimizeAll(void);

        [helpstring("Undo Minimize All")]
        HRESULT UndoMinimizeALL(void);

        [helpstring("Bring up the file run")]
        HRESULT FileRun(void);

        [helpstring("Cascade Windows")]
        HRESULT CascadeWindows(void);

        [helpstring("Tile windows vertically")]
        HRESULT TileVertically(void);

        [helpstring("Tile windows horizontally")]
        HRESULT TileHorizontally(void);

        [helpstring("Exit Windows")]
        HRESULT ShutdownWindows(void);

        [helpstring("Suspend the pc")]
        HRESULT Suspend(void);

        [helpstring("Eject the pc")]
        HRESULT EjectPC(void);

        [helpstring("Bring up the Set time dialog")]
        HRESULT SetTime(void);

        [helpstring("Handle Tray properties")]
        HRESULT TrayProperties(void);

        [helpstring("Display shell help")]
        HRESULT Help(void);

        [helpstring("Find Files")]
        HRESULT FindFiles(void);

        [helpstring("Find a computer")]
        HRESULT FindComputer(void);

        [helpstring("Refresh the menu")]
        HRESULT RefreshMenu(void);

        [helpstring("Run a controlpanelItem")]
        HRESULT ControlPanelItem([in] BSTR szDir);
    }

    [
        uuid(13709620-C279-11CE-A49E-444553540000), // CLSID_Shell
        helpstring("Shell Object Type Information")
    ]
    coclass Shell
    {
        [default] interface IShellDispatch;
    }

    [
        uuid(0A89A860-D7B1-11CE-8350-444553540000), // CLSID_ShellDispatchInproc
        helpstring("ShellDispatch Load in Shell Context"),
        hidden
    ]
    coclass ShellDispatchInproc
    {
        interface IUnknown;
    }

    [
        uuid(1820FED0-473E-11D0-A96C-00C04FD705A2),     // CLSID_WebViewFolderContents
        hidden
    ]
    coclass WebViewFolderContents
    {
        [default] interface IShellFolderViewDual;
        [source,default] dispinterface DShellFolderViewEvents;
    }

    typedef
    [
        uuid(CA31EA20-48D0-11CF-8350-444553540000),
        helpstring("Constants for Special Folders for open/Explore")
    ]
    enum ShellSpecialFolderConstants    {
        [helpstring("Special Folder DESKTOP")]      ssfDESKTOP = 0x0000,
        [helpstring("Special Folder PROGRAMS")]     ssfPROGRAMS = 0x0002,
        [helpstring("Special Folder CONTROLS")]     ssfCONTROLS = 0x0003,
        [helpstring("Special Folder PRINTERS")]     ssfPRINTERS = 0x0004,
        [helpstring("Special Folder PERSONAL")]     ssfPERSONAL = 0x0005,
        [helpstring("Special Folder FAVORITES")]    ssfFAVORITES = 0x0006,
        [helpstring("Special Folder STARTUP")]      ssfSTARTUP = 0x0007,
        [helpstring("Special Folder RECENT")]       ssfRECENT = 0x0008,
        [helpstring("Special Folder SENDTO")]       ssfSENDTO = 0x0009,
        [helpstring("Special Folder BITBUCKET")]    ssfBITBUCKET = 0x000a,
        [helpstring("Special Folder STARTMENU")]    ssfSTARTMENU = 0x000b,
        [helpstring("Special Folder DESKTOPDIRECTORY")]    ssfDESKTOPDIRECTORY = 0x0010,
        [helpstring("Special Folder DRIVES")]       ssfDRIVES = 0x0011,
        [helpstring("Special Folder NETWORK")]      ssfNETWORK = 0x0012,
        [helpstring("Special Folder NETHOOD")]      ssfNETHOOD = 0x0013,
        [helpstring("Special Folder FONTS")]        ssfFONTS = 0x0014,
        [helpstring("Special Folder TEMPLATES")]    ssfTEMPLATES = 0x0015,
    } ShellSpecialFolderConstants;

    [
        uuid(729FE2F8-1EA8-11d1-8F85-00C04FC2FBE1),     // IID_IShellUIHelper
        helpstring("Shell UI Helper Control Interface"),
        oleautomation, dual
    ]
    interface IShellUIHelper : IDispatch
    {
        [hidden, id(DISPID_RESETFIRSTBOOTMODE)] HRESULT ResetFirstBootMode();
        [hidden, id(DISPID_RESETSAFEMODE)] HRESULT ResetSafeMode();
        [hidden, id(DISPID_REFRESHOFFLINEDESKTOP)] HRESULT RefreshOfflineDesktop();
        [id(DISPID_ADDFAVORITE)] HRESULT AddFavorite([in] BSTR URL, [optional, in] VARIANT *Title);
        [id(DISPID_ADDCHANNEL)] HRESULT AddChannel([in] BSTR URL);
        [id(DISPID_ADDDESKTOPCOMPONENT)] HRESULT AddDesktopComponent([in] BSTR URL, [in] BSTR Type,
            [optional, in] VARIANT *Left,
            [optional, in] VARIANT *Top,
            [optional, in] VARIANT *Width,
            [optional, in] VARIANT *Height);
        [id(DISPID_ISSUBSCRIBED)] HRESULT IsSubscribed([in] BSTR URL, [out,retval] VARIANT_BOOL* pBool);
    }
    [
        uuid(64AB4BB7-111E-11d1-8F79-00C04FC2FBE1)  // CLSID_ShellUIHelper
    ]
    coclass ShellUIHelper
    {
        [default] interface IShellUIHelper;
    }
*/
}  // extern (Windows)

