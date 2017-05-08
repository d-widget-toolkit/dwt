module org.eclipse.swt.internal.ole.win32.extras;

//
// extra bits form here and there to bring the com alias inline with MS
// to ease the porting.
//

//public import std.c.windows.com;
//public import std.c.windows.windows;
import org.eclipse.swt.internal.win32.WINTYPES;
import org.eclipse.swt.internal.ole.win32.COMTYPES;
import java.lang.util;

enum
{
    rmm = 23,   // OLE 2 version number info
    rup = 639,
}

enum : int
{
    S_OK = 0,
    S_FALSE = 0x00000001,
    NOERROR = 0,
    E_NOTIMPL     = cast(int)0x80004001,
    E_NOINTERFACE = cast(int)0x80004002,
    E_POINTER     = cast(int)0x80004003,
    E_ABORT       = cast(int)0x80004004,
    E_FAIL        = cast(int)0x80004005,
    E_HANDLE      = cast(int)0x80070006,
    CLASS_E_NOAGGREGATION = cast(int)0x80040110,
    E_OUTOFMEMORY = cast(int)0x8007000E,
    E_INVALIDARG  = cast(int)0x80070057,
    E_UNEXPECTED  = cast(int)0x8000FFFF,
}

enum {
    CLSCTX_INPROC_SERVER    = 0x1,
    CLSCTX_INPROC_HANDLER   = 0x2,
    CLSCTX_LOCAL_SERVER = 0x4,
    CLSCTX_INPROC_SERVER16  = 0x8,
    CLSCTX_REMOTE_SERVER    = 0x10,
    CLSCTX_INPROC_HANDLER16 = 0x20,
    CLSCTX_INPROC_SERVERX86 = 0x40,
    CLSCTX_INPROC_HANDLERX86 = 0x80,

    CLSCTX_INPROC = (CLSCTX_INPROC_SERVER|CLSCTX_INPROC_HANDLER),
    CLSCTX_ALL = (CLSCTX_INPROC_SERVER| CLSCTX_INPROC_HANDLER| CLSCTX_LOCAL_SERVER),
    CLSCTX_SERVER = (CLSCTX_INPROC_SERVER|CLSCTX_LOCAL_SERVER),
}

version(Tango){
    //alias GUID IID;
}
alias GUID CLSID;

extern (C)
{
    extern IID IID_IUnknown;
    extern IID IID_IClassFactory;
    extern IID IID_IMarshal;
    extern IID IID_IMallocSpy;
    extern IID IID_IStdMarshalInfo;
    extern IID IID_IExternalConnection;
    extern IID IID_IMultiQI;
    extern IID IID_IEnumUnknown;
    extern IID IID_IBindCtx;
    extern IID IID_IEnumMoniker;
    extern IID IID_IRunnableObject;
    extern IID IID_IRunningObjectTable;
    extern IID IID_IPersist;
    extern IID IID_IPersistStream;
    extern IID IID_IMoniker;
    extern IID IID_IROTData;
    extern IID IID_IEnumString;
    extern IID IID_ISequentialStream;
    extern IID IID_IStream;
    extern IID IID_IEnumSTATSTG;
    extern IID IID_IStorage;
    extern IID IID_IPersistFile;
    extern IID IID_IPersistStorage;
    extern IID IID_ILockBytes;
    extern IID IID_IEnumFORMATETC;
    extern IID IID_IEnumSTATDATA;
    extern IID IID_IRootStorage;
    extern IID IID_IAdviseSink;
    extern IID IID_IAdviseSink2;
    extern IID IID_IDataObject;
    extern IID IID_IDataAdviseHolder;
    extern IID IID_IMessageFilter;
    extern IID IID_IRpcChannelBuffer;
    extern IID IID_IRpcProxyBuffer;
    extern IID IID_IRpcStubBuffer;
    extern IID IID_IPSFactoryBuffer;
    extern IID IID_IPropertyStorage;
    extern IID IID_IPropertySetStorage;
    extern IID IID_IEnumSTATPROPSTG;
    extern IID IID_IEnumSTATPROPSETSTG;
    extern IID IID_IFillLockBytes;
    extern IID IID_IProgressNotify;
    extern IID IID_ILayoutStorage;
    extern IID GUID_NULL;
    extern IID IID_IRpcChannel;
    extern IID IID_IRpcStub;
    extern IID IID_IStubManager;
    extern IID IID_IRpcProxy;
    extern IID IID_IProxyManager;
    extern IID IID_IPSFactory;
    extern IID IID_IInternalMoniker;
    extern IID IID_IDfReserved1;
    extern IID IID_IDfReserved2;
    extern IID IID_IDfReserved3;
    extern IID IID_IStub;
    extern IID IID_IProxy;
    extern IID IID_IEnumGeneric;
    extern IID IID_IEnumHolder;
    extern IID IID_IEnumCallback;
    extern IID IID_IOleManager;
    extern IID IID_IOlePresObj;
    extern IID IID_IDebug;
    extern IID IID_IDebugStream;
    extern IID IID_StdOle;
    extern IID IID_ICreateTypeInfo;
    extern IID IID_ICreateTypeInfo2;
    extern IID IID_ICreateTypeLib;
    extern IID IID_ICreateTypeLib2;
    extern IID IID_IDispatch;
    extern IID IID_IEnumVARIANT;
    extern IID IID_ITypeComp;
    extern IID IID_ITypeInfo;
    extern IID IID_ITypeInfo2;
    extern IID IID_ITypeLib;
    extern IID IID_ITypeLib2;
    extern IID IID_ITypeChangeEvents;
    extern IID IID_IErrorInfo;
    extern IID IID_ICreateErrorInfo;
    extern IID IID_ISupportErrorInfo;
    extern IID IID_IOleAdviseHolder;
    extern IID IID_IOleCache;
    extern IID IID_IOleCache2;
    extern IID IID_IOleCacheControl;
    extern IID IID_IParseDisplayName;
    extern IID IID_IOleContainer;
    extern IID IID_IOleClientSite;
    extern IID IID_IOleObject;
    extern IID IID_IOleWindow;
    extern IID IID_IOleLink;
    extern IID IID_IOleItemContainer;
    extern IID IID_IOleInPlaceUIWindow;
    extern IID IID_IOleInPlaceActiveObject;
    extern IID IID_IOleInPlaceFrame;
    extern IID IID_IOleInPlaceObject;
    extern IID IID_IOleInPlaceSite;
    extern IID IID_IContinue;
    extern IID IID_IViewObject;
    extern IID IID_IViewObject2;
    extern IID IID_IDropSource;
    extern IID IID_IDropTarget;
    extern IID IID_IEnumOLEVERB;
}

