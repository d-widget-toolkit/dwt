/*
 * extra COM types not define in any other modules
 * don't import this module directly, import std.internal.ole.win32.com instead
 *
 * author : Shawn Liu
 */

module org.eclipse.swt.internal.ole.win32.COMTYPES;

private import org.eclipse.swt.internal.win32.WINTYPES;
private import org.eclipse.swt.internal.ole.win32.extras;
import java.lang.util;
//private import std.c.windows.windows;
//private import std.c.windows.com;

// private import org.eclipse.swt.internal.ole.win32.extras;


alias WCHAR OLECHAR;
alias OLECHAR *LPOLESTR;
alias TryConst!(OLECHAR) *LPCOLESTR;

alias IID* LPIID;
alias HRESULT STDAPI;
alias DWORD OLE_COLOR;

// for temp use
// alias void* ComObj;

struct CAUUID {
    ULONG cElems;
    GUID* pElems;
}
struct CONNECTDATA
{
	LPUNKNOWN pUnk;
	DWORD dwCookie;
}

struct CONTROLINFO {
    ULONG  cb;
    HACCEL hAccel;
    USHORT cAccel;
    DWORD  dwFlags;
}

struct LICINFO {
    ULONG cbLicInfo;
    BOOL  fRuntimeKeyAvail;
    BOOL  fLicVerified;
}

struct POINTF
{
    FLOAT x;
    FLOAT y;
}







