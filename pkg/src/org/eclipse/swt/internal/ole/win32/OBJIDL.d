module org.eclipse.swt.internal.ole.win32.OBJIDL;
//+-------------------------------------------------------------------------
//
//  Microsoft Windows
//  Copyright (C) Microsoft Corporation, 1992-1997.
//
//  File: objidl.idl
//
//--------------------------------------------------------------------------


import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.win32.WINTYPES;
import org.eclipse.swt.internal.ole.win32.COMTYPES;
// private import std.c.windows.windows;
// private import std.c.windows.com;
// private import org.eclipse.swt.internal.win32.os;


/* *NEED* to port wtypes.h */

extern( Windows ) {




//#ifndef DO_NO_IMPORTS
//import "unknwn.idl";
//import "wtypes.idl";
//#endif

enum SRVINFO
{
    SRVINFO_F_COSERVERINFO = 0,
    SRVINFO_F_COSERVERINFO2 = 1
}

struct COSERVERINFO
{
    DWORD             dwReserved1;
    LPWSTR            pwszName;
    COAUTHINFO *      pAuthInfo;
    DWORD             dwReserved2;
}

struct COSERVERINFO2 {
    DWORD           dwFlags;
    LPWSTR          pwszName;
    COAUTHINFO*     pAuthInfo;
    IUnknown*       ppCall;
    LPWSTR          pwszCodeURL;
    DWORD           dwFileVersionMS;
    DWORD           dwFileVersionLS;
    LPWSTR          pwszContentType;
}


/****************************************************************************
 *  Component Object Interfaces
 ****************************************************************************/

interface IMarshal : IUnknown
{
	HRESULT GetUnmarshalClass( REFIID riid, void *pv, DWORD dwDestContext, void *pvDestContext, DWORD mshlflags, CLSID *pCid );
	HRESULT GetMarshalSizeMax( REFIID riid, void *pv, DWORD dwDestContext, void *pvDestContext, DWORD mshlflags, DWORD *pSize );
	HRESULT MarshalInterface( IStream pStm, REFIID riid, void *pv, DWORD dwDestContext, void *pvDestContext, DWORD mshlflags );
	HRESULT UnmarshalInterface( IStream pStm, REFIID riid, void **ppv );
	HRESULT ReleaseMarshalData( IStream pStm );
	HRESULT DisconnectObject( DWORD dwReserved );
}
alias IMarshal LPMARSHAL;

interface IMalloc : IUnknown
{
	void * Alloc( SIZE_T cb );
	void * Realloc( void * pv, SIZE_T cb );
	void   Free( void * pv );
	SIZE_T  GetSize( void * pv );
	int    DidAlloc( void * pv );
	void   HeapMinimize();
}
alias IMalloc LPMALLOC;

interface IMallocSpy : IUnknown
{
	SIZE_T   PreAlloc( SIZE_T cbRequest );
	void  * PostAlloc( void * pActual );
	void  * PreFree( void *pRequest, BOOL  fSpyed );
	void    PostFree( BOOL  fSpyed );
	SIZE_T   PreRealloc( void   *pRequest, SIZE_T   cbRequest, void **ppNewRequest, BOOL    fSpyed );
	void  * PostRealloc( void *pActual, BOOL  fSpyed );
	void  * PreGetSize( void *pRequest, BOOL  fSpyed );
	SIZE_T   PostGetSize( SIZE_T cbActual, BOOL  fSpyed );
	void  * PreDidAlloc( void * pRequest, BOOL  fSpyed );
	int    PostDidAlloc( void *pRequest, BOOL  fSpyed, int   fActual );
	void  PreHeapMinimize();
	void  PostHeapMinimize();
}
alias IMallocSpy LPMALLOCSPY;

interface IStdMarshalInfo : IUnknown
{
	HRESULT GetClassForHandler( DWORD dwDestContext, void *pvDestContext, CLSID *pClsid );
}
alias IStdMarshalInfo LPSTDMARSHALINFO;

    // bit flags for IExternalConnection
enum EXTCONN
{
	EXTCONN_STRONG      = 0x0001,   // strong connection
	EXTCONN_WEAK        = 0x0002,   // weak connection (table, container)
	EXTCONN_CALLABLE    = 0x0004,   // table .vs. callable
}

interface IExternalConnection : IUnknown
{
    // *** IExternalConnection methods ***
	DWORD AddConnection( DWORD extconn, DWORD reserved );
	DWORD ReleaseConnection( DWORD extconn, DWORD reserved, BOOL  fLastReleaseCloses );
}
alias IExternalConnection LPEXTERNALCONNECTION;


struct MULTI_QI
{
	const IID  *pIID; // pass this one in
	IUnknown   pItf; // get these out (you must set to NULL before calling)
	HRESULT     hr;
}

interface IMultiQI : IUnknown
{
    HRESULT QueryMultipleInterfaces( ULONG      cMQIs, MULTI_QI  *pMQIs );
}
alias IMultiQI LPMULTIQI;

interface IEnumUnknown : IUnknown
{
	HRESULT Next( ULONG celt, IUnknown * rgelt, ULONG *pceltFetched);
	HRESULT Skip( ULONG celt );
	HRESULT Reset();
	HRESULT Clone( IEnumUnknown * ppenum );
}
alias IEnumUnknown LPENUMUNKNOWN;



/****************************************************************************
 *  Binding Interfaces
 ****************************************************************************/

struct BIND_OPTS {
    DWORD       cbStruct;       //  sizeof(BIND_OPTS)
    DWORD       grfFlags;
    DWORD       grfMode;
    DWORD       dwTickCountDeadline;
}
alias BIND_OPTS * LPBIND_OPTS;

struct BIND_OPTS2 {
    DWORD           cbStruct;       //  sizeof(BIND_OPTS2)
    DWORD           grfFlags;
    DWORD           grfMode;
    DWORD           dwTickCountDeadline;
    DWORD           dwTrackFlags;
    DWORD           dwClassContext;
    LCID            locale;
    COSERVERINFO *  pServerInfo;
}
alias BIND_OPTS2 * LPBIND_OPTS2;

enum BIND_FLAGS
{
	BIND_MAYBOTHERUSER = 1,
	BIND_JUSTTESTEXISTENCE = 2
}

interface IBindCtx : IUnknown
{
	HRESULT RegisterObjectBound( IUnknown  punk );
	HRESULT RevokeObjectBound( IUnknown punk );
	HRESULT ReleaseBoundObjects();
	HRESULT SetBindOptions( BIND_OPTS * pbindopts );
	HRESULT GetBindOptions( BIND_OPTS * pbindopts );
	HRESULT GetRunningObjectTable( IRunningObjectTable * pprot );
	HRESULT RegisterObjectParam( LPOLESTR pszKey, IUnknown punk );
	HRESULT GetObjectParam( LPOLESTR pszKey, IUnknown * ppunk );
	HRESULT EnumObjectParam( IEnumString * ppenum );
	HRESULT RevokeObjectParam( LPOLESTR pszKey );
}
alias IBindCtx LPBC;
alias IBindCtx LPBINDCTX;

interface IEnumMoniker : IUnknown
{
	HRESULT Next( ULONG celt, IMoniker * rgelt, ULONG *pceltFetched );
	HRESULT Skip( ULONG celt );
	HRESULT Reset();
	HRESULT Clone( IEnumMoniker * ppenum );
}
alias IEnumMoniker LPENUMMONIKER;

interface IRunnableObject : IUnknown
{
	HRESULT GetRunningClass( LPCLSID lpClsid );
	HRESULT Run( LPBINDCTX pbc );
	BOOL IsRunning();
	HRESULT LockRunning( BOOL fLock, BOOL fLastUnlockCloses );
	HRESULT SetContainedObject( BOOL fContained );
}
alias IRunnableObject LPRUNNABLEOBJECT;

interface IRunningObjectTable : IUnknown
{
	HRESULT Register( DWORD grfFlags, IUnknown punkObject, IMoniker pmkObjectName, DWORD *pdwRegister );
	HRESULT Revoke ( DWORD dwRegister );
	HRESULT IsRunning( IMoniker pmkObjectName );
	HRESULT GetObject( IMoniker pmkObjectName, IUnknown * ppunkObject );
	HRESULT NoteChangeTime( DWORD dwRegister, FILETIME *pfiletime );
	HRESULT GetTimeOfLastChange( IMoniker  pmkObjectName, FILETIME *pfiletime );
	HRESULT EnumRunning( IEnumMoniker * ppenumMoniker );
}
alias IRunningObjectTable LPRUNNINGOBJECTTABLE;

interface IPersist : IUnknown
{
	HRESULT GetClassID( CLSID * pClassID );
}
alias IPersist LPPERSIST;

interface IPersistStream : IPersist
{
	HRESULT IsDirty(  );
	HRESULT Load( IStream pStm );
	HRESULT Save( IStream pStm, BOOL fClearDirty );
	HRESULT GetSizeMax( ULARGE_INTEGER *pcbSize );
}
alias IPersistStream LPPERSISTSTREAM;

    // system moniker types; returned from IsSystemMoniker.
enum MKSYS
{
	MKSYS_NONE = 0,
	MKSYS_GENERICCOMPOSITE = 1,
	MKSYS_FILEMONIKER = 2,
	MKSYS_ANTIMONIKER = 3,
	MKSYS_ITEMMONIKER = 4,
	MKSYS_POINTERMONIKER = 5,
    //  MKSYS_URLMONIKER = 6,
	MKSYS_CLASSMONIKER = 7
}

enum MKREDUCE
{
	MKRREDUCE_ONE           =   3<<16,
	MKRREDUCE_TOUSER        =   2<<16,
	MKRREDUCE_THROUGHUSER   =   1<<16,
	MKRREDUCE_ALL           =   0
}

interface IMoniker : IPersistStream
{
	HRESULT BindToObject( IBindCtx pbc, IMoniker pmkToLeft, REFIID riidResult, void **ppvResult );
	HRESULT BindToStorage( IBindCtx pbc, IMoniker pmkToLeft, REFIID riid, void * ppvObj );
	HRESULT Reduce( IBindCtx pbc, DWORD dwReduceHowFar, IMoniker * ppmkToLeft, IMoniker * ppmkReduced );
	HRESULT ComposeWith( IMoniker pmkRight, BOOL fOnlyIfNotGeneric, IMoniker * ppmkComposite );
	HRESULT Enum( BOOL fForward, IEnumMoniker * ppenumMoniker );
	HRESULT IsEqual( IMoniker pmkOtherMoniker );
	HRESULT Hash( DWORD *pdwHash );
	HRESULT IsRunning( IBindCtx pbc, IMoniker pmkToLeft, IMoniker pmkNewlyRunning );
	HRESULT GetTimeOfLastChange( IBindCtx pbc, IMoniker pmkToLeft, FILETIME *pFileTime );
	HRESULT Inverse( IMoniker * ppmk );
	HRESULT CommonPrefixWith( IMoniker pmkOther, IMoniker * ppmkPrefix );
	HRESULT RelativePathTo( IMoniker pmkOther, IMoniker * ppmkRelPath );
	HRESULT GetDisplayName( IBindCtx pbc, IMoniker pmkToLeft, LPOLESTR *ppszDisplayName );
	HRESULT ParseDisplayName( IBindCtx pbc, IMoniker pmkToLeft, LPOLESTR pszDisplayName, ULONG *pchEaten,	IMoniker * ppmkOut );
	HRESULT IsSystemMoniker( DWORD * pdwMksys );
}
alias IMoniker LPMONIKER;

interface IROTData : IUnknown
{
	HRESULT GetComparisonData( byte * pbData, ULONG cbMax, ULONG *pcbData );
}

interface IEnumString : IUnknown
{
	HRESULT Next( ULONG celt, LPOLESTR *rgelt, ULONG *pceltFetched );
	HRESULT Skip( ULONG celt );
	HRESULT Reset();
	HRESULT Clone( IEnumString * ppenum );
}
alias IEnumString LPENUMSTRING;


/****************************************************************************
 *  Structured Storage Interfaces
 ****************************************************************************/

interface ISequentialStream : IUnknown
{
	HRESULT Read( void *pv, ULONG cb, ULONG *pcbRead );
	HRESULT Write( void *pv, ULONG cb, ULONG *pcbWritten );
}

    /* Storage stat buffer */
struct STATSTG
{
        LPOLESTR pwcsName;
        DWORD type;
        ULARGE_INTEGER cbSize;
        FILETIME mtime;
        FILETIME ctime;
        FILETIME atime;
        DWORD grfMode;
        DWORD grfLocksSupported;
        CLSID clsid;
        DWORD grfStateBits;
    DWORD reserved;
}

    /* Storage element types */
enum STGTY
{
	STGTY_STORAGE   = 1,
	STGTY_STREAM    = 2,
	STGTY_LOCKBYTES = 3,
	STGTY_PROPERTY  = 4
}

enum STREAM_SEEK
{
        STREAM_SEEK_SET = 0,
        STREAM_SEEK_CUR = 1,
        STREAM_SEEK_END = 2
}

enum LOCKTYPE
{
        LOCK_WRITE      = 1,
        LOCK_EXCLUSIVE  = 2,
        LOCK_ONLYONCE   = 4
}

interface IStream : ISequentialStream
{
	HRESULT Seek( LARGE_INTEGER dlibMove, DWORD dwOrigin, ULARGE_INTEGER *plibNewPosition );
	HRESULT SetSize( ULARGE_INTEGER libNewSize );
	HRESULT CopyTo( IStream pstm, ULARGE_INTEGER cb, ULARGE_INTEGER *pcbRead, ULARGE_INTEGER *pcbWritten);
	HRESULT Commit( DWORD grfCommitFlags );
	HRESULT Revert();
	HRESULT LockRegion( ULARGE_INTEGER libOffset, ULARGE_INTEGER cb, DWORD dwLockType );
	HRESULT UnlockRegion( ULARGE_INTEGER libOffset, ULARGE_INTEGER cb, DWORD dwLockType );
	HRESULT Stat( STATSTG *pstatstg, DWORD grfStatFlag);
	HRESULT Clone( IStream * ppstm );
}
alias IStream LPSTREAM;

interface IEnumSTATSTG : IUnknown
{
	HRESULT Next( ULONG celt, STATSTG *rgelt, ULONG *pceltFetched );
	HRESULT Skip( ULONG celt );
	HRESULT Reset();
	HRESULT Clone( IEnumSTATSTG * ppenum );
}
alias IEnumSTATSTG LPENUMSTATSTG;

struct RemSNB
{
	ULONG ulCntStr;
	ULONG ulCntChar;
	OLECHAR[] rgString;
}
alias RemSNB * wireSNB;
alias OLECHAR ** SNB;

interface IStorage : IUnknown
{
	HRESULT CreateStream( LPCOLESTR pwcsName, DWORD grfMode, DWORD reserved1, DWORD reserved2, IStream * ppstm);
   HRESULT OpenStream( LPCOLESTR pwcsName, void *reserved1, DWORD grfMode, DWORD reserved2, IStream * ppstm);
   HRESULT CreateStorage( LPCOLESTR pwcsName, DWORD grfMode, DWORD reserved1, DWORD reserved2, IStorage * ppstg);
   HRESULT OpenStorage( LPCOLESTR pwcsName, IStorage pstgPriority, DWORD grfMode, SNB snbExclude, DWORD reserved, IStorage * ppstg );
   HRESULT CopyTo( DWORD ciidExclude, IID *rgiidExclude, SNB snbExclude, IStorage pstgDest );
	HRESULT MoveElementTo( LPCOLESTR  pwcsName, IStorage pstgDest, LPCOLESTR pwcsNewName, DWORD grfFlags );
	HRESULT Commit( DWORD grfCommitFlags );
	HRESULT Revert();
	HRESULT EnumElements( DWORD reserved1, void *reserved2, DWORD reserved3, IEnumSTATSTG * ppenum);
	HRESULT DestroyElement( LPCOLESTR  pwcsName );
	HRESULT RenameElement( LPCOLESTR pwcsOldName, LPCOLESTR pwcsNewName );
	HRESULT SetElementTimes( LPCOLESTR  pwcsName, FILETIME * pctime, FILETIME *patime, FILETIME *pmtime );
	HRESULT SetClass( REFCLSID clsid );
	HRESULT SetStateBits( DWORD grfStateBits, DWORD grfMask );
	HRESULT Stat( STATSTG *pstatstg, DWORD grfStatFlag );
}
alias IStorage LPSTORAGE;

interface IPersistFile : IPersist
{
	HRESULT IsDirty();
	HRESULT Load(LPCOLESTR pszFileName,DWORD dwMode);
	HRESULT Save(LPCOLESTR pszFileName,BOOL fRemember);
	HRESULT SaveCompleted(LPCOLESTR pszFileName);
	HRESULT GetCurFile(LPOLESTR *ppszFileName );
}
alias IPersistFile LPPERSISTFILE;

interface IPersistStorage : IPersist
{
	HRESULT IsDirty();
	HRESULT InitNew(IStorage pStg);
	HRESULT Load(IStorage pStg);
	HRESULT Save(IStorage pStgSave,BOOL fSameAsLoad);
	HRESULT SaveCompleted(IStorage pStgNew);
	HRESULT HandsOffStorage();
}
alias IPersistStorage LPPERSISTSTORAGE;

interface ILockBytes : IUnknown
{
    HRESULT ReadAt(
ULARGE_INTEGER ulOffset,
void *pv,
ULONG cb,
ULONG *pcbRead);

    HRESULT WriteAt(
ULARGE_INTEGER ulOffset,
void  *pv,
ULONG cb,
ULONG *pcbWritten);

HRESULT Flush();

HRESULT SetSize(
ULARGE_INTEGER cb);

    HRESULT LockRegion(
ULARGE_INTEGER libOffset,
ULARGE_INTEGER cb,
DWORD dwLockType);

    HRESULT UnlockRegion(
ULARGE_INTEGER libOffset,
ULARGE_INTEGER cb,
DWORD dwLockType);

    HRESULT Stat(
STATSTG *pstatstg,
DWORD grfStatFlag);
}
alias ILockBytes LPLOCKBYTES;

struct DVTARGETDEVICE {
        DWORD tdSize;
        WORD tdDriverNameOffset;
        WORD tdDeviceNameOffset;
        WORD tdPortNameOffset;
        WORD tdExtDevmodeOffset;
BYTE[1] tdData;
}

alias CLIPFORMAT LPCLIPFORMAT;

struct FORMATETC {
        CLIPFORMAT cfFormat;
DVTARGETDEVICE * ptd;
        DWORD dwAspect;
        LONG lindex;
        DWORD tymed;
}
alias FORMATETC *LPFORMATETC;

interface IEnumFORMATETC : IUnknown
{
    HRESULT Next(
ULONG celt,
        FORMATETC *rgelt,
ULONG *pceltFetched);

    HRESULT Skip(
ULONG celt);

    HRESULT Reset();

    HRESULT Clone(
IEnumFORMATETC * ppenum);
}
alias IEnumFORMATETC LPENUMFORMATETC;

    //Advise Flags
enum ADVF
{
        ADVF_NODATA = 1,
        ADVF_PRIMEFIRST = 2,
        ADVF_ONLYONCE = 4,
        ADVF_DATAONSTOP = 64,
        ADVFCACHE_NOHANDLER = 8,
        ADVFCACHE_FORCEBUILTIN = 16,
        ADVFCACHE_ONSAVE = 32
}

    // Stats for data; used by several enumerations and by at least one
    // implementation of IDataAdviseHolder; if a field is not used, it
    // will be NULL.

struct STATDATA
{                              // field used by:
	FORMATETC formatetc;       // EnumAdvise, EnumData (cache), EnumFormats
	DWORD advf;                // EnumAdvise, EnumData (cache)
	IAdviseSink pAdvSink; // EnumAdvise
	DWORD dwConnection;        // EnumAdvise
}
alias STATDATA * LPSTATDATA;

interface IEnumSTATDATA : IUnknown
{
    HRESULT Next(
ULONG celt,
        STATDATA *rgelt,
ULONG *pceltFetched);


    HRESULT Skip(
ULONG celt);

    HRESULT Reset();

    HRESULT Clone(
IEnumSTATDATA * ppenum);
}
alias IEnumSTATDATA LPENUMSTATDATA;

interface IRootStorage : IUnknown
{
    HRESULT SwitchToFile( LPOLESTR pszFile    );
}
alias IRootStorage LPROOTSTORAGE;


/****************************************************************************
 *  Notification Interfaces
 ****************************************************************************/

enum TYMED {
        TYMED_HGLOBAL = 1,
        TYMED_FILE = 2,
        TYMED_ISTREAM = 4,
        TYMED_ISTORAGE = 8,
        TYMED_GDI = 16,
        TYMED_MFPICT = 32,
        TYMED_ENHMF = 64,
        TYMED_NULL = 0
}

struct RemSTGMEDIUM {
        DWORD tymed;
        DWORD dwHandleType;
        ULONG pData;
        ULONG pUnkForRelease;
        ULONG cbData;
        byte[1] data;
}

union UNION_u {
	HBITMAP hBitmap;
	HMETAFILEPICT hMetaFilePict;
	HENHMETAFILE hEnhMetaFile;
	HGLOBAL hGlobal;
	LPOLESTR lpszFileName;
	IStream pstm;
	IStorage pstg;
}
/*
struct uSTGMEDIUM {
	DWORD tymed;
	UNION_u u;
	IUnknown pUnkForRelease;
}
*/
// <Shawn Liu> modified
struct uSTGMEDIUM {
	DWORD tymed;
	void* unionField;
	IUnknown pUnkForRelease;
}


enum {
	OBJ_PEN             =1,
	OBJ_BRUSH           =2,
	OBJ_DC              =3,
	OBJ_METADC          =4,
	OBJ_PAL             =5,
	OBJ_FONT            =6,
	OBJ_BITMAP          =7,
	OBJ_REGION          =8,
	OBJ_METAFILE        =9,
	OBJ_MEMDC           =10,
	OBJ_EXTPEN          =11,
	OBJ_ENHMETADC       =12,
	OBJ_ENHMETAFILE     =13
}
union __MIDL_IAdviseSink_0002
{
		wireHBITMAP hBitmap;
		wireHPALETTE hPalette;
		wireHGLOBAL hGeneric;
}

struct GDI_OBJECT
{
	DWORD ObjectType;
   __MIDL_IAdviseSink_0002 u;
}

union __MIDL_IAdviseSink_0003
{
			wireHMETAFILEPICT hMetaFilePict;
			wireHENHMETAFILE hHEnhMetaFile;
			GDI_OBJECT  *hGdiHandle;
			wireHGLOBAL hGlobal;
			LPOLESTR lpszFileName;
			BYTE_BLOB  *pstm;
			BYTE_BLOB  *pstg;
}

struct  userSTGMEDIUM
{
   DWORD tymed;
   __MIDL_IAdviseSink_0003 u;
	IUnknown pUnkForRelease;
}

alias userSTGMEDIUM *wireSTGMEDIUM;
alias uSTGMEDIUM STGMEDIUM;
alias userSTGMEDIUM *wireASYNC_STGMEDIUM;
alias STGMEDIUM ASYNC_STGMEDIUM;
alias STGMEDIUM *LPSTGMEDIUM;

struct  userFLAG_STGMEDIUM
{
    LONG ContextFlags;
    LONG fPassOwnership;
	userSTGMEDIUM Stgmed;
}

alias userFLAG_STGMEDIUM *wireFLAG_STGMEDIUM;

struct  FLAG_STGMEDIUM
{
	LONG ContextFlags;
	LONG fPassOwnership;
	STGMEDIUM Stgmed;
}


interface IAdviseSink : IUnknown
{
    void OnDataChange(FORMATETC *pFormatetc,STGMEDIUM *pStgmed);
    void OnViewChange(DWORD dwAspect,LONG lindex);
    void OnRename(IMoniker pmk);
    void OnSave();
    void OnClose();
}
alias IAdviseSink LPADVISESINK;

interface IAdviseSink2 : IAdviseSink
{
    void OnLinkSrcChange( IMoniker pmk );
}
alias IAdviseSink2 LPADVISESINK2;


enum DATADIR
{
	DATADIR_GET = 1,
	DATADIR_SET = 2
}

interface IDataObject : IUnknown
{

    HRESULT GetData( FORMATETC *pformatetcIn, STGMEDIUM *pmedium);

    HRESULT GetDataHere( FORMATETC *pformatetc, STGMEDIUM *pmedium);

    HRESULT QueryGetData(	FORMATETC *pformatetc);

    HRESULT GetCanonicalFormatEtc(
			FORMATETC *pformatectIn,
			FORMATETC *pformatetcOut);

    HRESULT SetData(
		FORMATETC *pformatetc,
		STGMEDIUM *pmedium,
			BOOL fRelease);

    HRESULT EnumFormatEtc(
			DWORD dwDirection,
			IEnumFORMATETC * ppenumFormatEtc);

    HRESULT DAdvise(
		FORMATETC *pformatetc,
		DWORD advf,
		IAdviseSink pAdvSink,
		DWORD *pdwConnection);

    HRESULT DUnadvise(DWORD dwConnection);

    HRESULT EnumDAdvise(IEnumSTATDATA * ppenumAdvise);

}
alias IDataObject LPDATAOBJECT;

interface IDataAdviseHolder : IUnknown
{
    HRESULT Advise
    (
	IDataObject pDataObject,
	FORMATETC *pFetc,
	DWORD advf,
	IAdviseSink pAdvise,
	DWORD *pdwConnection
    );

    HRESULT Unadvise
    (
	DWORD dwConnection
    );

    HRESULT EnumAdvise
    (
IEnumSTATDATA * ppenumAdvise
    );

    HRESULT SendOnDataChange
    (
		IDataObject pDataObject,
		DWORD dwReserved,
		DWORD advf
    );

}
alias IDataAdviseHolder LPDATAADVISEHOLDER;


// call type used by IMessageFilter::HandleIncomingMessage
enum CALLTYPE
{
    CALLTYPE_TOPLEVEL = 1,      // toplevel call - no outgoing call
    CALLTYPE_NESTED   = 2,      // callback on behalf of previous outgoing call - should always handle
    CALLTYPE_ASYNC    = 3,      // aysnchronous call - can NOT be rejected
    CALLTYPE_TOPLEVEL_CALLPENDING = 4,  // new toplevel call with new LID
    CALLTYPE_ASYNC_CALLPENDING    = 5   // async call - can NOT be rejected
}

// status of server call - returned by IMessageFilter::HandleIncomingCall
// and passed to  IMessageFilter::RetryRejectedCall
enum SERVERCALL
{
    SERVERCALL_ISHANDLED    = 0,
    SERVERCALL_REJECTED     = 1,
    SERVERCALL_RETRYLATER   = 2
}

// Pending type indicates the level of nesting
enum PENDINGTYPE
{
    PENDINGTYPE_TOPLEVEL = 1, // toplevel call
    PENDINGTYPE_NESTED   = 2  // nested call
}

// return values of MessagePending
enum PENDINGMSG
{
    PENDINGMSG_CANCELCALL  = 0, // cancel the outgoing call
    PENDINGMSG_WAITNOPROCESS  = 1, // wait for the return and don't dispatch the message
    PENDINGMSG_WAITDEFPROCESS = 2  // wait and dispatch the message

}

// additional interface information about the incoming call
struct INTERFACEINFO
{
    IUnknown    pUnk;      // the pointer to the object
    IID         iid;        // interface id
    WORD        wMethod;    // interface method
}
alias INTERFACEINFO *LPINTERFACEINFO;


interface IMessageFilter : IUnknown
{

    DWORD HandleInComingCall
    (
DWORD dwCallType,
HTASK htaskCaller,
DWORD dwTickCount,
LPINTERFACEINFO lpInterfaceInfo
    );

    DWORD RetryRejectedCall
    (
HTASK htaskCallee,
DWORD dwTickCount,
DWORD dwRejectType
    );

    DWORD MessagePending
    (
HTASK htaskCallee,
DWORD dwTickCount,
DWORD dwPendingType
    );
}
alias IMessageFilter LPMESSAGEFILTER;



/****************************************************************************
 *  Object Remoting Interfaces
 ****************************************************************************/
/*
interface IRpcChannelBuffer : IUnknown
{

    typedef unsigned long RPCOLEDATAREP;

    typedef struct tagRPCOLEMESSAGE
    {
        void             *reserved1;
        RPCOLEDATAREP     dataRepresentation;
        void             *Buffer;
        ULONG             cbBuffer;
        ULONG             iMethod;
        void             *reserved2[5];
        ULONG             rpcFlags;
    } RPCOLEMESSAGE;

    typedef RPCOLEMESSAGE *PRPCOLEMESSAGE;

    HRESULT GetBuffer
    (
        [in] RPCOLEMESSAGE *pMessage,
        [in] REFIID riid
    );

    HRESULT SendReceive
    (
        [in,out] RPCOLEMESSAGE *pMessage,
        [out] ULONG *pStatus
    );

    HRESULT FreeBuffer
    (
        [in] RPCOLEMESSAGE *pMessage
    );

    HRESULT GetDestCtx
    (
        [out] DWORD *pdwDestContext,
        [out] void **ppvDestContext
    );

    HRESULT IsConnected
    (
        void
    );

}

[
    local,
    object,
    uuid(594f31d0-7f19-11d0-b194-00a0c90dc8bf)
]
interface IRpcChannelBuffer2 : IRpcChannelBuffer
{

    HRESULT GetProtocolVersion
    (
        [in,out] DWORD *pdwVersion
    );
}

[
    local,
    object,
    uuid(25B15600-0115-11d0-BF0D-00AA00B8DFD2)
]
interface IRpcChannelBuffer3 : IRpcChannelBuffer2
{

    HRESULT Send
    (
        [in,out] RPCOLEMESSAGE *pMsg,
        [out]    ULONG *pulStatus
    );

    HRESULT Receive
    (
        [in,out] RPCOLEMESSAGE *pMsg,
        [in]     ULONG ulSize,
        [out]    ULONG *pulStatus
    );

    HRESULT Cancel
    (
        [in] RPCOLEMESSAGE *pMsg
    );

    HRESULT GetCallContext
    (
        [in]  RPCOLEMESSAGE *pMsg,
        [in]  REFIID riid,
        [out] void **pInterface
    );

    HRESULT GetDestCtxEx
    (
        [in] RPCOLEMESSAGE *pMsg,
        [out] DWORD *pdwDestContext,
        [out] void **ppvDestContext
    );

    HRESULT GetState
    (
        [in]  RPCOLEMESSAGE   *pMsg,
        [out] DWORD           *pState
    );

    HRESULT RegisterAsync
    (
        [in] RPCOLEMESSAGE *pMsg,
        [in] IAsyncManager *pAsyncMgr
    );

}


[
    local,
    object,
    uuid(D5F56A34-593B-101A-B569-08002B2DBF7A)
]
interface IRpcProxyBuffer : IUnknown
{

    HRESULT Connect
    (
        [in, unique] IRpcChannelBuffer *pRpcChannelBuffer
    );

    void Disconnect
    (
        void
    );

}

[
    local,
    object,
    uuid(D5F56AFC-593B-101A-B569-08002B2DBF7A)
]
interface IRpcStubBuffer : IUnknown
{

    HRESULT Connect
    (
        [in] IUnknown *pUnkServer
    );

    void Disconnect();

    HRESULT Invoke
    (
        [in] RPCOLEMESSAGE *_prpcmsg,
        [in] IRpcChannelBuffer *_pRpcChannelBuffer
    );

    IRpcStubBuffer *IsIIDSupported
    (
        [in] REFIID riid
    );

    ULONG CountRefs
    (
        void
    );

    HRESULT DebugServerQueryInterface
    (
        void **ppv
    );

    void DebugServerRelease
    (
        void *pv
    );

}



[
    local,
    object,
    uuid(D5F569D0-593B-101A-B569-08002B2DBF7A)
]
interface IPSFactoryBuffer : IUnknown
{

    HRESULT CreateProxy
    (
        [in] IUnknown *pUnkOuter,
        [in] REFIID riid,
        [out] IRpcProxyBuffer **ppProxy,
        [out] void **ppv
    );

    HRESULT CreateStub
    (
        [in] REFIID riid,
        [in, unique] IUnknown *pUnkServer,
        [out] IRpcStubBuffer **ppStub
    );
}

cpp_quote( "#if  (_WIN32_WINNT >= 0x0400 ) || defined(_WIN32_DCOM) // DCOM" )
cpp_quote( "// This interface is only valid on Windows NT 4.0" )

// This structure contains additional data for hooks.  As a backward
// compatability hack, the entire structure is passed in place of the
// RIID parameter on all hook methods.  Thus the IID must be the first
// parameter.  As a forward compatability hack the second field is the
// current size of the structure.
typedef struct SChannelHookCallInfo
{
    IID               iid;
    DWORD             cbSize;
    GUID              uCausality;
    DWORD             dwServerPid;
    DWORD             iMethod;
    void             *pObject;
} SChannelHookCallInfo;

[
    local,
    object,
    uuid(1008c4a0-7613-11cf-9af1-0020af6e72f4)
]
interface IChannelHook : IUnknown
{
    void ClientGetSize(
        [in]  REFGUID uExtent,
        [in]  REFIID  riid,
        [out] ULONG  *pDataSize );

    void ClientFillBuffer(
        [in]      REFGUID uExtent,
        [in]      REFIID  riid,
        [in, out] ULONG  *pDataSize,
        [in]      void   *pDataBuffer );

    void ClientNotify(
        [in] REFGUID uExtent,
        [in] REFIID  riid,
        [in] ULONG   cbDataSize,
        [in] void   *pDataBuffer,
        [in] DWORD   lDataRep,
        [in] HRESULT hrFault );

    void ServerNotify(
        [in] REFGUID uExtent,
        [in] REFIID  riid,
        [in] ULONG   cbDataSize,
        [in] void   *pDataBuffer,
        [in] DWORD   lDataRep );

    void ServerGetSize(
        [in]  REFGUID uExtent,
        [in]  REFIID  riid,
        [in]  HRESULT hrFault,
        [out] ULONG  *pDataSize );

    void ServerFillBuffer(
        [in]      REFGUID uExtent,
        [in]      REFIID  riid,
        [in, out] ULONG  *pDataSize,
        [in]      void   *pDataBuffer,
        [in]      HRESULT hrFault );
};

cpp_quote( "#endif //DCOM" )
*/

/****************************************************************************
 *  Property Storage Interfaces
 ****************************************************************************/

 /*
interface IPropertyStorage;
interface IEnumSTATPROPSTG;
interface IEnumSTATPROPSETSTG;

[
    object,
    uuid(00000138-0000-0000-C000-000000000046),
    pointer_default(unique)
]

interface IPropertyStorage : IUnknown
{

    cpp_quote("")
    cpp_quote("// Well-known Property Set Format IDs")
    extern const FMTID FMTID_SummaryInformation;
    extern const FMTID FMTID_DocSummaryInformation;
    extern const FMTID FMTID_UserDefinedProperties;

    cpp_quote("")
    cpp_quote("// Flags for IPropertySetStorage::Create")
    const DWORD PROPSETFLAG_DEFAULT = 0;
    const DWORD PROPSETFLAG_NONSIMPLE = 1;
    const DWORD PROPSETFLAG_ANSI = 2;
    cpp_quote("// This flag is only supported on StgCreatePropStg & StgOpenPropStg")
    const DWORD PROPSETFLAG_UNBUFFERED = 4;

    typedef [unique] IPropertyStorage * LPPROPERTYSTORAGE;

    typedef struct tagPROPVARIANT PROPVARIANT;

    #define TYPEDEF_CA(type, name) \
        typedef struct tag##name\
        {\
            ULONG   cElems;\
            [size_is( cElems )]\
            type *  pElems;\
        } name

    TYPEDEF_CA(unsigned char,       CAUB);
    TYPEDEF_CA(short,               CAI);
    TYPEDEF_CA(USHORT,              CAUI);
    TYPEDEF_CA(long,                CAL);
    TYPEDEF_CA(ULONG,               CAUL);
    TYPEDEF_CA(float,               CAFLT);
    TYPEDEF_CA(double,              CADBL);
    TYPEDEF_CA(CY,                  CACY);
    TYPEDEF_CA(DATE,                CADATE);
    TYPEDEF_CA(BSTR,                CABSTR);
    TYPEDEF_CA(BSTRBLOB,            CABSTRBLOB);
    TYPEDEF_CA(VARIANT_BOOL,        CABOOL);
    TYPEDEF_CA(SCODE,               CASCODE);
    TYPEDEF_CA(PROPVARIANT,         CAPROPVARIANT);
    TYPEDEF_CA(LARGE_INTEGER,       CAH);
    TYPEDEF_CA(ULARGE_INTEGER,      CAUH);
    TYPEDEF_CA(LPSTR,               CALPSTR);
    TYPEDEF_CA(LPWSTR,              CALPWSTR);
    TYPEDEF_CA(FILETIME,            CAFILETIME);
    TYPEDEF_CA(CLIPDATA,            CACLIPDATA);
    TYPEDEF_CA(CLSID,               CACLSID);

cpp_quote("// Disable the warning about the obsolete member named 'bool'")
cpp_quote("// 'bool', 'true', 'false', 'mutable', 'explicit', & 'typename'")
cpp_quote("// are reserved keywords")
cpp_quote("#pragma warning(disable:4237)")

    struct tagPROPVARIANT
    {
        VARTYPE vt;
        WORD    wReserved1;
        WORD    wReserved2;
        WORD    wReserved3;
        [switch_is((unsigned short) (vt & 0x1fff))] union
        {
            [case(VT_EMPTY, VT_NULL)]
                ;
            [case(VT_UI1)]
                UCHAR               bVal;
            [case(VT_I2)]
                short               iVal;
            [case(VT_UI2)]
                USHORT              uiVal;
            [case(VT_BOOL)]
                VARIANT_BOOL        boolVal;
            [case(VT_ILLEGAL)]  // obsolete field name; use boolVal
                _VARIANT_BOOL        bool;
            [case(VT_I4)]
                long                lVal;
            [case(VT_UI4)]
                ULONG               ulVal;
            [case(VT_R4)]
                float               fltVal;
            [case(VT_ERROR)]
                SCODE               scode;
            [case(VT_I8)]
                LARGE_INTEGER       hVal;
            [case(VT_UI8)]
                ULARGE_INTEGER      uhVal;
            [case(VT_R8)]
                double              dblVal;
            [case(VT_CY)]
                CY                  cyVal;
            [case(VT_DATE)]
                DATE                date;
            [case(VT_FILETIME)]
                FILETIME            filetime;
            [case(VT_CLSID)]
                CLSID *             puuid;
            [case(VT_BLOB, VT_BLOB_OBJECT)]
                BLOB                blob;
            [case(VT_CF)]
                CLIPDATA            *pclipdata;
            [case(VT_STREAM, VT_STREAMED_OBJECT)]
                IStream *           pStream;
            [case(VT_STORAGE, VT_STORED_OBJECT)]
                IStorage *          pStorage;
            [case(VT_BSTR)]
                BSTR                bstrVal;
            [case(VT_BSTR_BLOB)]        // System use only
                BSTRBLOB            bstrblobVal;
            [case(VT_LPSTR)]
                LPSTR               pszVal;
            [case(VT_LPWSTR)]
                LPWSTR              pwszVal;
            [case(VT_UI1|VT_VECTOR)]
                CAUB                caub;
            [case(VT_I2|VT_VECTOR)]
                CAI                 cai;
            [case(VT_UI2|VT_VECTOR)]
                CAUI                caui;
            [case(VT_BOOL|VT_VECTOR)]
                CABOOL              cabool;
            [case(VT_I4|VT_VECTOR)]
                CAL                 cal;
            [case(VT_UI4|VT_VECTOR)]
                CAUL                caul;
            [case(VT_R4|VT_VECTOR)]
                CAFLT               caflt;
            [case(VT_ERROR|VT_VECTOR)]
                CASCODE             cascode;
            [case(VT_I8|VT_VECTOR)]
                CAH                 cah;
            [case(VT_UI8|VT_VECTOR)]
                CAUH                cauh;
            [case(VT_R8|VT_VECTOR)]
                CADBL               cadbl;
            [case(VT_CY|VT_VECTOR)]
                CACY                cacy;
            [case(VT_DATE|VT_VECTOR)]
                CADATE              cadate;
            [case(VT_FILETIME|VT_VECTOR)]
                CAFILETIME          cafiletime;
            [case(VT_CLSID|VT_VECTOR)]
                CACLSID             cauuid;
            [case(VT_CF|VT_VECTOR)]
                CACLIPDATA          caclipdata;
            [case(VT_BSTR|VT_VECTOR)]
                CABSTR              cabstr;
            [case(VT_BSTR_BLOB|VT_VECTOR)]  // System use only
                CABSTRBLOB          cabstrblob;
            [case(VT_LPSTR|VT_VECTOR)]
                CALPSTR             calpstr;
            [case(VT_LPWSTR|VT_VECTOR)]
                CALPWSTR            calpwstr;
            [case(VT_VARIANT|VT_VECTOR)]
                CAPROPVARIANT       capropvar;
        };
    };

    typedef struct tagPROPVARIANT * LPPROPVARIANT;

    cpp_quote("// Reserved global Property IDs")
    const PROPID PID_DICTIONARY         = 0x00000000;
    const PROPID PID_CODEPAGE           = 0x00000001;
    const PROPID PID_FIRST_USABLE       = 0x00000002;
    const PROPID PID_FIRST_NAME_DEFAULT = 0x00000fff;
    const PROPID PID_LOCALE             = 0x80000000;
    const PROPID PID_MODIFY_TIME        = 0x80000001;
    const PROPID PID_SECURITY           = 0x80000002;
    const PROPID PID_ILLEGAL            = 0xffffffff;


    cpp_quote("// Property IDs for the SummaryInformation Property Set")
    cpp_quote("")
    cpp_quote("#define PIDSI_TITLE               0x00000002L  // VT_LPSTR")
    cpp_quote("#define PIDSI_SUBJECT             0x00000003L  // VT_LPSTR")
    cpp_quote("#define PIDSI_AUTHOR              0x00000004L  // VT_LPSTR")
    cpp_quote("#define PIDSI_KEYWORDS            0x00000005L  // VT_LPSTR")
    cpp_quote("#define PIDSI_COMMENTS            0x00000006L  // VT_LPSTR")
    cpp_quote("#define PIDSI_TEMPLATE            0x00000007L  // VT_LPSTR")
    cpp_quote("#define PIDSI_LASTAUTHOR          0x00000008L  // VT_LPSTR")
    cpp_quote("#define PIDSI_REVNUMBER           0x00000009L  // VT_LPSTR")
    cpp_quote("#define PIDSI_EDITTIME            0x0000000aL  // VT_FILETIME (UTC)")
    cpp_quote("#define PIDSI_LASTPRINTED         0x0000000bL  // VT_FILETIME (UTC)")
    cpp_quote("#define PIDSI_CREATE_DTM          0x0000000cL  // VT_FILETIME (UTC)")
    cpp_quote("#define PIDSI_LASTSAVE_DTM        0x0000000dL  // VT_FILETIME (UTC)")
    cpp_quote("#define PIDSI_PAGECOUNT           0x0000000eL  // VT_I4")
    cpp_quote("#define PIDSI_WORDCOUNT           0x0000000fL  // VT_I4")
    cpp_quote("#define PIDSI_CHARCOUNT           0x00000010L  // VT_I4")
    cpp_quote("#define PIDSI_THUMBNAIL           0x00000011L  // VT_CF")
    cpp_quote("#define PIDSI_APPNAME             0x00000012L  // VT_LPSTR")
    cpp_quote("#define PIDSI_DOC_SECURITY        0x00000013L  // VT_I4")

    const ULONG PRSPEC_INVALID = 0xffffffff;
    const ULONG PRSPEC_LPWSTR = 0;
    const ULONG PRSPEC_PROPID = 1;

    typedef struct tagPROPSPEC
    {

        ULONG   ulKind;
        [switch_is(ulKind)] union
        {
            [case(PRSPEC_PROPID)]
                PROPID      propid;
            [case(PRSPEC_LPWSTR)]
                LPOLESTR    lpwstr;
            [default] ;
        } ;

    } PROPSPEC;

    typedef struct tagSTATPROPSTG
    {

        LPOLESTR    lpwstrName;
        PROPID      propid;
        VARTYPE     vt;

    } STATPROPSTG;

    cpp_quote("// Macros for parsing the OS Version of the Property Set Header")
    cpp_quote("#define PROPSETHDR_OSVER_KIND(dwOSVer)      HIWORD( (dwOSVer) )")
    cpp_quote("#define PROPSETHDR_OSVER_MAJOR(dwOSVer)     LOBYTE(LOWORD( (dwOSVer) ))")
    cpp_quote("#define PROPSETHDR_OSVER_MINOR(dwOSVer)     HIBYTE(LOWORD( (dwOSVer) ))")
    cpp_quote("#define PROPSETHDR_OSVERSION_UNKNOWN        0xFFFFFFFF")


    typedef struct tagSTATPROPSETSTG
    {

        FMTID       fmtid;
        CLSID       clsid;
        DWORD       grfFlags;
        FILETIME    mtime;
        FILETIME    ctime;
        FILETIME    atime;
        DWORD       dwOSVersion;

    } STATPROPSETSTG;


    // When this IDL file is used for "IProp.dll" (the
    // standalone property set DLL), we must have local
    // and remotable routines (call_as routines are used
    // to remove BSTRs, which are not remotable with some
    // RPC run-times).
    //
    // For the remotable routines, we must use pointer
    // parameters (e.g. "*rgspec" rather than "rgspec[]")
    // so that the MIDL 2.0 compiler will generate an
    // interpereted proxy/stub, rather than inline.

#ifdef IPROPERTY_DLL
    [local]
#endif
    HRESULT ReadMultiple(
        [in]    ULONG                   cpspec,
        [in, size_is(cpspec)]
                const PROPSPEC          rgpspec[],
        [out, size_is(cpspec)]
                PROPVARIANT             rgpropvar[]
        );

#ifdef IPROPERTY_DLL
    [call_as(ReadMultiple)]
    HRESULT RemoteReadMultiple(
        [out]   BOOL                    *pfBstrPresent,
        [in]    ULONG                   cpspec,
        [in, size_is(cpspec)]
                const PROPSPEC          *rgpspec,
        [out, size_is(cpspec)]
                PROPVARIANT             *rgpropvar
        );
#endif

#ifdef IPROPERTY_DLL
    [local]
#endif
    HRESULT WriteMultiple(
        [in]    ULONG                   cpspec,
        [in, size_is(cpspec)]
                const PROPSPEC          rgpspec[],
        [in, size_is(cpspec)]
                const PROPVARIANT       rgpropvar[],
        [in]    PROPID                  propidNameFirst
        );

#ifdef IPROPERTY_DLL
    [call_as(WriteMultiple)]
    HRESULT RemoteWriteMultiple(
        [in]    BOOL                    fBstrPresent,
        [in]    ULONG                   cpspec,
        [in, size_is(cpspec)]
                const PROPSPEC          *rgpspec,
        [in, size_is(cpspec)]
                const PROPVARIANT       *rgpropvar,
        [in]    PROPID                  propidNameFirst
        );
#endif

#ifdef IPROPERTY_DLL
    [local]
#endif
    HRESULT DeleteMultiple(
        [in]    ULONG                   cpspec,
        [in, size_is(cpspec)]
                const PROPSPEC          rgpspec[]
        );

#ifdef IPROPERTY_DLL
    [call_as(DeleteMultiple)]
    HRESULT RemoteDeleteMultiple(
        [in]    ULONG                   cpspec,
        [in, size_is(cpspec)]
                const PROPSPEC          *rgpspec
        );
#endif

    HRESULT ReadPropertyNames(
        [in]    ULONG                   cpropid,
        [in, size_is(cpropid)]
                const PROPID            rgpropid[],
        [out, size_is(cpropid)]
                LPOLESTR                rglpwstrName[]
        );

    HRESULT WritePropertyNames(
        [in]    ULONG                   cpropid,
        [in, size_is(cpropid)]
                const PROPID            rgpropid[],
        [in, size_is(cpropid)]
                const LPOLESTR          rglpwstrName[]
        );

    HRESULT DeletePropertyNames(
        [in]    ULONG                   cpropid,
        [in, size_is(cpropid)]
                const PROPID            rgpropid[]
        );

    HRESULT Commit(
        [in]    DWORD                   grfCommitFlags
        );

    HRESULT Revert();

    HRESULT Enum(
        [out]   IEnumSTATPROPSTG **     ppenum
        );

    HRESULT SetTimes(
        [in]    FILETIME const *        pctime,
        [in]    FILETIME const *        patime,
        [in]    FILETIME const *        pmtime
        );

    HRESULT SetClass(
        [in]    REFCLSID                clsid
        );

    HRESULT Stat(
        [out]   STATPROPSETSTG *        pstatpsstg
        );
}

[
    object,
    uuid(0000013A-0000-0000-C000-000000000046),
    pointer_default(unique)
]

interface IPropertySetStorage : IUnknown
{

    typedef [unique] IPropertySetStorage * LPPROPERTYSETSTORAGE;

    HRESULT Create(
        [in]    REFFMTID                rfmtid,
        [in, unique]
                const CLSID *           pclsid,
        [in]    DWORD                   grfFlags,
        [in]    DWORD                   grfMode,
        [out]   IPropertyStorage **     ppprstg
        );

    HRESULT Open(
        [in]    REFFMTID                rfmtid,
        [in]    DWORD                   grfMode,
        [out]   IPropertyStorage **     ppprstg
        );

    HRESULT Delete(
        [in]    REFFMTID                rfmtid
        );

    HRESULT Enum(
        [out]   IEnumSTATPROPSETSTG **  ppenum
        );

}


[
    object,
    uuid(00000139-0000-0000-C000-000000000046),
    pointer_default(unique)
]

interface IEnumSTATPROPSTG : IUnknown
{

    typedef [unique] IEnumSTATPROPSTG * LPENUMSTATPROPSTG;

    [local]
    HRESULT Next(
        [in]    ULONG                   celt,
        [out, size_is(celt), length_is(*pceltFetched)]
                STATPROPSTG *           rgelt,
        [out]   ULONG *                 pceltFetched
        );

    [call_as(Next)]
    HRESULT RemoteNext(
        [in]    ULONG                   celt,
        [out, size_is(celt), length_is(*pceltFetched)]
                STATPROPSTG *           rgelt,
        [out]   ULONG *                 pceltFetched
        );

    HRESULT Skip(
        [in]    ULONG                   celt
        );

    HRESULT Reset();

    HRESULT Clone(
        [out]   IEnumSTATPROPSTG **     ppenum
        );
}


[
    object,
    uuid(0000013B-0000-0000-C000-000000000046),
    pointer_default(unique)
]

interface IEnumSTATPROPSETSTG : IUnknown
{

    typedef [unique] IEnumSTATPROPSETSTG * LPENUMSTATPROPSETSTG;

    [local]
    HRESULT Next(
        [in]    ULONG                   celt,
        [out, size_is(celt), length_is(*pceltFetched)]
                STATPROPSETSTG *        rgelt,
        [out]   ULONG *                 pceltFetched
        );

    [call_as(Next)]
    HRESULT RemoteNext(
        [in]    ULONG                   celt,
        [out, size_is(celt), length_is(*pceltFetched)]
                STATPROPSETSTG *        rgelt,
        [out]   ULONG *                 pceltFetched
        );

    HRESULT Skip(
        [in]    ULONG                   celt
        );

    HRESULT Reset();

    HRESULT Clone(
        [out]   IEnumSTATPROPSETSTG **  ppenum
        );
}


cpp_quote("WINOLEAPI PropVariantCopy ( PROPVARIANT * pvarDest, const PROPVARIANT * pvarSrc );")
cpp_quote("WINOLEAPI PropVariantClear ( PROPVARIANT * pvar );")
cpp_quote("WINOLEAPI FreePropVariantArray ( ULONG cVariants, PROPVARIANT * rgvars );")

cpp_quote("")
cpp_quote("#define _PROPVARIANTINIT_DEFINED_")
cpp_quote("#   ifdef __cplusplus")
cpp_quote("inline void PropVariantInit ( PROPVARIANT * pvar )")
cpp_quote("{")
cpp_quote("    memset ( pvar, 0, sizeof(PROPVARIANT) );")
cpp_quote("}")
cpp_quote("#   else")
cpp_quote("#   define PropVariantInit(pvar) memset ( pvar, 0, sizeof(PROPVARIANT) )")
cpp_quote("#   endif")
cpp_quote("")

cpp_quote("")
cpp_quote("#ifndef _STGCREATEPROPSTG_DEFINED_")
cpp_quote("WINOLEAPI StgCreatePropStg( IUnknown* pUnk, REFFMTID fmtid, const CLSID *pclsid, DWORD grfFlags, DWORD dwReserved, IPropertyStorage **ppPropStg );")
cpp_quote("WINOLEAPI StgOpenPropStg( IUnknown* pUnk, REFFMTID fmtid, DWORD grfFlags, DWORD dwReserved, IPropertyStorage **ppPropStg );")
cpp_quote("WINOLEAPI StgCreatePropSetStg( IStorage *pStorage, DWORD dwReserved, IPropertySetStorage **ppPropSetStg);")

cpp_quote("")
cpp_quote("#define CCH_MAX_PROPSTG_NAME    31")
cpp_quote("WINOLEAPI FmtIdToPropStgName( const FMTID *pfmtid, LPOLESTR oszName );" )
cpp_quote("WINOLEAPI PropStgNameToFmtId( const LPOLESTR oszName, FMTID *pfmtid );" )
cpp_quote("#endif")

	*/

/****************************************************************************
 *  Connection Point Interfaces
 ****************************************************************************/
 /*
#ifdef __INCLUDE_CPIFS
interface IConnectionPointContainer;
interface IConnectionPoint;
interface IEnumConnections;
interface IEnumConnectionPoints;

[
    object,
    uuid(B196B286-BAB4-101A-B69C-00AA00341D07),
    pointer_default(unique)
]
interface IConnectionPoint : IUnknown
{
    typedef IConnectionPoint * PCONNECTIONPOINT;
    typedef IConnectionPoint * LPCONNECTIONPOINT;

    HRESULT GetConnectionInterface
    (
        [out]           IID * piid
    );

    HRESULT GetConnectionPointContainer
    (
        [out]           IConnectionPointContainer ** ppCPC
    );

    HRESULT Advise
    (
        [in]    IUnknown * pUnkSink,
        [out]   DWORD *    pdwCookie
    );

    HRESULT Unadvise
    (
        [in]    DWORD dwCookie
    );

    HRESULT EnumConnections
    (
        [out]   IEnumConnections ** ppEnum
    );
}

[
    object,
    uuid(B196B284-BAB4-101A-B69C-00AA00341D07),
    pointer_default(unique)
]
interface IConnectionPointContainer : IUnknown
{
    typedef IConnectionPointContainer * PCONNECTIONPOINTCONTAINER;
    typedef IConnectionPointContainer * LPCONNECTIONPOINTCONTAINER;

    HRESULT EnumConnectionPoints
    (
        [out]   IEnumConnectionPoints ** ppEnum
    );

    HRESULT FindConnectionPoint
    (
        [in]    REFIID riid,
        [out]   IConnectionPoint ** ppCP
    );
}


[
    object,
    uuid(B196B287-BAB4-101A-B69C-00AA00341D07),
    pointer_default(unique)
]
interface IEnumConnections : IUnknown
{
    typedef IEnumConnections * PENUMCONNECTIONS;
    typedef IEnumConnections * LPENUMCONNECTIONS;

    typedef struct tagCONNECTDATA
    {
        IUnknown *  pUnk;
        DWORD       dwCookie;
    } CONNECTDATA;

    typedef struct tagCONNECTDATA * PCONNECTDATA;
    typedef struct tagCONNECTDATA * LPCONNECTDATA;

    [local]
    HRESULT Next(
        [in]                        ULONG           cConnections,
        [out,
         size_is(cConnections),
         length_is(*lpcFetched)]    CONNECTDATA *   rgcd,
        [out]                       ULONG *         lpcFetched
    );

    [call_as(Next)]
    HRESULT RemoteNext(
        [in]                            ULONG           cConnections,
        [out,
         size_is(cConnections),
         length_is(*lpcFetched)]        CONNECTDATA *   rgcd,
        [out]                           ULONG *         lpcFetched
    );

    HRESULT Skip
    (
        [in]    ULONG cConnections
    );

    HRESULT Reset
    (
        void
    );

    HRESULT Clone
    (
        [out]   IEnumConnections ** ppEnum
    );
}


[
    object,
    uuid(B196B285-BAB4-101A-B69C-00AA00341D07),
    pointer_default(unique)
]
interface IEnumConnectionPoints : IUnknown
{
    typedef IEnumConnectionPoints * PENUMCONNECTIONPOINTS;
    typedef IEnumConnectionPoints * LPENUMCONNECTIONPOINTS;

    [local]
    HRESULT Next(
        [in]                        ULONG               cConnections,
        [out,
         size_is(cConnections),
         length_is(*lpcFetched)]    IConnectionPoint ** rgpcn,
        [out]                       ULONG *             lpcFetched
    );

    [call_as(Next)]
    HRESULT RemoteNext(
        [in]                        ULONG               cConnections,
        [out,
         size_is(cConnections),
         length_is(*lpcFetched)]    IConnectionPoint ** rgpcn,
        [out]                       ULONG *             lpcFetched
    );

    HRESULT Skip
    (
        [in]    ULONG   cConnections
    );

    HRESULT Reset
    (
        void
    );

    HRESULT Clone
    (
        [out]   IEnumConnectionPoints **    ppEnum
    );
}
#endif // __INCLUDE_CPIFS


cpp_quote( "#if  (_WIN32_WINNT >= 0x0400 ) || defined(_WIN32_DCOM) // DCOM" )
cpp_quote( "// This interface is only valid on Windows NT 4.0" )

[
    local,
    object,
    uuid(0000013D-0000-0000-C000-000000000046)
]
interface IClientSecurity : IUnknown
{

    typedef struct tagSOLE_AUTHENTICATION_SERVICE
    {
        DWORD    dwAuthnSvc;
        DWORD    dwAuthzSvc;
        OLECHAR *pPrincipalName;
        HRESULT  hr;
    } SOLE_AUTHENTICATION_SERVICE;

    typedef SOLE_AUTHENTICATION_SERVICE *PSOLE_AUTHENTICATION_SERVICE;

    typedef enum tagEOLE_AUTHENTICATION_CAPABILITIES
    {
        EOAC_NONE           = 0x0,
        EOAC_MUTUAL_AUTH    = 0x1,
        EOAC_CLOAKING       = 0x10,

        // These are only valid for CoInitializeSecurity
        EOAC_SECURE_REFS    = 0x2,
        EOAC_ACCESS_CONTROL = 0x4,
        EOAC_APPID          = 0x8
    } EOLE_AUTHENTICATION_CAPABILITIES;

    HRESULT QueryBlanket
    (
        [in]  IUnknown                *pProxy,
        [out] DWORD                   *pAuthnSvc,
        [out] DWORD                   *pAuthzSvc,
        [out] OLECHAR                **pServerPrincName,
        [out] DWORD                   *pAuthnLevel,
        [out] DWORD                   *pImpLevel,
        [out] void                   **pAuthInfo,
        [out] DWORD                   *pCapabilites
    );

    HRESULT SetBlanket
    (
        [in] IUnknown                 *pProxy,
        [in] DWORD                     AuthnSvc,
        [in] DWORD                     AuthzSvc,
        [in] OLECHAR                  *pServerPrincName,
        [in] DWORD                     AuthnLevel,
        [in] DWORD                     ImpLevel,
        [in] void                     *pAuthInfo,
        [in] DWORD                     Capabilities
    );

    HRESULT CopyProxy
    (
        [in]  IUnknown  *pProxy,
        [out] IUnknown **ppCopy
    );
}

[
    local,
    object,
    uuid(0000013E-0000-0000-C000-000000000046)
]
interface IServerSecurity : IUnknown
{
    HRESULT QueryBlanket
    (
        [out] DWORD    *pAuthnSvc,
        [out] DWORD    *pAuthzSvc,
        [out] OLECHAR **pServerPrincName,
        [out] DWORD    *pAuthnLevel,
        [out] DWORD    *pImpLevel,
        [out] void    **pPrivs,
        [out] DWORD    *pCapabilities
    );

    HRESULT ImpersonateClient();

    HRESULT RevertToSelf();

    BOOL IsImpersonating();
}

[
    object,
    uuid(00000140-0000-0000-C000-000000000046)
]

interface IClassActivator : IUnknown
{
    HRESULT GetClassObject(
        [in] REFCLSID rclsid,
        [in] DWORD dwClassContext,
        [in] LCID locale,
        [in] REFIID riid,
        [out, iid_is(riid)] void **ppv);
}


[
object,
local,
uuid(00000144-0000-0000-C000-000000000046),
oleautomation
]
interface IRpcOptions : IUnknown
{
    HRESULT Set([in] IUnknown * pPrx,
                [in] DWORD dwProperty,
                [in] ULONG_PTR dwValue);

    HRESULT Query([in] IUnknown * pPrx,
                  [in] DWORD dwProperty,
                  [out] ULONG_PTR * pdwValue);

    HRESULT CopyProxy([in] IUnknown * punkProxy,
                      [out] IUnknown ** ppunkCopy);
}

enum {COMBND_RPCSTRINGS = 0x01};  // flag indicating arBndInfo is the
                                  // Rpc string bindings to be used.

[
object,
local,
uuid(00000148-0000-0000-C000-000000000046)
]
interface IComBinding : IUnknown
{
  HRESULT InitBinding([in]    DWORD    dwEndpointFlags,
                      [in]    DWORD    dwNICFlags,
                      [in]    DWORD    mbzReserved1,
                      [in]    DWORD    mbzReserved2,
                      [in]    LPOLESTR pszBinding
	              );

  HRESULT QueryBinding([out]    LPDWORD    pdwEndpointFlags,
                       [out]    LPDWORD    pdwNICFlags,
                       [out]    LPDWORD    mbzReserved1,
                       [out]    LPDWORD    mbzReserved2,
                       [out]    LPOLESTR  *ppszBinding
	              );


}




cpp_quote( "#endif //DCOM" )


[
    object,
    uuid(99caf010-415e-11cf-8814-00aa00b569f5),
    pointer_default(unique)
]

interface IFillLockBytes: IUnknown
{
    [local]
    HRESULT FillAppend
    (
        [in, size_is(cb)] void const *pv,
        [in] ULONG cb,
        [out] ULONG *pcbWritten
    );

    [call_as(FillAppend)]
    HRESULT _stdcall RemoteFillAppend(
        [in, size_is(cb)] byte const *pv,
        [in] ULONG cb,
        [out] ULONG *pcbWritten);

    [local]
    HRESULT FillAt
    (
        [in] ULARGE_INTEGER ulOffset,
        [in, size_is(cb)] void const *pv,
        [in] ULONG cb,
        [out] ULONG *pcbWritten
    );

    [call_as(FillAt)]
    HRESULT _stdcall RemoteFillAt(
        [in] ULARGE_INTEGER ulOffset,
        [in, size_is(cb)] byte const *pv,
        [in] ULONG cb,
        [out] ULONG *pcbWritten);

    HRESULT SetFillSize
    (
        [in] ULARGE_INTEGER ulSize
    );

    HRESULT Terminate
    (
        [in] BOOL bCanceled
    );
}


[
    object,
    uuid(a9d758a0-4617-11cf-95fc-00aa00680db4),
    pointer_default(unique)
]

interface IProgressNotify: IUnknown
{
    HRESULT OnProgress
    (
        [in] DWORD dwProgressCurrent,
        [in] DWORD dwProgressMaximum,
        [in] BOOL  fAccurate,
        [in] BOOL  fOwner
    );
}


[
    local,
    object,
    uuid(0e6d4d90-6738-11cf-9608-00aa00680db4),
    pointer_default(unique)
]

interface ILayoutStorage: IUnknown
{
        typedef struct tagStorageLayout
        {
            DWORD LayoutType;
            OLECHAR *pwcsElementName;
            LARGE_INTEGER cOffset;
            LARGE_INTEGER cBytes;
        } StorageLayout;

        HRESULT __stdcall LayoutScript
        (
            [in] StorageLayout *pStorageLayout,
            [in] DWORD nEntries,
            [in] DWORD glfInterleavedFlag
        );
        HRESULT __stdcall BeginMonitor(void);

        HRESULT __stdcall EndMonitor(void);

        HRESULT __stdcall ReLayoutDocfile
        (
            [in] OLECHAR *pwcsNewDfName
        );

        HRESULT __stdcall ReLayoutDocfileOnILockBytes
        (
            [in] ILockBytes *pILockBytes
        );


}

[
 uuid(00000022-0000-0000-C000-000000000046),
 version(1.0),
 pointer_default(unique)
  , object
]

interface ISurrogate : IUnknown
{
    typedef [unique] ISurrogate* LPSURROGATE;

        HRESULT LoadDllServer(
                [in] REFCLSID           Clsid);
        HRESULT FreeSurrogate();
}


[
    local,
    object,
    uuid(00000146-0000-0000-C000-000000000046)
]
interface IGlobalInterfaceTable : IUnknown
{
    typedef [unique] IGlobalInterfaceTable *LPGLOBALINTERFACETABLE;

    HRESULT RegisterInterfaceInGlobal
    (
        [in]  IUnknown *pUnk,
        [in]  REFIID    riid,
        [out] DWORD    *pdwCookie
    );

    HRESULT RevokeInterfaceFromGlobal
    (
        [in] DWORD      dwCookie
    );

    HRESULT GetInterfaceFromGlobal
    (
        [in]  DWORD          dwCookie,
        [in]  REFIID         riid,
        [out, iid_is(riid)] void **ppv
    );
};


[
    object,
    uuid(0e6d4d92-6738-11cf-9608-00aa00680db4),
    pointer_default(unique)
]

interface IDirectWriterLock : IUnknown
{

    HRESULT WaitForWriteAccess ([in] DWORD dwTimeout);

    HRESULT ReleaseWriteAccess ();

    HRESULT HaveWriteAccess ();

}

[
    object,
    uuid(00000023-0000-0000-C000-000000000046)
]

interface ISynchronize : IUnknown
{
    HRESULT Wait([in] DWORD dwMilliseconds);
    HRESULT Signal();
    HRESULT Reset();
}

[
 local,
 object,
 uuid(00000025-0000-0000-C000-000000000046)
]
interface ISynchronizeMutex : ISynchronize
{
    HRESULT ReleaseMutex();
}

[
 local,
 object,
 uuid(00000024-0000-0000-C000-000000000046)
]
interface IAsyncSetup : IUnknown
{
    HRESULT GetAsyncManager( [in]  REFIID           riid,
                             [in]  IUnknown        *pOuter,
                             [in]  DWORD            dwFlags,
                             [out] IUnknown       **ppInner,
                             [out] IAsyncManager  **ppAsyncMgr );
}

[
 local,
 object,
 uuid(00000029-0000-0000-C000-000000000046)
]

interface ICancelMethodCalls : IUnknown
{
    typedef [unique] ICancelMethodCalls *LPCANCELMETHODCALLS;

    HRESULT Cancel          (void);
    HRESULT TestCancel      (void);
    HRESULT SetCancelTimeout([in] ULONG ulSeconds);
}

[
 local,
 object,
 uuid(0000002A-0000-0000-C000-000000000046)
]
interface IAsyncManager : IUnknown
{
    typedef enum tagDCOM_CALL_STATE
    {
        DCOM_NONE           = 0x0,
        DCOM_CALL_COMPLETE  = 0x1,
        DCOM_CALL_CANCELED  = 0x2,
    } DCOM_CALL_STATE;

    HRESULT CompleteCall  ( [in] HRESULT Result );
    HRESULT GetCallContext( [in] REFIID riid, [out] void **pInterface );
    HRESULT GetState      ( [out] ULONG *pulStateFlags);
}

[
 local,
 object,
 uuid(0000002B-0000-0000-C000-000000000046)
]
interface IWaitMultiple : IUnknown
{
    HRESULT WaitMultiple  ( [in] DWORD timeout, [out] ISynchronize **pSync );
    HRESULT AddSynchronize( [in] ISynchronize *pSync );
}

[
 local,
 object,
 uuid(0000002C-0000-0000-C000-000000000046)
]
interface ISynchronizeEvent : IUnknown
{
    HRESULT GetEvent( [out] HANDLE *pEvent );
}

[
 object,
 uuid(00000026-0000-0000-C000-000000000046)
]
interface IUrlMon : IUnknown
{
    HRESULT AsyncGetClassBits(
        [in]         REFCLSID   rclsid,
        [in, unique] LPCWSTR    pszTYPE,
        [in, unique] LPCWSTR    pszExt,
        [in]         DWORD      dwFileVersionMS,
        [in]         DWORD      dwFileVersionLS,
        [in, unique] LPCWSTR    pszCodeBase,
        [in]         IBindCtx * pbc,
        [in]         DWORD      dwClassContext,
        [in]         REFIID     riid,
        [in]         DWORD      flags);
}

//----------------------------------------------------------------------------
// The Class Store Access Interface.
//----------------------------------------------------------------------------
[
  object,
  uuid(00000190-0000-0000-C000-000000000046)
]
interface IClassAccess : IUnknown
{

// This is the most common method to access the Class Container.
// It queries the Class Store for implementations for a specific
// Class Id.
// If a matching implementation is available for the object type,
// client architecture, locale and class context a pointer to the
// binary is returned along with other package info in the [out] parameter
// pPackageInfo.
//
// If the binary needs to be downloaded to the local machine, it is
// done as a part of this.
//
    HRESULT   GetClassInfo(
          [in]    REFCLSID          clsid,             // Class ID
          [in]    QUERYCONTEXT      QryContext,        // Query Attributes
          [out]   PACKAGEINFO   *   pPackageInfo
    );

//
// GetClassSpecInfo is same as GetClassInfo except for it takes in
//  any Class Specifier , CLSID or File Ext, or ProgID or MIME type.
//
    HRESULT   GetClassSpecInfo(
          [in]    uCLSSPEC      *   pClassSpec,        // Class Spec (CLSID/Ext/MIME)
          [in]    QUERYCONTEXT      QryContext,        // Query Attributes
          [out]   PACKAGEINFO   *   pPackageInfo
    );


//
// GetInstallablePackages is used by CoGetPublishedAppInfo
// to provide list of published apps from the class store that are
// available for installation.
//

typedef struct tagPUBLISHEDINFOLIST {
        DWORD            cPublApps;
        [size_is(cPublApps), unique] PUBLISHEDAPPINFO    *pPublAppInfo;
} PUBLISHEDINFOLIST;

    HRESULT   GetInstallablePackages (
          [in]    DWORD               Count,
          [out]   PUBLISHEDINFOLIST   *pInfoList
    );

}

[
  object,
  uuid(00000192-0000-0000-C000-000000000046)
]
interface IClassRefresh : IUnknown
{
//
// GetUpgrades is called to check if the Class Store has
// newer versions for any of a list of CLSIDs. The client calls this
// with a list of CLSIDs that were installed from the Class Container.
//

typedef struct tagPACKAGEINFOLIST {
        DWORD            cPackInfo;
        [size_is(cPackInfo), unique] PACKAGEINFO    *pPackageInfo;
} PACKAGEINFOLIST;

    HRESULT   GetUpgrades (
        [in]    ULONG                   cClasses,
        [in, size_is(cClasses)] CLSID   *pClassList,     // CLSIDs Installed
        [in]    CSPLATFORM              Platform,
        [in]    LCID                    Locale,
        [out]   PACKAGEINFOLIST         *pPackageInfoList);

//
// CommitUpgrades is called to notify the Class Store that
// the newer versions were successfully installed and that the update sequence
// can be moved forward.
//

    HRESULT   CommitUpgrades ();
}


//----------------------------------------------------------------------------
// The Class Store Admin Interface.
//----------------------------------------------------------------------------

typedef struct tagCLASSDETAIL {
               CLSID                Clsid;
               LPOLESTR             pszDesc;
               LPOLESTR             pszIconPath;
               CLSID                TreatAsClsid;
               CLSID                AutoConvertClsid;
               DWORD                cFileExt;
               [size_is(cFileExt)] LPOLESTR  *prgFileExt;
               LPOLESTR             pMimeType;
               LPOLESTR             pDefaultProgId;
               DWORD                cOtherProgId;
               [size_is(cOtherProgId)] LPOLESTR  *prgOtherProgId;
} CLASSDETAIL;

//+---------------------------------------------------------------------------
//    Contents:        Enum Interfaces for Class Store
//----------------------------------------------------------------------------
cpp_quote("#ifndef _LPCSADMNENUM_DEFINED")
cpp_quote("#define _LPCSADMNENUM_DEFINED")

//
//  IEnumPackage
//  ============
//

[
  object,
  uuid(00000193-0000-0000-C000-000000000046)
]
interface IEnumPackage : IUnknown
{

//---- Next()

    HRESULT Next(
        [in]        ULONG celt,
        [out, size_is(celt), length_is(*pceltFetched)] PACKAGEDETAIL *rgelt,
        [out]       ULONG *pceltFetched);

//
//    celt             number of elements to be fetched.
//    rgelt            array of PackageDetail structures.
//    pceltFetched     elements actually fetched.
//
// Returns:
//        S_OK
//        S_FALSE            (Not enough elements to be fetched.)
//        E_INVALIDARG
//        E_FAIL
//        CS_E_INVALID_VERSION (Class Container is corrupted
//                              OR is of a version that is no more supported)
//        E_OUTOFMEMORY
//
//    on errors
//        *pceltFetched = 0
//


//---- Skip()

    HRESULT Skip(
        [in]        ULONG celt);

//
//    celt            number of elements to be skipped.
//
// Returns:
//        S_OK
//        S_FALSE            (Not enough elements to be skipped.)
//        E_FAIL
//        E_ACCESSDENIED
//        E_OUTOFMEMORY


//---- Reset()

    HRESULT Reset();

//
// Returns:
//        S_OK
//


//---- Clone()

    HRESULT Clone(
        [out]       IEnumPackage **ppenum);

//
// Returns:
//        S_OK
//        E_FAIL
//        E_INVALIDARG
//        E_ACCESSDENIED
//        E_OUTOFMEMORY


}


//
//  IEnumClass
//  ==========
//

[
  object,
  uuid(00000194-0000-0000-C000-000000000046)
]

interface IEnumClass : IUnknown
{
//---- Next()

    HRESULT Next(
        [in]        ULONG celt,
        [out, size_is(celt), length_is(*pceltFetched)] CLASSDETAIL *rgelt,
        [out]       ULONG *pceltFetched);

//
//    celt             number of elements to be fetched.
//    rgelt            array of CLASSDETAIL structures.
//    pceltFetched     elements actually fetched.
//
// Returns:
//        S_OK
//        S_FALSE            (Not enough elements to be fetched.)
//        E_INVALIDARG
//        E_FAIL
//        CS_E_INVALID_VERSION (Class Container is corrupted
//                              OR is of a version that is no more supported)
//        E_OUTOFMEMORY
//
//    on errors
//        *pceltFetched = 0
//

//---- Skip()

    HRESULT Skip(
        [in]        ULONG celt);

//
//    celt            number of elements to be skipped.
//
// Returns:
//        S_OK
//        S_FALSE            (Not enough elements to be skipped.)
//        E_FAIL
//        E_ACCESSDENIED
//        E_OUTOFMEMORY

//---- Reset()

    HRESULT Reset();

//
// Returns:
//        S_OK
//


//---- Clone()

    HRESULT Clone(
        [out]       IEnumClass **ppenum);

//
// Returns:
//        S_OK
//        E_FAIL
//        E_INVALIDARG
//        E_ACCESSDENIED
//        E_OUTOFMEMORY



}
cpp_quote("#endif")

//
//  IClassAdmin
//  ===========
//


[
  object,
  uuid(00000191-0000-0000-C000-000000000046)
]
interface IClassAdmin : IUnknown
{

// ::NewClass
// -----------
// Stores a new Class Definition in the Class Store
// Corresponds to HKCR/{CLSID} in registry
// [In] - CLSID
//                Class Name
//                TreatAs CLSID (NULL GUID if no TreatAs)
//                AutoConvert CLSID (NULL GUID if no AutoConvert)
//                File Extension (NULL if no association)
//                Mime Type (NULL if no association)
//                Default ProgId (NULL if no association)
//                Other ProgIds
//                TypelibID
//                Icon Path (NULL if none).
//
// Returns - S_OK
//                     E_ALREADY_EXISTS
//                     E_INVALIDARG
//
    HRESULT    NewClass (
        [in]        CLASSDETAIL *pClassDetail
        );

// ::DeleteClass
// -----------
// Removes a Class Definition from the Class Store
// [In] - CLSID

    HRESULT    DeleteClass (
        [in]        REFCLSID      guidClsId
        );


// ::NewInterface
// --------------
// Stores a new Interface Definition in the Class Store
// Corresponds to HKCR/{IID} in registry
// [In] - IID
//                Interface Name
//                Proxy-Stub CLSID (NULL GUID if no ProxyStub)
//                TypeLib GUID (NULL GUID if no TypeLib)
//
// Returns - S_OK
//                     E_ALREADY_EXISTS
//                     E_INVALID_ARG
//
    HRESULT    NewInterface (
        [in]        REFIID      iid,
        [in, unique] LPOLESTR   pszDesc,
        [in]        REFCLSID    psclsid,
        [in]        REFCLSID    typelibid
        );

// ::DeleteInterface
// -----------
// Removes an Interface Definition from the Class Store
// [In] - IID

    HRESULT    DeleteInterface (
        [in]        REFIID      iid
        );


// ::NewPackage
// ------------
// Stores a new application package in the Class Store
// May Correspond to HKCR/{CLSID}/LocalServer32 likes in registry
//
// Returns - S_OK
//                     E_ALREADY_EXISTS
//                     E_INVALIDARG
//
    HRESULT    NewPackage (
        [in]        PACKAGEDETAIL *pPackageDetail
        );


// ::DeletePackage
// -----------
// Removes a package from the Class Store
// [In] - PackageName

    HRESULT    DeletePackage (
        [in]        LPOLESTR       pszPackageName
        );

// ::GetClassesEnum()
//
// Returns the clsid enumerator
// for browsing classes defined in the class store.
//
// Returns:
//        S_OK
//        E_INVALIDARG
//        E_FAIL
//        E_ACCESSDENIED
//        E_OUTOFMEMORY
//
//
//  The value of the enumerator is NULL for all the error conditions.
//

    HRESULT    GetClassesEnum(
        [out]       IEnumClass **ppIEnumClass
    );



// ::GetPackagesEnum()
//
//        Getting the Package enumerator from the classstore.
//
//        guidClsid:    All the apps that implements the clsid.
//                        ignored if NULLGUID.
//        Vendor:       All the apps provided by a given Vendor.
//                        ignored if NULL.
//
//        ppIEnumPackage: NULL if there is any error.
//
// Returns:
//        S_OK
//        E_INVALIDARG
//        E_FAIL
//        E_ACCESSDENIED
//        E_OUTOFMEMORY
//
// The value of the enumerator is NULL for all the error conditions.
//

    HRESULT    GetPackagesEnum(
        [in]         REFCLSID         guidClsid,
        [in, unique] LPOLESTR         pszVendor,
        [in]         CSPLATFORM       Platform,
        [in]         DWORD            dwContext,
        [in]         LCID             Locale,
        [out]        IEnumPackage    **ppIEnumPackage
        );


// ::GetClassDetails()
//
// Get all the class details given the clsid.
//
//    [in]      guidClsID    class ID (guid)
//    [out]     CLASSDETAIL     *pClassDetail
//
// Returns:
//        S_OK
//        E_INVALIDARG
//        E_FAIL
//        E_NOTFOUND            (no such class)
//        E_ACCESSDENIED
//        E_OUTOFMEMORY
//
//



    HRESULT    GetClassDetails (
        [in]        REFCLSID            guidClsId,
        [out]       CLASSDETAIL         *pClassDetail
        );


// ::GetIidDetails()
//
//    [IN]
//        iid            IID (guid)
//    [OUT]
//        pszDesc         Description
//        psClsid         Proxy Stub Class ID
//        pTypeLibId      libid
//
// Returns:
//        S_OK
//        E_INVALIDARG
//        E_FAIL
//        E_NOTFOUND
//        E_ACCESSDENIED
//        E_OUTOFMEMORY
//
//

    HRESULT GetIidDetails (
        [in]        REFIID           iid,
        [out]       LPOLESTR        *ppszDesc,
        [out]       CLSID           *psClsid,
        [out]       CLSID           *pTypeLibId
        );

// ::GetPackageDetails()
//
// Get all the Package details given packagename.
//
//    [IN]
//          PackageName: Name of the package
//    [OUT]
//          pPackageDetail  Package Detail
//
// Returns:
//        S_OK
//        E_INVALIDARG
//        E_FAIL
//        E_NOTFOUND            (no such class)
//        E_ACCESSDENIED
//        E_OUTOFMEMORY
//
//


    HRESULT    GetPackageDetails (
        [in]        LPOLESTR             pszPackageName,
        [out]       PACKAGEDETAIL       *pPackageDetail
        );
}

cpp_quote("#if ( _MSC_VER >= 800 )")
cpp_quote("#pragma warning(default:4201)")
cpp_quote("#endif")

	*/

} // extern (Windows)
