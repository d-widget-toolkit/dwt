module org.eclipse.swt.internal.ole.win32.MSHTMHST;
//+------------------------------------------------------------------------
//
//  Microsoft Forms
//  Copyright 1996 - 1998 Microsoft Corporation.
//
//  File:       mshtmhst.idl
//
//  Contents:   MSHTML advanced host interfaces
//
//-------------------------------------------------------------------------

//private import std.c.windows.windows;
//private import std.c.windows.com;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.internal.ole.win32.COMTYPES;

//import win32.oleextra;
private import org.eclipse.swt.internal.ole.win32.extras;
private import org.eclipse.swt.internal.ole.win32.OAIDL;
private import org.eclipse.swt.internal.ole.win32.OBJIDL;
private import org.eclipse.swt.internal.ole.win32.OLEIDL;
private import org.eclipse.swt.internal.ole.win32.DOCOBJ;

extern( Windows ) {
/*
cpp_quote("#define CONTEXT_MENU_DEFAULT        0")
cpp_quote("#define CONTEXT_MENU_IMAGE          1")
cpp_quote("#define CONTEXT_MENU_CONTROL        2")
cpp_quote("#define CONTEXT_MENU_TABLE          3")
cpp_quote("// in browse mode")
cpp_quote("#define CONTEXT_MENU_TEXTSELECT     4")
cpp_quote("#define CONTEXT_MENU_ANCHOR         5")
cpp_quote("#define CONTEXT_MENU_UNKNOWN        6")
cpp_quote("//;begin_internal")
cpp_quote("// These 2 are mapped to IMAGE for the public")
cpp_quote("#define CONTEXT_MENU_IMGDYNSRC      7")
cpp_quote("#define CONTEXT_MENU_IMGART         8")
cpp_quote("#define CONTEXT_MENU_DEBUG          9")
cpp_quote("//;end_internal")

cpp_quote("#define MENUEXT_SHOWDIALOG           0x1")

cpp_quote("#define DOCHOSTUIFLAG_BROWSER       DOCHOSTUIFLAG_DISABLE_HELP_MENU | DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE ")

import "ocidl.idl";
import "objidl.idl";
import "oleidl.idl";
import "oaidl.idl";
import "docobj.idl";
import "mshtml.idl";

cpp_quote("EXTERN_C const GUID CGID_MSHTML;")
cpp_quote("#define CMDSETID_Forms3 CGID_MSHTML")
cpp_quote("#define SZ_HTML_CLIENTSITE_OBJECTPARAM L\"{d4db6850-5385-11d0-89e9-00a0c90a90ac}\"")
#pragma midl_echo("typedef HRESULT STDAPICALLTYPE SHOWHTMLDIALOGFN (HWND hwndParent, IMoniker *pmk, VARIANT *pvarArgIn, TCHAR* pchOptions, VARIANT *pvArgOut);")
#pragma midl_echo("STDAPI ShowHTMLDialog(                   ")
#pragma midl_echo("    HWND        hwndParent,              ")
#pragma midl_echo("    IMoniker *  pMk,                     ")
#pragma midl_echo("    VARIANT *   pvarArgIn,               ")
#pragma midl_echo("    TCHAR *     pchOptions,              ")
#pragma midl_echo("    VARIANT *   pvarArgOut               ")
#pragma midl_echo("    );                                   ")
*/

//-------------------------------------------------------------------------
//  IDocHostUIHandler
//
//-------------------------------------------------------------------------

enum DOCHOSTUITYPE {
        DOCHOSTUITYPE_BROWSE    = 0,
        DOCHOSTUITYPE_AUTHOR    = 1,
        BROWSE    = 0,
        AUTHOR    = 1,
}

enum DOCHOSTUIDBLCLK {
        DOCHOSTUIDBLCLK_DEFAULT         = 0,
        DOCHOSTUIDBLCLK_SHOWPROPERTIES  = 1,
        DOCHOSTUIDBLCLK_SHOWCODE        = 2,

        DEFAULT         = 0,
        SHOWPROPERTIES  = 1,
        SHOWCODE        = 2,
}

enum DOCHOSTUIFLAG {
        DOCHOSTUIFLAG_DIALOG            = 1,
        DOCHOSTUIFLAG_DISABLE_HELP_MENU = 2,
        DOCHOSTUIFLAG_NO3DBORDER        = 4,
        DOCHOSTUIFLAG_SCROLL_NO         = 8,
        DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE = 16,
        DOCHOSTUIFLAG_OPENNEWWIN        = 32,
        DOCHOSTUIFLAG_DISABLE_OFFSCREEN = 64,
        DOCHOSTUIFLAG_FLAT_SCROLLBAR = 128,
        DOCHOSTUIFLAG_DIV_BLOCKDEFAULT = 256,
        DOCHOSTUIFLAG_ACTIVATE_CLIENTHIT_ONLY = 512,
        DOCHOSTUIFLAG_DISABLE_COOKIE = 1024,
//
//  DOCHOSTUIFLAG.name versions
//
        DIALOG            = 1,
        DISABLE_HELP_MENU = 2,
        NO3DBORDER        = 4,
        SCROLL_NO         = 8,
        DISABLE_SCRIPT_INACTIVE = 16,
        OPENNEWWIN        = 32,
        DISABLE_OFFSCREEN = 64,
        FLAT_SCROLLBAR = 128,
        DIV_BLOCKDEFAULT = 256,
        ACTIVATE_CLIENTHIT_ONLY = 512,
        DISABLE_COOKIE = 1024,
}
/* polute the global namespace */
enum {
        DOCHOSTUITYPE_BROWSE    = 0,
        DOCHOSTUITYPE_AUTHOR    = 1,

        DOCHOSTUIDBLCLK_DEFAULT         = 0,
        DOCHOSTUIDBLCLK_SHOWPROPERTIES  = 1,
        DOCHOSTUIDBLCLK_SHOWCODE        = 2,

       DOCHOSTUIFLAG_DIALOG            = 1,
        DOCHOSTUIFLAG_DISABLE_HELP_MENU = 2,
        DOCHOSTUIFLAG_NO3DBORDER        = 4,
        DOCHOSTUIFLAG_SCROLL_NO         = 8,
        DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE = 16,
        DOCHOSTUIFLAG_OPENNEWWIN        = 32,
        DOCHOSTUIFLAG_DISABLE_OFFSCREEN = 64,
        DOCHOSTUIFLAG_FLAT_SCROLLBAR = 128,
        DOCHOSTUIFLAG_DIV_BLOCKDEFAULT = 256,
        DOCHOSTUIFLAG_ACTIVATE_CLIENTHIT_ONLY = 512,
        DOCHOSTUIFLAG_DISABLE_COOKIE = 1024,
}

struct DOCHOSTUIINFO
{
	ULONG cbSize;
	DWORD dwFlags;
	DWORD dwDoubleClick;
}

interface IDocHostUIHandler : IUnknown
{
	HRESULT ShowContextMenu( DWORD dwID, POINT* ppt, IUnknown pcmdtReserved, IDispatch pdispReserved);
	HRESULT GetHostInfo( DOCHOSTUIINFO * pInfo );
	HRESULT ShowUI( DWORD dwID, IOleInPlaceActiveObject pActiveObject, IOleCommandTarget pCommandTarget, IOleInPlaceFrame pFrame, IOleInPlaceUIWindow pDoc );
	HRESULT HideUI();
	HRESULT UpdateUI();
	HRESULT EnableModeless( BOOL fEnable );
	HRESULT OnDocWindowActivate( BOOL fActivate );
	HRESULT OnFrameWindowActivate( BOOL fActivate );
	HRESULT ResizeBorder(LPRECT prcBorder, IOleInPlaceUIWindow pUIWindow, BOOL fRameWindow );
	HRESULT TranslateAccelerator( LPMSG lpMsg, GUID * pguidCmdGroup, DWORD nCmdID );
	HRESULT GetOptionKeyPath( LPOLESTR * pchKey, DWORD dw );
	HRESULT GetDropTarget( IDropTarget pDropTarget, IDropTarget * ppDropTarget );
	HRESULT GetExternal( IDispatch * ppDispatch );
	HRESULT TranslateUrl( DWORD dwTranslate, OLECHAR * pchURLIn, OLECHAR ** ppchURLOut );
	HRESULT FilterDataObject( IDataObject pDO, IDataObject * ppDORet );
}


//-------------------------------------------------------------------------
//  ICustomDoc
//
//-------------------------------------------------------------------------

interface ICustomDoc : IUnknown
{
	HRESULT SetUIHandler( IDocHostUIHandler pUIHandler );
}

//-------------------------------------------------------------------------
//  IDocHostShowUI
//
//-------------------------------------------------------------------------

interface IDocHostShowUI : IUnknown
{
	HRESULT ShowMessage( HWND hwnd, LPOLESTR lpstrText, LPOLESTR lpstrCaption, DWORD dwType, LPOLESTR lpstrHelpFile, DWORD dwHelpContext, LRESULT * plResult);
	HRESULT ShowHelp( HWND hwnd, LPOLESTR pszHelpFile, UINT uCommand, DWORD dwData, POINT ptMouse, IDispatch pDispatchObjectHit );
}

/*

//-------------------------------------------------------------------------
//  ICSSFilterSite
//
//-------------------------------------------------------------------------
interface ICSSFilterSite : IUnknown
{
	HRESULT GetElement( IHTMLElement * ppElem );
	HRESULT FireOnFilterChangeEvent();
}


//-------------------------------------------------------------------------
//  ICSSFilter
//
//-------------------------------------------------------------------------
interface ICSSFilter : IUnknown
{
	HRESULT SetSite( ICSSFilterSite * pSink );
	HRESULT OnAmbientPropertyChange( LONG dispid );
}

*/

} // extern( Windows )
