/*
 * extra interface not define in any other modules, copied from MSDN 2003
 * don't import this module directly, import std.internal.ole.win32.com instead
 *
 * author : Shawn Liu
 */

module org.eclipse.swt.internal.ole.win32.ifs;

private import org.eclipse.swt.SWT;
private import org.eclipse.swt.internal.win32.WINTYPES;
private import org.eclipse.swt.internal.ole.win32.COM;
//private import std.c.windows.windows;
//private import std.c.windows.com;
private import org.eclipse.swt.internal.ole.win32.COMTYPES;
private import org.eclipse.swt.internal.ole.win32.OAIDL;
private import org.eclipse.swt.internal.ole.win32.OBJIDL;
private import org.eclipse.swt.internal.ole.win32.OLEIDL;
private import org.eclipse.swt.internal.ole.win32.DOCOBJ;
private import org.eclipse.swt.internal.ole.win32.EXDISP;
private import org.eclipse.swt.internal.ole.win32.MSHTMHST;
private import org.eclipse.swt.internal.ole.win32.extras;


interface IAccessible : IDispatch {
//	int GetTypeInfoCount(int pctinfo);
//	int GetTypeInfo(THIS_ UINT itinfo, LCID lcid, ITypeInfo FAR* FAR* pptinfo);
//	int GetIDsOfNames - not implemented
//	int Invoke - not implemented
	HRESULT get_accParent(LPDISPATCH* ppdispParent);
	HRESULT get_accChildCount(LONG* pcountChildren);
	HRESULT get_accChild(VARIANT varChildID, LPDISPATCH* ppdispChild);
	HRESULT get_accName(VARIANT varID, BSTR* pszName);
	HRESULT get_accValue(VARIANT varID, BSTR* pszValue);
	HRESULT get_accDescription(VARIANT varID,BSTR* pszDescription);
	HRESULT get_accRole(VARIANT varID, VARIANT* pvarRole);
	HRESULT get_accState(VARIANT varID, VARIANT* pvarState);
	HRESULT get_accHelp(VARIANT varID, BSTR* pszHelp);
	HRESULT get_accHelpTopic(BSTR* pszHelpFile, VARIANT varChild, LONG* pidTopic);
	HRESULT get_accKeyboardShortcut(VARIANT varID, BSTR* pszKeyboardShortcut);
	HRESULT get_accFocus(VARIANT* pvarID);
	HRESULT get_accSelection(VARIANT* pvarChildren);
	HRESULT get_accDefaultAction(VARIANT varID,BSTR* pszDefaultAction);
	HRESULT accSelect(LONG flagsSelect, VARIANT varID);
	HRESULT accLocation(LONG* pxLeft, LONG* pyTop, LONG* pcxWidth, LONG* pcyHeight, VARIANT varID);
	HRESULT accNavigate(LONG navDir, VARIANT varStart, VARIANT* pvarEnd);
	HRESULT accHitTest(LONG xLeft,  LONG yTop, VARIANT* pvarID);
	HRESULT accDoDefaultAction(VARIANT varID);
	HRESULT put_accName(VARIANT varID, BSTR* szName);
	HRESULT put_accValue(VARIANT varID, BSTR* szValue);
}
alias IAccessible LPACCESSIBLE;

interface IClassFactory2 : IClassFactory
{
	HRESULT GetLicInfo(LICINFO * pLicInfo);
	HRESULT RequestLicKey(DWORD dwReserved, BSTR * pbstrKey);
	HRESULT CreateInstanceLic(LPUNKNOWN pUnkOuter, LPUNKNOWN pUnkReserved, REFCIID riid, BSTR bstrKey, void ** ppvObject);
}
alias IClassFactory2 LPCLASSFACTORY2;


interface IConnectionPoint : IUnknown
{
	HRESULT GetConnectionInterface(IID * pIID);
	HRESULT GetConnectionPointContainer(LPCONNECTIONPOINTCONTAINER * ppCPC);
	HRESULT Advise(LPUNKNOWN pUnk, DWORD * pdwCookie);
	HRESULT Unadvise(DWORD dwCookie);
	HRESULT EnumConnections(LPENUMCONNECTIONS * ppEnum);
}
alias IConnectionPoint LPCONNECTIONPOINT;