alias TryConst!(IID) *REFCIID;
extern (Windows) export {
    DWORD   CoBuildVersion();

    int StringFromGUID2(GUID *rguid, LPOLESTR lpsz, int cbMax);

    /* init/uninit */

    HRESULT CoInitialize(LPVOID pvReserved);
    void    CoUninitialize();
    DWORD   CoGetCurrentProcess();


    HRESULT CoCreateInstance(CLSID *rclsid, IUnknown UnkOuter,
                        DWORD dwClsContext, IID* riid, void* ppv);

    //HINSTANCE CoLoadLibrary(LPOLESTR lpszLibName, BOOL bAutoFree);
    void    CoFreeLibrary(HINSTANCE hInst);
    void    CoFreeAllLibraries();
    void    CoFreeUnusedLibraries();

    interface IUnknown {
        HRESULT QueryInterface(REFCIID riid, void** pvObject);
        ULONG AddRef();
        ULONG Release();
    }

    interface IClassFactory : IUnknown {
        HRESULT CreateInstance(IUnknown UnkOuter, IID* riid, void** pvObject);
        HRESULT LockServer(BOOL fLock);
    }

}


alias IUnknown LPUNKNOWN;
alias IClassFactory LPCLASSFACTORY;

//alias LPRECT LPCRECT; /* D has no consts */
struct COAUTHINFO{}
//alias DWORD LCID;
alias PDWORD PLCID;
//typedef GUID CLSID;
//alias CLSID * LPCLSID;
alias GUID *REFGUID;
alias TryConst!(GUID) *REFCGUID;

//alias IID *REFIID;

alias CLSID *REFCLSID;

//typedef FMTID  *REFFMTID;
union __MIDL_IWinTypes_0001
{
DWORD dwValue;
wchar *pwszName;
}
struct  userCLIPFORMAT
{
    long fContext;
	__MIDL_IWinTypes_0001 u;
}

alias userCLIPFORMAT *wireCLIPFORMAT;

alias WORD CLIPFORMAT;

alias void * HMETAFILEPICT;
// typeless hack
alias void * wireHGLOBAL;
alias void * wireHBITMAP;
alias void * wireHPALETTE;
alias void * wireHENHMETAFILE;
alias void * wireHMETAFILE;
alias void * wireHMETAFILEPICT;

struct BYTE_BLOB {
   ULONG clSize;
	byte[1] abData;
}

alias BYTE_BLOB *UP_BYTE_BLOB;

struct  WORD_BLOB
{
	ULONG clSize;
	ushort[1] asData;
}

alias WORD_BLOB *UP_WORD_BLOB;

struct  DWORD_BLOB
{
    ULONG clSize;
	ULONG[1] alData;
}
alias DWORD_BLOB *UP_DWORD_BLOB;
alias ushort VARTYPE;
alias short VARIANT_BOOL;

// all the st
enum READYSTATE
    {	READYSTATE_UNINITIALIZED	= 0,
	READYSTATE_LOADING	= 1,
	READYSTATE_LOADED	= 2,
	READYSTATE_INTERACTIVE	= 3,
	READYSTATE_COMPLETE	= 4
}

alias HANDLE HTASK;
