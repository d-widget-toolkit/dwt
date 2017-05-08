module org.eclipse.swt.internal.ole.win32.DOCOBJ;

//private import std.c.windows.windows;
//private import std.c.windows.com;
private import org.eclipse.swt.internal.win32.OS;
private import org.eclipse.swt.internal.win32.WINTYPES;
private import org.eclipse.swt.internal.ole.win32.extras;
private import org.eclipse.swt.internal.ole.win32.OLEIDL;
//private import org.eclipse.swt.internal.ole.win32.OAIDL;
private import org.eclipse.swt.internal.ole.win32.OBJIDL;

extern( Windows ) {

alias wchar wchar_t;

//+---------------------------------------------------------------------------
//
//  Copyright 1995 - 1998 Microsoft Corporation. All Rights Reserved.
//
//  Contents:   OLE Document Object interfaces
//
//----------------------------------------------------------------------------


/*
#define HWND        UserHWND
#define HACCEL      UserHACCEL
#define HDC         UserHDC
#define HFONT       UserHFONT
#define MSG         UserMSG
#define BSTR        UserBSTR
#define EXCEPINFO   UserEXCEPINFO
#define VARIANT     UserVARIANT
*/
/*
interface IOleDocument;
interface IOleDocumentSite;
interface IOleDocumentView;
interface IEnumOleDocumentViews;
interface IContinueCallback;
interface IPrint;
interface IOleCommandTarget;
  */



//+---------------------------------------------------------------------------
//
//  Copyright (C) Microsoft Corporation, 1995-1997.
//
//  Contents:    IOleDocument interface definition
//
//----------------------------------------------------------------------------
enum DOCMISC {
                DOCMISC_CANCREATEMULTIPLEVIEWS          = 1,
                DOCMISC_SUPPORTCOMPLEXRECTANGLES        = 2,
                DOCMISC_CANTOPENEDIT                        = 4,        // fails the IOleDocumentView::Open  method
                DOCMISC_NOFILESUPPORT                       = 8,        //  does not support read/writing to a file
}

interface IOleDocument : IUnknown
{
        HRESULT CreateView(IOleInPlaceSite pIPSite,IStream pstm,DWORD dwReserved,IOleDocumentView *ppView);

        HRESULT GetDocMiscStatus(DWORD *pdwStatus);

        HRESULT EnumViews( IEnumOleDocumentViews * ppEnum, IOleDocumentView * ppView);
}
alias IOleDocument LPOLEDOCUMENT;


//+---------------------------------------------------------------------------
//
//  Copyright (C) Microsoft Corporation, 1995-1997.
//
//  Contents:    IOleDocumentSite interface definition
//
//----------------------------------------------------------------------------
interface IOleDocumentSite : IUnknown
{
        HRESULT ActivateMe(IOleDocumentView pViewToActivate);
}
alias IOleDocumentSite LPOLEDOCUMENTSITE;


//+---------------------------------------------------------------------------
//
//  Copyright (C) Microsoft Corporation, 1995-1997.
//
//  Contents:    IOleDocumentView interface definition
//
//----------------------------------------------------------------------------
interface IOleDocumentView : IUnknown
{
        HRESULT SetInPlaceSite(IOleInPlaceSite pIPSite);

        HRESULT GetInPlaceSite(IOleInPlaceSite * ppIPSite);

        HRESULT GetDocument(IUnknown *ppunk);

        HRESULT SetRect(LPRECT prcView);

        HRESULT GetRect(LPRECT prcView);

        HRESULT SetRectComplex(LPRECT prcView,LPRECT prcHScroll,LPRECT prcVScroll,LPRECT prcSizeBox);

        HRESULT Show(BOOL fShow);

        HRESULT UIActivate(BOOL fUIActivate);

        HRESULT Open();

        HRESULT CloseView(DWORD dwReserved);

        HRESULT SaveViewState(LPSTREAM pstm);

        HRESULT ApplyViewState(LPSTREAM pstm);

        HRESULT Clone(IOleInPlaceSite pIPSiteNew,IOleDocumentView *ppViewNew);
}
alias IOleDocumentView LPOLEDOCUMENTVIEW;


//+---------------------------------------------------------------------------
//
//  Copyright (C) Microsoft Corporation, 1995-1997.
//
//  Contents:    IEnumOleDocumentViews interface definition
//
//----------------------------------------------------------------------------
interface IEnumOleDocumentViews : IUnknown
{
        HRESULT Next(
	ULONG cViews,
	IOleDocumentView * rgpView,
		ULONG *pcFetched);

        HRESULT Skip(ULONG cViews);

        HRESULT Reset();

        HRESULT Clone(IEnumOleDocumentViews *ppEnum);
}
alias IEnumOleDocumentViews LPENUMOLEDOCUMENTVIEWS;



//+---------------------------------------------------------------------------
//
//  Copyright (C) Microsoft Corporation, 1995-1997.
//
//  Contents:    IContinueCallback interface definition
//
//----------------------------------------------------------------------------

interface IContinueCallback : IUnknown
{
        HRESULT FContinue();

        HRESULT FContinuePrinting(LONG nCntPrinted,LONG nCurPage, wchar_t * pwszPrintStatus);
}
alias IContinueCallback  LPCONTINUECALLBACK;


//+---------------------------------------------------------------------------
//
//  Copyright (C) Microsoft Corporation, 1995-1997.
//
//  Contents:    IPrint interface definition
//
//----------------------------------------------------------------------------
enum PRINTFLAG
        {
                PRINTFLAG_MAYBOTHERUSER         = 1,
                PRINTFLAG_PROMPTUSER            = 2,
                PRINTFLAG_USERMAYCHANGEPRINTER  = 4,
                PRINTFLAG_RECOMPOSETODEVICE     = 8,
                PRINTFLAG_DONTACTUALLYPRINT     = 16,
                PRINTFLAG_FORCEPROPERTIES       = 32,
                PRINTFLAG_PRINTTOFILE           = 64
        } ;

struct  PAGERANGE
        {
                LONG nFromPage;
                LONG nToPage;
        }

struct  PAGESET
        {
                ULONG   cbStruct;
                BOOL    fOddPages;
                BOOL    fEvenPages;
                ULONG   cPageRange;
                PAGERANGE[1] rgPages;
        }

interface IPrint : IUnknown
{

        HRESULT SetInitialPageNum(LONG nFirstPage);

        HRESULT GetPageInfo(LONG *pnFirstPage,LONG *pcPages);

        HRESULT Print(
	DWORD grfFlags,
DVTARGETDEVICE **pptd,
PAGESET ** ppPageSet,
STGMEDIUM * pstgmOptions,
IContinueCallback pcallback,
LONG nFirstPage,
LONG *pcPagesPrinted,
LONG *pnLastPage);
}
alias IPrint LPPRINT;


//+---------------------------------------------------------------------------
//
//  Copyright (C) Microsoft Corporation, 1995-1997.
//
//  Contents:    IOleCommandTarget interface definition
//
//----------------------------------------------------------------------------
enum OLECMDF
        {
                OLECMDF_SUPPORTED       = 0x00000001,
                OLECMDF_ENABLED         = 0x00000002,
                OLECMDF_LATCHED         = 0x00000004,
                OLECMDF_NINCHED         = 0x00000008,
        }




struct OLECMD {
                ULONG   cmdID;
                DWORD   cmdf;
        }

struct OLECMDTEXT{
                DWORD cmdtextf;
                ULONG cwActual;
                ULONG cwBuf;    /* size in wide chars of the buffer for text */
                wchar_t[1] rgwz; /* Array into which callee writes the text */
}

enum OLECMDTEXTF
        {
                OLECMDTEXTF_NONE        = 0,
                OLECMDTEXTF_NAME        = 1,
                OLECMDTEXTF_STATUS      = 2,
        }

enum OLECMDEXECOPT
        {
                OLECMDEXECOPT_DODEFAULT         = 0,
                OLECMDEXECOPT_PROMPTUSER        = 1,
                OLECMDEXECOPT_DONTPROMPTUSER    = 2,
                OLECMDEXECOPT_SHOWHELP          = 3
        }
enum OLECMDID {
                OLECMDID_OPEN                           = 1,
                OLECMDID_NEW                            = 2,
                OLECMDID_SAVE                           = 3,
                OLECMDID_SAVEAS                         = 4,
                OLECMDID_SAVECOPYAS                     = 5,
                OLECMDID_PRINT                          = 6,
                OLECMDID_PRINTPREVIEW                   = 7,
                OLECMDID_PAGESETUP                      = 8,
                OLECMDID_SPELL                          = 9,
                OLECMDID_PROPERTIES                     = 10,
                OLECMDID_CUT                            = 11,
                OLECMDID_COPY                           = 12,
                OLECMDID_PASTE                          = 13,
                OLECMDID_PASTESPECIAL                   = 14,
                OLECMDID_UNDO                           = 15,
                OLECMDID_REDO                           = 16,
                OLECMDID_SELECTALL                      = 17,
                OLECMDID_CLEARSELECTION                 = 18,
                OLECMDID_ZOOM                           = 19,
                OLECMDID_GETZOOMRANGE                   = 20,
                OLECMDID_UPDATECOMMANDS                 = 21,
                OLECMDID_REFRESH                        = 22,
                OLECMDID_STOP                           = 23,
                OLECMDID_HIDETOOLBARS                   = 24,
                OLECMDID_SETPROGRESSMAX                 = 25,
                OLECMDID_SETPROGRESSPOS                 = 26,
                OLECMDID_SETPROGRESSTEXT                = 27,
                OLECMDID_SETTITLE                       = 28,
                OLECMDID_SETDOWNLOADSTATE               = 29,
                OLECMDID_STOPDOWNLOAD                   = 30,
                OLECMDID_ONTOOLBARACTIVATED             = 31,
                OLECMDID_FIND                           = 32,
                OLECMDID_DELETE                         = 33,
                OLECMDID_HTTPEQUIV                      = 34,
                OLECMDID_HTTPEQUIV_DONE                 = 35,
                OLECMDID_ENABLE_INTERACTION             = 36,
                OLECMDID_ONUNLOAD                       = 37,
                OLECMDID_PROPERTYBAG2                   = 38,
                OLECMDID_PREREFRESH                     = 39
        }

interface IOleCommandTarget : IUnknown
{

/* error codes */
/*
cpp_quote("#define OLECMDERR_E_FIRST            (OLE_E_LAST+1)")
cpp_quote("#define OLECMDERR_E_NOTSUPPORTED (OLECMDERR_E_FIRST)")
cpp_quote("#define OLECMDERR_E_DISABLED         (OLECMDERR_E_FIRST+1)")
cpp_quote("#define OLECMDERR_E_NOHELP           (OLECMDERR_E_FIRST+2)")
cpp_quote("#define OLECMDERR_E_CANCELED         (OLECMDERR_E_FIRST+3)")
cpp_quote("#define OLECMDERR_E_UNKNOWNGROUP     (OLECMDERR_E_FIRST+4)")

cpp_quote("#define MSOCMDERR_E_FIRST OLECMDERR_E_FIRST")
cpp_quote("#define MSOCMDERR_E_NOTSUPPORTED OLECMDERR_E_NOTSUPPORTED")
cpp_quote("#define MSOCMDERR_E_DISABLED OLECMDERR_E_DISABLED")
cpp_quote("#define MSOCMDERR_E_NOHELP OLECMDERR_E_NOHELP")
cpp_quote("#define MSOCMDERR_E_CANCELED OLECMDERR_E_CANCELED")
cpp_quote("#define MSOCMDERR_E_UNKNOWNGROUP OLECMDERR_E_UNKNOWNGROUP")
  */
        HRESULT QueryStatus(
					GUID *pguidCmdGroup,
				ULONG cCmds,
					OLECMD * prgCmds,
				OLECMDTEXT *pCmdText);


        HRESULT Exec(
					GUID *pguidCmdGroup,
					DWORD nCmdID,
				DWORD nCmdexecopt,
					VARIANT *pvaIn,
				VARIANT *pvaOut);
}
alias IOleCommandTarget LPOLECOMMANDTARGET;
/*
cpp_quote("typedef enum")
cpp_quote("{")
cpp_quote("      OLECMDIDF_REFRESH_NORMAL          = 0,")
cpp_quote("      OLECMDIDF_REFRESH_IFEXPIRED       = 1,")
cpp_quote("      OLECMDIDF_REFRESH_CONTINUE        = 2,")
cpp_quote("      OLECMDIDF_REFRESH_COMPLETELY      = 3,")
cpp_quote("      OLECMDIDF_REFRESH_NO_CACHE        = 4,")
cpp_quote("      OLECMDIDF_REFRESH_RELOAD          = 5,")
cpp_quote("      OLECMDIDF_REFRESH_LEVELMASK       = 0x00FF,")
cpp_quote("      OLECMDIDF_REFRESH_CLEARUSERINPUT  = 0x1000,")
cpp_quote("      OLECMDIDF_REFRESH_PROMPTIFOFFLINE = 0x2000,")
cpp_quote("} OLECMDID_REFRESHFLAG;")

cpp_quote("")
cpp_quote("////////////////////////////////////////////////////////////////////////////")
cpp_quote("//  Aliases to original office-compatible names")
cpp_quote("#define IMsoDocument             IOleDocument")
cpp_quote("#define IMsoDocumentSite         IOleDocumentSite")
cpp_quote("#define IMsoView                 IOleDocumentView")
cpp_quote("#define IEnumMsoView             IEnumOleDocumentViews")
cpp_quote("#define IMsoCommandTarget        IOleCommandTarget")
cpp_quote("#define LPMSODOCUMENT            LPOLEDOCUMENT")
cpp_quote("#define LPMSODOCUMENTSITE        LPOLEDOCUMENTSITE")
cpp_quote("#define LPMSOVIEW                LPOLEDOCUMENTVIEW")
cpp_quote("#define LPENUMMSOVIEW            LPENUMOLEDOCUMENTVIEWS")
cpp_quote("#define LPMSOCOMMANDTARGET       LPOLECOMMANDTARGET")
cpp_quote("#define MSOCMD                   OLECMD")
cpp_quote("#define MSOCMDTEXT               OLECMDTEXT")
cpp_quote("#define IID_IMsoDocument         IID_IOleDocument")
cpp_quote("#define IID_IMsoDocumentSite     IID_IOleDocumentSite")
cpp_quote("#define IID_IMsoView             IID_IOleDocumentView")
cpp_quote("#define IID_IEnumMsoView         IID_IEnumOleDocumentViews")
cpp_quote("#define IID_IMsoCommandTarget    IID_IOleCommandTarget")
cpp_quote("#define MSOCMDF_SUPPORTED OLECMDF_SUPPORTED")
cpp_quote("#define MSOCMDF_ENABLED OLECMDF_ENABLED")
cpp_quote("#define MSOCMDF_LATCHED OLECMDF_LATCHED")
cpp_quote("#define MSOCMDF_NINCHED OLECMDF_NINCHED")
cpp_quote("#define MSOCMDTEXTF_NONE OLECMDTEXTF_NONE")
cpp_quote("#define MSOCMDTEXTF_NAME OLECMDTEXTF_NAME")
cpp_quote("#define MSOCMDTEXTF_STATUS OLECMDTEXTF_STATUS")
cpp_quote("#define MSOCMDEXECOPT_DODEFAULT OLECMDEXECOPT_DODEFAULT")
cpp_quote("#define MSOCMDEXECOPT_PROMPTUSER OLECMDEXECOPT_PROMPTUSER")
cpp_quote("#define MSOCMDEXECOPT_DONTPROMPTUSER OLECMDEXECOPT_DONTPROMPTUSER")
cpp_quote("#define MSOCMDEXECOPT_SHOWHELP OLECMDEXECOPT_SHOWHELP")
cpp_quote("#define MSOCMDID_OPEN OLECMDID_OPEN")
cpp_quote("#define MSOCMDID_NEW OLECMDID_NEW")
cpp_quote("#define MSOCMDID_SAVE OLECMDID_SAVE")
cpp_quote("#define MSOCMDID_SAVEAS OLECMDID_SAVEAS")
cpp_quote("#define MSOCMDID_SAVECOPYAS OLECMDID_SAVECOPYAS")
cpp_quote("#define MSOCMDID_PRINT OLECMDID_PRINT")
cpp_quote("#define MSOCMDID_PRINTPREVIEW OLECMDID_PRINTPREVIEW")
cpp_quote("#define MSOCMDID_PAGESETUP OLECMDID_PAGESETUP")
cpp_quote("#define MSOCMDID_SPELL OLECMDID_SPELL")
cpp_quote("#define MSOCMDID_PROPERTIES OLECMDID_PROPERTIES")
cpp_quote("#define MSOCMDID_CUT OLECMDID_CUT")
cpp_quote("#define MSOCMDID_COPY OLECMDID_COPY")
cpp_quote("#define MSOCMDID_PASTE OLECMDID_PASTE")
cpp_quote("#define MSOCMDID_PASTESPECIAL OLECMDID_PASTESPECIAL")
cpp_quote("#define MSOCMDID_UNDO OLECMDID_UNDO")
cpp_quote("#define MSOCMDID_REDO OLECMDID_REDO")
cpp_quote("#define MSOCMDID_SELECTALL OLECMDID_SELECTALL")
cpp_quote("#define MSOCMDID_CLEARSELECTION OLECMDID_CLEARSELECTION")
cpp_quote("#define MSOCMDID_ZOOM OLECMDID_ZOOM")
cpp_quote("#define MSOCMDID_GETZOOMRANGE OLECMDID_GETZOOMRANGE")

cpp_quote("EXTERN_C const GUID SID_SContainerDispatch;")
								*/
} // extern( Windows)