interface IConnectionPointContainer : IUnknown
{
	HRESULT EnumConnectionPoints(LPENUMCONNECTIONPOINTS * ppEnum);
	HRESULT FindConnectionPoint(REFCIID riid, LPCONNECTIONPOINT * ppCP);
}
alias IConnectionPointContainer LPCONNECTIONPOINTCONTAINER;

interface IEnumConnectionPoints : IUnknown
{
	HRESULT Next(ULONG celt, LPCONNECTIONPOINT * rgelt, ULONG * pceltFetched);
	HRESULT Skip(ULONG celt);
	HRESULT Reset();
	HRESULT Clone(LPENUMCONNECTIONPOINTS * ppenum);
}
alias IEnumConnectionPoints LPENUMCONNECTIONPOINTS;

interface IEnumConnections : IUnknown {
	HRESULT Next(ULONG cConnections, CONNECTDATA ** rgpcd, ULONG * pcFetched);
	HRESULT Skip(ULONG cConnections);
	HRESULT Reset();
	HRESULT Clone(LPENUMCONNECTIONS * ppEnum);
}alias IEnumConnections LPENUMCONNECTIONS;

interface IEnumVARIANT : IUnknown {
    HRESULT Next(ULONG celt, VARIANT *rgelt, ULONG *pceltFetched);
    HRESULT Skip(ULONG celt);
    HRESULT Reset();
    HRESULT Clone(LPENUMVARIANT * ppenum);
}
alias IEnumVARIANT LPENUMVARIANT;


interface IInternetSecurityManager : IUnknown {
	HRESULT SetSecuritySite(LPINTERNETSECURITYMGRSITE pSite);
	HRESULT GetSecuritySite(LPINTERNETSECURITYMGRSITE *ppSite);
	HRESULT MapUrlToZone(LPCWSTR pwszUrl, DWORD *pdwZone, DWORD dwFlags);
	HRESULT GetSecurityId(LPCWSTR pwszUrl, BYTE *pbSecurityId, DWORD *pcbSecurityId, DWORD_PTR dwReserved);
	HRESULT ProcessUrlAction(LPCWSTR pwszUrl, DWORD dwAction, BYTE *pPolicy, DWORD cbPolicy, BYTE *pContext, DWORD cbContext, DWORD dwFlags, DWORD dwReserved);
	HRESULT QueryCustomPolicy(LPCWSTR pwszUrl, REFGUID guidKey, BYTE **ppPolicy, DWORD *pcbPolicy, BYTE *pContext, DWORD cbContext, DWORD dwReserved);
	HRESULT SetZoneMapping(DWORD dwZone, LPCWSTR lpszPattern, DWORD dwFlags);
	HRESULT GetZoneMappings(DWORD dwZone, LPENUMSTRING * ppenumString, DWORD dwFlags);
}
interface IInternetSecurityMgrSite : IUnknown {
	HRESULT EnableModeless(BOOL fEnable);
	HRESULT GetWindow(HWND *phwnd);
}
alias IInternetSecurityMgrSite LPINTERNETSECURITYMGRSITE;

interface IOleControl : IUnknown
{
	HRESULT GetControlInfo(CONTROLINFO* pCI);
	HRESULT OnMnemonic(LPMSG pMsg);
	HRESULT OnAmbientPropertyChange(DISPID dispID);
	HRESULT FreezeEvents(BOOL bFreeze);
}
alias IOleControl LPOLECONTROL;


interface IOleControlSite : IUnknown {
	HRESULT OnControlInfoChanged();
	HRESULT LockInPlaceActive(
	  BOOL fLock  //Indicates whether to ensure the active state
	);
	HRESULT GetExtendedControl(
	  LPDISPATCH* ppDisp  //Address of output variable that receives the
	                  // IDispatch interface pointer
	);
	HRESULT TransformCoords(
	  POINTL* pPtlHimetric ,  //Address of POINTL structure
	  POINTF* pPtfContainer ,  //Address of POINTF structure
	  DWORD dwFlags           //Flags indicating the exact conversion
	);
	HRESULT TranslateAccelerator(
	  LPMSG pMsg ,        //Pointer to the structure
	  DWORD grfModifiers  //Flags describing the state of the keys
	);
	HRESULT OnFocus(
	  BOOL fGotFocus  //Indicates whether the control gained focus
	);
	HRESULT ShowPropertyFrame();
}
alias IOleControlSite LPOLECONTROLSITE;


