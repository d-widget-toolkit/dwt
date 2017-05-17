/*
 * All COM APIs required by SWT, all APIs prototype copied from MSDN 2003
 * don't import this module directly, import std.internal.ole.win32.com instead
 *
 * author : Shawn Liu
 */


module org.eclipse.swt.internal.ole.win32.COMAPI;


//private import std.c.windows.windows;
//private import std.c.windows.com;
import org.eclipse.swt.internal.win32.WINTYPES;
import org.eclipse.swt.internal.ole.win32.COMTYPES;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.ole.win32.OLEIDL;
import org.eclipse.swt.internal.ole.win32.OAIDL;
import org.eclipse.swt.internal.ole.win32.extras;

extern(Windows){

WINOLEAPI CreateStreamOnHGlobal(
	HGLOBAL hGlobal,         //Memory handle for the stream object
	BOOL fDeleteOnRelease,   //Whether to free memory when the object
					   // is released
	LPSTREAM * ppstm         //Address of output variable that
					   // receives the IStream interface pointer
);
HRESULT CLSIDFromProgID(
  LPCOLESTR lpszProgID,
  LPCLSID pclsid
);
HRESULT CLSIDFromString(
  LPCOLESTR lpsz,
  LPCLSID pclsid
);
STDAPI CoCreateInstance(
  REFCLSID rclsid,
  LPUNKNOWN pUnkOuter,
  DWORD dwClsContext,
  REFCIID riid,
  LPVOID * ppv
);
void CoFreeUnusedLibraries();
STDAPI CoGetClassObject(
  REFCLSID rclsid,
  DWORD dwClsContext,
  COSERVERINFO * pServerInfo,
  REFCIID riid,
  LPVOID * ppv
);
STDAPI CoLockObjectExternal(
  LPUNKNOWN pUnk,
  BOOL fLock,
  BOOL fLastUnlockReleases
);
LPVOID CoTaskMemAlloc(
  SIZE_T cb
);
void CoTaskMemFree(
  void * pv
);

WINOLEAPI DoDragDrop(
  LPDATAOBJECT pDataObject,  //Pointer to the data object
  LPDROPSOURCE pDropSource,  //Pointer to the source
  DWORD dwOKEffect,           //Effects allowed by the source
  DWORD * pdwEffect           //Pointer to effects on the source
);

WINOLEAPI GetClassFile(
  LPCWSTR szFileName,
  CLSID * pclsid
);
WINOLEAPI IIDFromString(
  LPCOLESTR lpsz,
  LPIID lpiid
);
BOOL IsEqualGUID(
  REFCGUID rguid1,
  REFCGUID rguid2
);
WINOLEAPI OleCreate(
  REFCLSID rclsid,  //CLSID of embedded object to be created
  REFCIID riid,      //Reference to the identifier of the interface
                    // used to communicate with new object
  DWORD renderopt,  //RENDEROPT value indicating cached capabilities
  FORMATETC * pFormatEtc,
                    //Pointer to a FORMATETC structure
  IOleClientSite * pClientSite,
                    //Pointer to request services from the container
  LPSTORAGE pStg,  //Pointer to storage for the object
  void ** ppvObject //Address of output variable that receives the
                    // interface pointer requested in riid
);
WINOLEAPI OleCreateFromFile(
  REFCLSID rclsid,         //Reserved. Must be CLSID_NULL
  LPCOLESTR lpszFileName,  //Pointer to full path of file used to
                           // create object
  REFCIID riid,            //Reference to the identifier of the
                           // interface to be used to communicate with
                           // new object
  DWORD renderopt,         //Value from OLERENDER
  LPFORMATETC pFormatEtc,  //Pointer to the FORMATETC structure
  LPOLECLIENTSITE pClientSite,
                           //Pointer to an interface
  LPSTORAGE pStg,          //Pointer tothe interface to be used as
                           // object storage
  LPVOID * ppvObj       //Address of output variable that
                           // receives the interface pointer requested
                           // in riid
);

STDAPI OleCreatePropertyFrame(
  HWND hwndOwner,    //Parent window of property sheet dialog box
  UINT x,            //Horizontal position for dialog box
  UINT y,            //Vertical position for dialog box
  LPCOLESTR lpszCaption,
                     //Pointer to the dialog box caption
  ULONG cObjects,    //Number of object pointers in lplpUnk
  LPUNKNOWN * lplpUnk,
                     //Pointer to the objects for property sheet
  ULONG cPages,      //Number of property pages in lpPageClsID
  LPCLSID lpPageClsID,
                     //Array of CLSIDs for each property page
  LCID lcid,         //Locale identifier for property sheet locale
  DWORD dwReserved,  //Reserved
  LPVOID lpvReserved //Reserved
);
WINOLEAPI OleDraw(
  LPUNKNOWN pUnk,    //Pointer to the view object to be drawn
  DWORD dwAspect,     //How the object is to be represented
  HDC hdcDraw,        //Device context on which to draw
  LPCRECT lprcBounds  //Pointer to the rectangle in which the object
                      // is drawn
);
WINOLEAPI OleFlushClipboard();
WINOLEAPI OleGetClipboard(
  LPDATAOBJECT * ppDataObj  //Address of output variable that
                            // receives the IDataObject interface
                            // pointer
);
WINOLEAPI OleIsCurrentClipboard(
  LPDATAOBJECT pDataObject  //Pointer to the data object previously
                             // copied or cut
);
BOOL OleIsRunning(
  LPOLEOBJECT pObject  //Pointer to the interface
);
WINOLEAPI OleLoad(
  LPSTORAGE pStg,   //Pointer to the storage object from which to
                     // load
  REFIID riid,       //Reference to the identifier of the interface
  IOleClientSite * pClientSite,
                     //Pointer to the client site for the object
  LPVOID * ppvObj    //Address of output variable that receives the
                     // interface pointer requested in riid
);
WINOLEAPI OleRun(
  LPUNKNOWN pUnknown  //Pointer to interface on the object
);
WINOLEAPI OleSave(
  LPPERSISTSTORAGE pPS,   //Pointer to the object to be saved
  LPSTORAGE pStg,         //Pointer to the destination storage to
                           // which pPS is saved
  BOOL fSameAsLoad         //Whether the object was loaded from pstg
                           // or not
);
WINOLEAPI OleSetClipboard(
  LPDATAOBJECT pDataObj  //Pointer to the data object being copied
                          // or cut
);
WINOLEAPI OleSetContainedObject(
  LPUNKNOWN pUnk,  //Pointer to the interface on the embedded object
  BOOL fContained  //Indicates if the object is embedded
);
WINOLEAPI OleSetMenuDescriptor(
  HOLEMENU holemenu,      //Handle to the composite menu descriptor
  HWND hwndFrame,         //Handle to the container's frame window
  HWND hwndActiveObject,  //Handle to the object's in-place
                          // activation window
  LPOLEINPLACEFRAME lpFrame,  //Pointer to the container's frame
                              // window
  LPOLEINPLACEACTIVEOBJECT lpActiveObj
                          //Active in-place object
);
STDAPI OleTranslateColor (
  OLE_COLOR clr,       //Color to be converted into a COLORREF
  HPALETTE hpal,       //Palette used for conversion
  COLORREF *pcolorref  //Pointer to the caller's variable that
                       // receives the converted result
);
WINOLEAPI ProgIDFromCLSID(
  REFCLSID clsid,
  LPOLESTR * lplpszProgID
);

WINOLEAPI RegisterDragDrop(
  HWND hwnd,  //Handle to a window that can accept drops
  LPDROPTARGET pDropTarget
              //Pointer to object that is to be target of drop
);
void ReleaseStgMedium(
  STGMEDIUM * pmedium  //Pointer to storage medium to be freed
);
WINOLEAPI RevokeDragDrop(
  HWND hwnd  //Handle to a window that can accept drops
);
HRESULT SHDoDragDrop(
    HWND hwnd,
    IDataObject *pdtobj,
    IDropSource *pdsrc,
    DWORD dwEffect,
    DWORD *pdwEffect
);
HRESULT StgCreateDocfile(
  LPCWSTR pwcsName,
  DWORD grfMode,
  DWORD reserved,
  LPSTORAGE* ppstgOpen
);

WINOLEAPI StgIsStorageFile(
  LPCWSTR pwcsName
);

HRESULT StgOpenStorage(
  LPCWSTR pwcsName,
  LPSTORAGE pstgPriority,
  DWORD grfMode,
  SNB snbExclude,
  DWORD reserved,
  LPSTORAGE * ppstgOpen
);

WINOLEAPI StringFromCLSID(
  REFCLSID rclsid,
  LPOLESTR * ppsz
);
BSTR SysAllocString(
  LPCOLESTR  sz
);
VOID SysFreeString(
  BSTR  bstr
);
UINT SysStringByteLen(
  BSTR  bstr
);
HRESULT VariantChangeType(
  VARIANTARG *  pvargDest,
  VARIANTARG *  pvarSrc,
  ushort  wFlags,
  VARTYPE  vt
);

HRESULT VariantClear(
  VARIANTARG *  pvarg
);
HRESULT VariantCopy(
  VARIANTARG *  pvargDest,
  VARIANTARG *  pvargSrc
);
VOID VariantInit(
  VARIANTARG *  pvarg
);
WINOLEAPI WriteClassStg(
  LPSTORAGE pStg,
  REFCLSID rclsid
);

STDAPI CreateStdAccessibleObject(
  HWND hwnd,
  LONG idObject,
  REFCIID riidInterface,
  void** ppvObject
);
LRESULT LresultFromObject(
  REFCIID riid,
  WPARAM wParam,
  LPUNKNOWN pAcc
);

} // end of comapi
