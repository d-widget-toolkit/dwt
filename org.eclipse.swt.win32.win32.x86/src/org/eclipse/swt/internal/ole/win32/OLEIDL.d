module org.eclipse.swt.internal.ole.win32.OLEIDL;
//+-------------------------------------------------------------------------
//
//  Microsoft Windows
//  Copyright (C) Microsoft Corporation, 1992-1997.
//
//  File: oadvhr.idl
//
//--------------------------------------------------------------------------
import org.eclipse.swt.internal.win32.WINTYPES;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.ole.win32.COMTYPES;
//private import std.c.windows.windows;
//private import std.c.windows.com;

extern( Windows ) {
//interface IOleInPlaceActiveObject;
//interface IEnumOLEVERB;

interface IOleAdviseHolder : IUnknown
{
    HRESULT Advise( IAdviseSink pAdvise, DWORD * pdwConnection );
    HRESULT Unadvise( DWORD dwConnection );
    HRESULT EnumAdvise ( IEnumSTATDATA ppenumAdvise );
    HRESULT SendOnRename( IMoniker pmk );
    HRESULT SendOnSave();
    HRESULT SendOnClose();
}
alias IOleAdviseHolder LPOLEADVISEHOLDER;

interface IOleCache : IUnknown
{
    HRESULT Cache( FORMATETC *pformatetc, DWORD advf, DWORD * pdwConnection );
    HRESULT Uncache( DWORD dwConnection );
    HRESULT EnumCache( IEnumSTATDATA * ppenumSTATDATA );
    HRESULT InitCache( IDataObject pDataObject );
    HRESULT SetData( FORMATETC * pformatetc, STGMEDIUM * pmedium, BOOL fRelease );
}
alias IOleCache LPOLECACHE;

interface IOleCache2 : IOleCache
{
    // Cache update Flags
/*
    const DWORD UPDFCACHE_NODATACACHE   =       0x00000001;
    const DWORD UPDFCACHE_ONSAVECACHE   =       0x00000002;
    const DWORD UPDFCACHE_ONSTOPCACHE   =       0x00000004;
    const DWORD UPDFCACHE_NORMALCACHE   =       0x00000008;
    const DWORD UPDFCACHE_IFBLANK       =       0x00000010;
    const DWORD UPDFCACHE_ONLYIFBLANK   =       0x80000000;

    const DWORD UPDFCACHE_IFBLANKORONSAVECACHE  =
                    (UPDFCACHE_IFBLANK | UPDFCACHE_ONSAVECACHE);
    const DWORD UPDFCACHE_ALL                   =
                    ((DWORD)(~(UPDFCACHE_ONLYIFBLANK)));
    const DWORD UPDFCACHE_ALLBUTNODATACACHE     =
                    (UPDFCACHE_ALL & ((DWORD)(~UPDFCACHE_NODATACACHE)));


    // IOleCache2::DiscardCache options
    typedef [v1_enum] enum tagDISCARDCACHE
    {
        DISCARDCACHE_SAVEIFDIRTY =  0,  // Save all dirty cache before discarding
        DISCARDCACHE_NOSAVE      =  1   // Don't save dirty caches before
                                    // discarding
    } DISCARDCACHE;
*/

    HRESULT UpdateCache( LPDATAOBJECT pDataObject, DWORD grfUpdf, LPVOID pReserved );

//    [call_as(UpdateCache)]
//    HRESULT RemoteUpdateCache( LPDATAOBJECT pDataObject, DWORD grfUpdf, DWORD pReserved );
    HRESULT DiscardCache( DWORD dwDiscardOptions );
}
alias IOleCache2 LPOLECACHE2;

interface IOleCacheControl : IUnknown
{
    HRESULT OnRun( LPDATAOBJECT pDataObject );
    HRESULT OnStop();
}
alias IOleCacheControl LPOLECACHECONTROL;

interface IParseDisplayName : IUnknown
{
    HRESULT ParseDisplayName( IBindCtx pbc, LPOLESTR pszDisplayName, ULONG * pchEaten, IMoniker * ppmkOut );
}
alias IParseDisplayName LPPARSEDISPLAYNAME;

interface IOleContainer : IParseDisplayName
{
	HRESULT EnumObjects( DWORD grfFlags, IEnumUnknown * ppenum );
	HRESULT LockContainer( BOOL fLock );
}
alias IOleContainer LPOLECONTAINER;


interface IOleClientSite : IUnknown
{
	HRESULT SaveObject();
	HRESULT GetMoniker( DWORD dwAssign, DWORD dwWhichMoniker, IMoniker * ppmk );
	HRESULT GetContainer( IOleContainer * ppContainer );
	HRESULT ShowObject();
	HRESULT OnShowWindow( BOOL fShow );
	HRESULT RequestNewObjectLayout();
}
alias IOleClientSite LPOLECLIENTSITE;

enum OLEGETMONIKER
{
	OLEGETMONIKER_ONLYIFTHERE = 1,
	OLEGETMONIKER_FORCEASSIGN = 2,
	OLEGETMONIKER_UNASSIGN    = 3,
	OLEGETMONIKER_TEMPFORUSER = 4
}

enum OLEWHICHMK
{
	OLEWHICHMK_CONTAINER = 1,
	OLEWHICHMK_OBJREL    = 2,
	OLEWHICHMK_OBJFULL   = 3
}

enum USERCLASSTYPE
{
        USERCLASSTYPE_FULL    = 1,
        USERCLASSTYPE_SHORT   = 2,
        USERCLASSTYPE_APPNAME = 3,
}

enum OLEMISC
{
        OLEMISC_RECOMPOSEONRESIZE           = 0x00000001,
        OLEMISC_ONLYICONIC                  = 0x00000002,
        OLEMISC_INSERTNOTREPLACE            = 0x00000004,
        OLEMISC_STATIC                      = 0x00000008,
        OLEMISC_CANTLINKINSIDE              = 0x00000010,
        OLEMISC_CANLINKBYOLE1               = 0x00000020,
        OLEMISC_ISLINKOBJECT                = 0x00000040,
        OLEMISC_INSIDEOUT                   = 0x00000080,
        OLEMISC_ACTIVATEWHENVISIBLE         = 0x00000100,
        OLEMISC_RENDERINGISDEVICEINDEPENDENT= 0x00000200,
        OLEMISC_INVISIBLEATRUNTIME          = 0x00000400,
        OLEMISC_ALWAYSRUN                   = 0x00000800,
        OLEMISC_ACTSLIKEBUTTON              = 0x00001000,
        OLEMISC_ACTSLIKELABEL               = 0x00002000,
        OLEMISC_NOUIACTIVATE                = 0x00004000,
        OLEMISC_ALIGNABLE                   = 0x00008000,
        OLEMISC_SIMPLEFRAME                 = 0x00010000,
        OLEMISC_SETCLIENTSITEFIRST          = 0x00020000,
        OLEMISC_IMEMODE                     = 0x00040000,
        OLEMISC_IGNOREACTIVATEWHENVISIBLE   = 0x00080000,
        OLEMISC_WANTSTOMENUMERGE            = 0x00100000,
        OLEMISC_SUPPORTSMULTILEVELUNDO      = 0x00200000
}

enum OLECLOSE
{
	OLECLOSE_SAVEIFDIRTY = 0,
	OLECLOSE_NOSAVE      = 1,
	OLECLOSE_PROMPTSAVE  = 2,
	SAVEIFDIRTY = 0,
	NOSAVE      = 1,
	PROMPTSAVE  = 2
}

interface IOleObject : IUnknown
{
	HRESULT SetClientSite( IOleClientSite pClientSite );
	HRESULT GetClientSite( IOleClientSite * ppClientSite );
	HRESULT SetHostNames( LPCOLESTR szContainerApp, LPCOLESTR szContainerObj );
	HRESULT Close( DWORD dwSaveOption );
	HRESULT SetMoniker( DWORD dwWhichMoniker, IMoniker pmk );
	HRESULT GetMoniker( DWORD dwAssign, DWORD dwWhichMoniker, IMoniker * ppmk );
	HRESULT InitFromData( IDataObject pDataObject, BOOL fCreation, DWORD dwReserved );
	HRESULT GetClipboardData( DWORD dwReserved, IDataObject * ppDataObject );
	HRESULT DoVerb( LONG iVerb, LPMSG lpmsg, IOleClientSite pActiveSite, LONG lindex, HWND hwndParent, LPCRECT lprcPosRect );
	HRESULT EnumVerbs( IEnumOLEVERB * ppEnumOleVerb );
	HRESULT Update();
	HRESULT IsUpToDate();
	HRESULT GetUserClassID( CLSID * pClsid );
	HRESULT GetUserType( DWORD dwFormOfType, LPOLESTR * pszUserType );
	HRESULT SetExtent( DWORD dwDrawAspect, SIZEL * psizel );
	HRESULT GetExtent( DWORD dwDrawAspect, SIZEL * psizel );
	HRESULT Advise( IAdviseSink pAdvSink, DWORD * pdwConnection );
	HRESULT Unadvise( DWORD dwConnection );
	HRESULT EnumAdvise( IEnumSTATDATA * ppenumAdvise );
	HRESULT GetMiscStatus( DWORD dwAspect, DWORD *pdwStatus );
	HRESULT SetColorScheme( LOGPALETTE *pLogpal );
}
alias IOleObject LPOLEOBJECT;

enum OLERENDER
{
	OLERENDER_NONE   = 0,
	OLERENDER_DRAW   = 1,
	OLERENDER_FORMAT = 2,
	OLERENDER_ASIS   = 3,
	NONE   = 0,
	DRAW   = 1,
	FORMAT = 2,
	ASIS   = 3
}
alias OLERENDER * LPOLERENDER;

interface IOLETypes
{
}
    /****** OLE value types ***********************************************/
    /* rendering options */
    /****** Clipboard Data structures *****************************************/
    struct OBJECTDESCRIPTOR
    {
       ULONG    cbSize;              // Size of structure in bytes
       CLSID    clsid;               // CLSID of data being transferred
       DWORD    dwDrawAspect;        // Display aspect of the object
                                     //     normally DVASPECT_CONTENT or ICON.
                                     //     dwDrawAspect will be 0 (which is NOT
                                     //     DVASPECT_CONTENT) if the copier or
                                     //     dragsource didn't draw the object to
                                     //     begin with.
       SIZEL    sizel;               // size of the object in HIMETRIC
                                     //    sizel is opt.: will be (0,0) for apps
                                     //    which don't draw the object being
                                     //    transferred
       POINTL   pointl;              // Offset in HIMETRIC units from the
                                     //    upper-left corner of the obj where the
                                     //    mouse went down for the drag.
                                     //    NOTE: y coordinates increase downward.
                                     //          x coordinates increase to right
                                     //    pointl is opt.; it is only meaningful
                                     //    if object is transfered via drag/drop.
                                     //    (0, 0) if mouse position is unspecified
                                     //    (eg. when obj transfered via clipboard)
       DWORD    dwStatus;            // Misc. status flags for object. Flags are
                                     //    defined by OLEMISC enum. these flags
                                     //    are as would be returned
                                     //    by IOleObject::GetMiscStatus.
       DWORD    dwFullUserTypeName;  // Offset from beginning of structure to
                                     //    null-terminated string that specifies
                                     //    Full User Type Name of the object.
                                     //    0 indicates string not present.
       DWORD    dwSrcOfCopy;         // Offset from beginning of structure to
                                     //    null-terminated string that specifies
                                     //    source of the transfer.
                                     //    dwSrcOfCOpy is normally implemented as
                                     //    the display name of the temp-for-user
                                     //    moniker which identifies the source of
                                     //    the data.
                                     //    0 indicates string not present.
                                     //    NOTE: moniker assignment is NOT forced.
                                     //    see IOleObject::GetMoniker(
                                     //                OLEGETMONIKER_TEMPFORUSER)

     /* variable sized string data may appear here */

    }
	 alias OBJECTDESCRIPTOR  LINKSRCDESCRIPTOR;
	 alias OBJECTDESCRIPTOR  * POBJECTDESCRIPTOR;
	 alias OBJECTDESCRIPTOR  * LPOBJECTDESCRIPTOR;
	 alias OBJECTDESCRIPTOR  * PLINKSRCDESCRIPTOR;
	 alias OBJECTDESCRIPTOR  * LPLINKSRCDESCRIPTOR;


interface IOleWindow : IUnknown
{
    HRESULT GetWindow( HWND * phwnd );
    HRESULT ContextSensitiveHelp( BOOL fEnterMode );
}
alias IOleWindow LPOLEWINDOW;
enum OLEUPDATE
{
	OLEUPDATE_ALWAYS=1,
	OLEUPDATE_ONCALL=3
}
alias OLEUPDATE * LPOLEUPDATE;
alias OLEUPDATE * POLEUPDATE;

    // for IOleLink::BindToSource
enum OLELINKBIND
{
	OLELINKBIND_EVENIFCLASSDIFF = 1,
}

interface IOleLink : IUnknown
{
    /* Link update options */
	HRESULT SetUpdateOptions( DWORD dwUpdateOpt );
	HRESULT GetUpdateOptions( DWORD * pdwUpdateOpt );
	HRESULT SetSourceMoniker( IMoniker pmk, REFCLSID rclsid );
	HRESULT GetSourceMoniker( IMoniker * ppmk );
	HRESULT SetSourceDisplayName( LPCOLESTR pszStatusText );
	HRESULT GetSourceDisplayName( LPOLESTR * ppszDisplayName );
	HRESULT BindToSource( DWORD bindflags, IBindCtx pbc );
	HRESULT BindIfRunning();
	HRESULT GetBoundSource( IUnknown * ppunk );
	HRESULT UnbindSource();
	HRESULT Update( IBindCtx pbc );
}
alias IOleLink LPOLELINK;

enum BINDSPEED
{
	BINDSPEED_INDEFINITE    = 1,
	BINDSPEED_MODERATE      = 2,
	BINDSPEED_IMMEDIATE     = 3
}

enum OLECONTF
{
	OLECONTF_EMBEDDINGS     = 1,
	OLECONTF_LINKS          = 2,
	OLECONTF_OTHERS         = 4,
	OLECONTF_ONLYUSER       = 8,
	OLECONTF_ONLYIFRUNNING  = 16
}

interface IOleItemContainer : IOleContainer
{
	HRESULT GetObject( LPOLESTR pszItem, DWORD dwSpeedNeeded, IBindCtx pbc, REFIID riid, void **ppvObject);
	HRESULT GetObjectStorage( LPOLESTR pszItem, IBindCtx pbc, REFIID riid, void **ppvStorage);
	HRESULT IsRunning(LPOLESTR pszItem);
}
alias IOleItemContainer LPOLEITEMCONTAINER;

alias RECT BORDERWIDTHS;
alias LPRECT LPBORDERWIDTHS;
alias LPCRECT LPCBORDERWIDTHS;

interface IOleInPlaceUIWindow : IOleWindow
{
	HRESULT GetBorder( LPRECT lprectBorder );
	HRESULT RequestBorderSpace( LPCBORDERWIDTHS pborderwidths );
	HRESULT SetBorderSpace( LPCBORDERWIDTHS pborderwidths );
	HRESULT SetActiveObject( LPOLEINPLACEACTIVEOBJECT pActiveObject, LPCOLESTR pszObjName );
}
alias IOleInPlaceUIWindow LPOLEINPLACEUIWINDOW;

interface IOleInPlaceActiveObject : IOleWindow
{
	HRESULT TranslateAccelerator( LPMSG lpmsg );
	HRESULT OnFrameWindowActivate( BOOL fActivate );
	HRESULT OnDocWindowActivate( BOOL fActivate );
	HRESULT ResizeBorder( LPCRECT prcBorder, IOleInPlaceUIWindow pUIWindow, BOOL fFrameWindow );
	HRESULT EnableModeless ( BOOL fEnable );
}
alias IOleInPlaceActiveObject LPOLEINPLACEACTIVEOBJECT;

struct OLEINPLACEFRAMEINFO          // OleInPlaceFrameInfo
{
    UINT    cb;
    BOOL    fMDIApp;
    HWND    hwndFrame;
    HACCEL  haccel;
    UINT    cAccelEntries;
}
alias OLEINPLACEFRAMEINFO * LPOLEINPLACEFRAMEINFO;


struct OLEMENUGROUPWIDTHS
{
    LONG[6]    width;
}
alias OLEMENUGROUPWIDTHS * LPOLEMENUGROUPWIDTHS;

alias HGLOBAL HOLEMENU;

interface IOleInPlaceFrame : IOleInPlaceUIWindow
{
HRESULT InsertMenus( HMENU hmenuShared, LPOLEMENUGROUPWIDTHS lpMenuWidths );
HRESULT SetMenu( HMENU hmenuShared, HOLEMENU holemenu, HWND hwndActiveObject );
HRESULT RemoveMenus( HMENU hmenuShared );
HRESULT SetStatusText( LPCOLESTR pszStatusText );
HRESULT EnableModeless( BOOL fEnable );
HRESULT TranslateAccelerator( LPMSG lpmsg, WORD wID );
}
alias IOleInPlaceFrame LPOLEINPLACEFRAME;

interface IOleInPlaceObject : IOleWindow
{
	HRESULT InPlaceDeactivate();
	HRESULT UIDeactivate();
	HRESULT SetObjectRects( LPCRECT lprcPosRect, LPCRECT lprcClipRect );
	HRESULT ReactivateAndUndo();
}
alias IOleInPlaceObject LPOLEINPLACEOBJECT;

interface IOleInPlaceSite : IOleWindow
{
	HRESULT CanInPlaceActivate();
	HRESULT OnInPlaceActivate();
	HRESULT OnUIActivate();
	HRESULT GetWindowContext( IOleInPlaceFrame * ppFrame, IOleInPlaceUIWindow * ppDoc, LPRECT lprcPosRect, LPRECT lprcClipRect, LPOLEINPLACEFRAMEINFO lpFrameInfo );
	HRESULT Scroll( SIZE scrollExtant );
	HRESULT OnUIDeactivate( BOOL fUndoable );
	HRESULT OnInPlaceDeactivate();
	HRESULT DiscardUndoState();
	HRESULT DeactivateAndUndo();
	HRESULT OnPosRectChange( LPCRECT lprcPosRect );
}
alias IOleInPlaceSite LPOLEINPLACESITE;

interface IContinue : IUnknown
{
    HRESULT FContinue();
}

interface IViewObject : IUnknown
{
	HRESULT Draw( DWORD dwDrawAspect, LONG lindex, void * pvAspect, DVTARGETDEVICE *ptd, HDC hdcTargetDev, HDC hdcDraw, LPCRECTL lprcBounds, LPCRECTL lprcWBounds, BOOL function(ULONG_PTR dwContinue) pfnContinue, ULONG_PTR dwContinue );
	HRESULT GetColorSet( DWORD dwDrawAspect, LONG lindex, void *pvAspect, DVTARGETDEVICE *ptd, HDC hicTargetDev, LOGPALETTE **ppColorSet );
	HRESULT Freeze( DWORD dwDrawAspect, LONG lindex, void *pvAspect, DWORD *pdwFreeze );
	HRESULT Unfreeze( DWORD dwFreeze );
	HRESULT SetAdvise( DWORD aspects, DWORD advf, IAdviseSink pAdvSink );
	HRESULT GetAdvise( DWORD * pAspects, DWORD * pAdvf, IAdviseSink * ppAdvSink );
}
alias IViewObject LPVIEWOBJECT;

interface IViewObject2 : IViewObject
{
	HRESULT GetExtent( DWORD dwDrawAspect, LONG lindex, DVTARGETDEVICE* ptd, LPSIZEL lpsizel );
}
alias IViewObject2 LPVIEWOBJECT2;

interface IDropSource : IUnknown
{
	HRESULT QueryContinueDrag( BOOL fEscapePressed, DWORD grfKeyState );
	HRESULT GiveFeedback( DWORD dwEffect );
}
alias IDropSource LPDROPSOURCE;

const DWORD MK_ALT = 0x0020;
const DWORD DROPEFFECT_NONE = 0;
const DWORD DROPEFFECT_COPY = 1;
const DWORD DROPEFFECT_MOVE = 2;
const DWORD DROPEFFECT_LINK = 4;
const DWORD DROPEFFECT_SCROLL = 0x80000000;
const DWORD DD_DEFSCROLLINSET = 11;
const DWORD DD_DEFSCROLLDELAY = 50;
const DWORD DD_DEFSCROLLINTERVAL = 50;
const DWORD DD_DEFDRAGDELAY = 200;
const DWORD DD_DEFDRAGMINDIST = 2;

interface IDropTarget : IUnknown
{
	HRESULT DragEnter( IDataObject pDataObj, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect );
	HRESULT DragOver( DWORD grfKeyState, POINTL pt, DWORD *pdwEffect );
	HRESULT DragLeave();
	HRESULT Drop(IDataObject pDataObj,DWORD grfKeyState,POINTL pt,DWORD *pdwEffect);
}
alias IDropTarget LPDROPTARGET;

struct OLEVERB {
        LONG    lVerb;
        LPOLESTR  lpszVerbName;
        DWORD   fuFlags;
        DWORD grfAttribs;
}
alias OLEVERB * LPOLEVERB;

// Bitwise verb attributes used in OLEVERB.grfAttribs
enum OLEVERBATTRIB // bitwise
{
	OLEVERBATTRIB_NEVERDIRTIES = 1,
	OLEVERBATTRIB_ONCONTAINERMENU = 2,
	NEVERDIRTIES = 1,
	ONCONTAINERMENU = 2
}

interface IEnumOLEVERB : IUnknown
{
	HRESULT Next( ULONG celt, LPOLEVERB rgelt, ULONG * pceltFetched );
	HRESULT Skip( ULONG celt );
	HRESULT Reset();
	HRESULT Clone( IEnumOLEVERB * ppenum );
}
alias IEnumOLEVERB LPENUMOLEVERB;

} /* extern(Windows) */