interface IPersistStreamInit : IPersist {
	HRESULT IsDirty();
	HRESULT Load(LPSTREAM pStm);
	HRESULT Save(LPSTREAM pStm, BOOL fClearDirty);
	HRESULT GetSizeMax(ULARGE_INTEGER * pcbSize);
	HRESULT InitNew();
}

interface IPropertyNotifySink : IUnknown {
	HRESULT OnChanged(DISPID dispID);
	HRESULT OnRequestEdit(DISPID dispID);
}
alias IPropertyNotifySink LPPROPERTYNOTIFYSINK;

interface IProvideClassInfo : IUnknown
{
	HRESULT GetClassInfo(LPTYPEINFO * ppTI);
}
alias IProvideClassInfo LPPROVIDECLASSINFO;

interface IProvideClassInfo2 : IProvideClassInfo
{
	HRESULT GetGUID(DWORD dwGuidKind, GUID * pGUID);
}
alias IProvideClassInfo2 LPPROVIDECLASSINFO2;


/*
interface IDocHostUIHandler : IUnknown
{
	int ShowContextMenu( int dwID, POINT* ppt, ComObj pcmdtReserved, ComObj pdispReserved);
	int GetHostInfo( int pInfo );
	int ShowUI( int dwID, ComObj pActiveObject, ComObj pCommandTarget, ComObj pFrame, ComObj pDoc );
	int HideUI();
	int UpdateUI();
	int EnableModeless( int fEnable );
	int OnDocWindowActivate( int fActivate );
	int OnFrameWindowActivate( int fActivate );
	int ResizeBorder( RECT* prcBorder, ComObj pUIWindow, int fRameWindow );
	int TranslateAccelerator( int lpMsg, int pguidCmdGroup, int nCmdID );
	int GetOptionKeyPath( int  pchKey, int dw );
	int GetDropTarget( ComObj pDropTarget, ComObj* ppDropTarget );
	int GetExternal( ComObj** ppDispatch );
	int TranslateUrl( int dwTranslate, int pchURLIn, int ppchURLOut );
	int FilterDataObject( ComObj pDO, ComObj* ppDORet );
}

interface IDocHostShowUI : IUnknown
{
	int ShowMessage( HWND hwnd, wchar* lpstrText, int lpstrCaption, int dwType, int lpstrHelpFile, int dwHelpContext, LRESULT* plResult);
	int ShowHelp( HWND hwnd, int pszHelpFile, int uCommand, int dwData, long ptMouse, ComObj pDispatchObjectHit );
}
*/
interface IServiceProvider : IUnknown {
	HRESULT QueryService(REFGUID guidService, REFCIID riid, void **ppv);
}
alias IServiceProvider LPSERVICEPROVIDER;

interface ISpecifyPropertyPages : IUnknown {
	HRESULT GetPages(
  		CAUUID *pPages  //Pointer to structure
	);
}
alias ISpecifyPropertyPages LPSPECIFYPROPERTYPAGES;







/*
interface IEnumFORMATETC : IEnumXXXX {}


interface IDataObject : IUnknown {
	int GetData(int pFormatetc, int pmedium);
	int GetDataHere(FORMATETC* pFormatetc, STGMEDIUM* pmedium);
	int QueryGetData(FORMATETC* pFormatetc);
	int GetCanonicalFormatEtc(int pFormatetcIn, int pFormatetcOut);
	int SetData(int pFormatetc, int pmedium, int fRelease);
	int EnumFormatEtc(int dwDirection, int ppenumFormatetc);
	int DAdvise(int pFormatetc, int advf, int pAdvSink, int pdwConnection);
	int DUnadvise(int dwConnection);
	int EnumDAdvise(ComObj* ppenumAdvise);
}

interface IDropSource : IUnknown {
	int QueryContinueDrag(int fEscapePressed, int grfKeyState);
	int GiveFeedback(int dwEffect);
}

interface IDropTarget : IUnknown {
	// NOTE : POINT* is splited to pt_x, pt_y
	int DragEnter(ComObj pDataObject, int grfKeyState, int pt_x, int pt_y, int pdwEffect);
	int DragOver(int grfKeyState, int pt_x,	int pt_y, int pdwEffect);
	int DragLeave();
	int Drop(ComObj pDataObject, int grfKeyState, int pt_x, int pt_y, int pdwEffect);
}
*/
