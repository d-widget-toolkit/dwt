module org.eclipse.swt.internal.ole.win32.OAIDL;

//+---------------------------------------------------------------------------
//
//  Microsoft Windows
//  Copyright 1992 - 1998 Microsoft Corporation.
//
//  File: oaidl.idl
//
//----------------------------------------------------------------------------

//private import std.c.windows.windows;
//private import std.c.windows.com;
private import org.eclipse.swt.internal.ole.win32.OBJIDL;
private import org.eclipse.swt.internal.ole.win32.COMTYPES;
private import org.eclipse.swt.internal.ole.win32.extras;
private import org.eclipse.swt.internal.win32.WINTYPES;
private import org.eclipse.swt.ole.win32.Variant;

extern(Windows) {

struct  DECIMAL
    {
    USHORT wReserved;
    BYTE scale;
    BYTE sign;
    ULONG Hi32;
    ulong Lo64;
    }	;

alias wchar * BSTR;
struct  FLAGGED_WORD_BLOB
    {
    ULONG fFlags;
    ULONG clSize;
    ushort[1] asData;
    }

alias FLAGGED_WORD_BLOB  *wireBSTR;

 struct BYTE_SIZEDARR
    {
    ULONG clSize;
    byte  *pData;
    }	;

 struct  WORD_SIZEDARR
    {
    ULONG clSize;
    ushort *pData;
    }	;

struct  DWORD_SIZEDARR
    {
    ULONG clSize;
    ULONG * pData;
    }	;

struct  HYPER_SIZEDARR
    {
    ULONG clSize;
    long *pData;
    }


enum
{	VT_EMPTY	= 0,
	VT_NULL	= 1,
	VT_I2	= 2,
	VT_I4	= 3,
	VT_R4	= 4,
	VT_R8	= 5,
	VT_CY	= 6,
	VT_DATE	= 7,
	VT_BSTR	= 8,
	VT_DISPATCH	= 9,
	VT_ERROR	= 10,
	VT_BOOL	= 11,
	VT_VARIANT	= 12,
	VT_UNKNOWN	= 13,
	VT_DECIMAL	= 14,
	VT_I1	= 16,
	VT_UI1	= 17,
	VT_UI2	= 18,
	VT_UI4	= 19,
	VT_I8	= 20,
	VT_UI8	= 21,
	VT_INT	= 22,
	VT_UINT	= 23,
	VT_VOID	= 24,
	VT_HRESULT	= 25,
	VT_PTR	= 26,
	VT_SAFEARRAY	= 27,
	VT_CARRAY	= 28,
	VT_USERDEFINED	= 29,
	VT_LPSTR	= 30,
	VT_LPWSTR	= 31,
	VT_RECORD	= 36,
	VT_FILETIME	= 64,
	VT_BLOB	= 65,
	VT_STREAM	= 66,
	VT_STORAGE	= 67,
	VT_STREAMED_OBJECT	= 68,
	VT_STORED_OBJECT	= 69,
	VT_BLOB_OBJECT	= 70,
	VT_CF	= 71,
	VT_CLSID	= 72,
	VT_BSTR_BLOB	= 0xfff,
	VT_VECTOR	= 0x1000,
	VT_ARRAY	= 0x2000,
	VT_BYREF	= 0x4000,
	VT_RESERVED	= 0x8000,
	VT_ILLEGAL	= 0xffff,
	VT_ILLEGALMASKED	= 0xfff,
	VT_TYPEMASK	= 0xfff
};


/*
cpp_quote("//+-------------------------------------------------------------------------")
cpp_quote("//")
cpp_quote("//  Microsoft Windows")
cpp_quote("//  Copyright 1992 - 1998 Microsoft Corporation.")
cpp_quote("//")
cpp_quote("//--------------------------------------------------------------------------")

cpp_quote("#if ( _MSC_VER >= 800 )")
*/
//cpp_quote("#pragma warning(disable:4201)    /* Nameless struct/union */")
/*
cpp_quote("#endif")

#ifndef DO_NO_IMPORTS
import "objidl.idl";
#endif

interface ICreateTypeInfo;
interface ICreateTypeInfo2;
interface ICreateTypeLib;
interface ICreateTypeLib2;
interface IDispatch;
interface IEnumVARIANT;
interface ITypeComp;
interface ITypeInfo;
interface ITypeInfo2;
interface ITypeLib;
interface ITypeLib2;
interface ITypeChangeEvents;
interface IErrorInfo;
interface ICreateErrorInfo;
interface ISupportErrorInfo;
interface ITypeFactory;
interface ITypeMarshal;
interface IRecordInfo;


[
  version(1.0), pointer_default(unique)
]

interface IOleAutomationTypes
{

typedef CY CURRENCY;

// #########################################################################
//      SAFEARRAY
// #########################################################################
*/
struct SAFEARRAYBOUND {
    ULONG cElements;
    LONG  lLbound;
}
alias SAFEARRAYBOUND * LPSAFEARRAYBOUND;

struct _wireVARIANT {
}
struct _wireBRECORD {
}
// Forward references.
alias _wireVARIANT * wireVARIANT;
alias _wireBRECORD * wireBRECORD;

struct SAFEARR_BSTR {
    ULONG Size;
    wireBSTR * aBstr;
}
struct SAFEARR_UNKNOWN {
    ULONG Size;
    IUnknown * apUnknown;
}

struct SAFEARR_DISPATCH {
    ULONG Size;
    IDispatch * apDispatch;
}

struct SAFEARR_VARIANT {
    ULONG Size;
    wireVARIANT * aVariant;
}

struct SAFEARR_BRECORD {
    ULONG Size;
    wireBRECORD * aRecord;
}

struct SAFEARR_HAVEIID {
    ULONG Size;
    IUnknown * apUnknown;
    IID   iid;
}

enum SF_TYPE {
    SF_ERROR    = VT_ERROR,
    SF_I1       = VT_I1,
    SF_I2       = VT_I2,
    SF_I4       = VT_I4,
    SF_I8       = VT_I8,
    SF_BSTR     = VT_BSTR,
    SF_UNKNOWN  = VT_UNKNOWN,
    SF_DISPATCH = VT_DISPATCH,
    SF_VARIANT  = VT_VARIANT,
    SF_RECORD   = VT_RECORD,
    SF_HAVEIID  = VT_UNKNOWN|VT_RESERVED,
}

union uSAFEARRAY_UNION {
SAFEARR_BSTR     BstrStr;
SAFEARR_UNKNOWN  UnknownStr;
SAFEARR_DISPATCH DispatchStr;
SAFEARR_VARIANT  VariantStr;
SAFEARR_BRECORD  RecordStr;
SAFEARR_HAVEIID  HaveIidStr;
BYTE_SIZEDARR    ByteStr;
WORD_SIZEDARR    WordStr;
DWORD_SIZEDARR   LongStr;
HYPER_SIZEDARR   HyperStr;
}

struct SAFEARRAY_UNION {
	ULONG sfType;
	uSAFEARRAY_UNION u;
}

alias SAFEARRAY_UNION SAFEARRAYUNION;

struct wireSAFEARRAY {
    USHORT cDims;
    USHORT fFeatures;
    ULONG  cbElements;
    ULONG  cLocks;
    SAFEARRAYUNION uArrayStructs;
    SAFEARRAYBOUND[1] rgsabound;
}
alias wireSAFEARRAY SAFEARRAY ;

alias wireSAFEARRAY * wirePSAFEARRAY;


struct tagSAFEARRAY {
    USHORT cDims;
    USHORT fFeatures;
    ULONG  cbElements;
    ULONG  cLocks;
    PVOID  pvData;
    SAFEARRAYBOUND[1] rgsabound;
}

alias SAFEARRAY * LPSAFEARRAY;

const USHORT FADF_AUTO       = 0x0001;  /* array is allocated on the stack */
const USHORT FADF_STATIC     = 0x0002;  /* array is staticly allocated */
const USHORT FADF_EMBEDDED   = 0x0004;  /* array is embedded in a structure */
const USHORT FADF_FIXEDSIZE  = 0x0010;  /* may not be resized or reallocated */
const USHORT FADF_RECORD     = 0x0020;  /* an array of records */
const USHORT FADF_HAVEIID    = 0x0040;  /* with FADF_DISPATCH, FADF_UNKNOWN */
                                        /* array has an IID for interfaces */
const USHORT FADF_HAVEVARTYPE= 0x0080;  /* array has a VT type */
const USHORT FADF_BSTR       = 0x0100;  /* an array of BSTRs */
const USHORT FADF_UNKNOWN    = 0x0200;  /* an array of IUnknown* */
const USHORT FADF_DISPATCH   = 0x0400;  /* an array of IDispatch* */
const USHORT FADF_VARIANT    = 0x0800;  /* an array of VARIANTs */
const USHORT FADF_RESERVED   = 0xF008;  /* reserved bits */


// #########################################################################
//      VARIANT
// #########################################################################
/*
cpp_quote("#if (__STDC__ && !defined(_FORCENAMELESSUNION)) || defined(NONAMELESSUNION)")
cpp_quote("#define __VARIANT_NAME_1 n1")
cpp_quote("#define __VARIANT_NAME_2 n2")
cpp_quote("#define __VARIANT_NAME_3 n3")
cpp_quote("#define __VARIANT_NAME_4 brecVal")
cpp_quote("#else")
cpp_quote("#define __tagVARIANT")
cpp_quote("#define __VARIANT_NAME_1")
cpp_quote("#define __VARIANT_NAME_2")
cpp_quote("#define __VARIANT_NAME_3")
cpp_quote("#define __tagBRECORD")
cpp_quote("#define __VARIANT_NAME_4")
cpp_quote("#endif")
*/

/*struct brecVal_t {
	PVOID         pvRecord;
	IRecordInfo * pRecInfo;
}*/
struct brecVal_t {
	PVOID         pvRecord;
	IUnknown * pRecInfo;
}

alias double DOUBLE;
alias double DATE;
alias VARIANT_BOOL _VARIANT_BOOL;
alias long CY;


union n3_t {
    LONG          lVal;         /* VT_I4                */
    BYTE          bVal;         /* VT_UI1               */
    SHORT         iVal;         /* VT_I2                */
    FLOAT         fltVal;       /* VT_R4                */
    DOUBLE        dblVal;       /* VT_R8                */
    VARIANT_BOOL  boolVal;      /* VT_BOOL              */
    _VARIANT_BOOL BOOLval;         /* (obsolete)           */
    SCODE         scode;        /* VT_ERROR             */
    CY            cyVal;        /* VT_CY                */
    DATE          date;         /* VT_DATE              */
    BSTR          bstrVal;      /* VT_BSTR              */
    IUnknown     punkVal;      /* VT_UNKNOWN           */
    IDispatch    pdispVal;     /* VT_DISPATCH          */
    SAFEARRAY *   parray;       /* VT_ARRAY             */
    BYTE *        pbVal;        /* VT_BYREF|VT_UI1      */
    SHORT *       piVal;        /* VT_BYREF|VT_I2       */
    LONG *        plVal;        /* VT_BYREF|VT_I4       */
    FLOAT *       pfltVal;      /* VT_BYREF|VT_R4       */
    DOUBLE *      pdblVal;      /* VT_BYREF|VT_R8       */
    VARIANT_BOOL *pboolVal;     /* VT_BYREF|VT_BOOL     */
    _VARIANT_BOOL *pbool;       /* (obsolete)           */
    SCODE *       pscode;       /* VT_BYREF|VT_ERROR    */
    CY *          pcyVal;       /* VT_BYREF|VT_CY       */
    DATE *        pdate;        /* VT_BYREF|VT_DATE     */
    BSTR *        pbstrVal;     /* VT_BYREF|VT_BSTR     */
    IUnknown *   ppunkVal;     /* VT_BYREF|VT_UNKNOWN  */
    IDispatch *   ppdispVal;    /* VT_BYREF|VT_DISPATCH */
    SAFEARRAY **  pparray;      /* VT_BYREF|VT_ARRAY    */
    VARIANT *     pvarVal;      /* VT_BYREF|VT_VARIANT  */
    PVOID         byref;        /* Generic ByRef        */
    CHAR          cVal;         /* VT_I1                */
    USHORT        uiVal;        /* VT_UI2               */
    ULONG         ulVal;        /* VT_UI4               */
    INT           intVal;       /* VT_INT               */
    UINT          uintVal;      /* VT_UINT              */
    DECIMAL *     pdecVal;      /* VT_BYREF|VT_DECIMAL  */
    CHAR *        pcVal;        /* VT_BYREF|VT_I1       */
    USHORT *      puiVal;       /* VT_BYREF|VT_UI2      */
    ULONG *       pulVal;       /* VT_BYREF|VT_UI4      */
    INT *         pintVal;      /* VT_BYREF|VT_INT      */
    UINT *        puintVal;     /* VT_BYREF|VT_UINT     */
	brecVal_t brecVal;         /* VT_RECORD            */
}

struct n2_t {
    VARTYPE vt;
    WORD    wReserved1;
    WORD    wReserved2;
    WORD    wReserved3;
    n3_t n3;
};
union n1_t {
	n2_t n2;
    DECIMAL decVal;
};

// in tango.sys.win32.Types
/+
struct VARIANT {
	n1_t n1;

	VARTYPE vt() { return n1.n2.vt; };
	void vt(VARTYPE val) { n1.n2.vt = val; }
	LONG lVal()  { return n1.n2.n3.lVal; }
	void lVal(LONG val) { return n1.n2.n3.lVal = val; }
	FLOAT fltVal()  { return n1.n2.n3.fltVal; }
	void fltVal(FLOAT val) { return n1.n2.n3.fltVal = val; }
	IDispatch pdispVal() { return n1.n2.n3.pdispVal; }
	void pdispVal(IDispatch val) { n1.n2.n3.pdispVal = val; }
	IUnknown punkVal() { return n1.n2.n3.punkVal; }
	void punkVal(IUnknown val) { n1.n2.n3.punkVal = val; }
	VARIANT_BOOL boolVal() { return n1.n2.n3.boolVal; }
	void boolVal(VARIANT_BOOL val) { n1.n2.n3.boolVal = val; }
	SHORT iVal() { return n1.n2.n3.iVal; }
	void iVal(SHORT val) { n1.n2.n3.iVal = val; }
	BSTR bstrVal() { return n1.n2.n3.bstrVal; }
	void bstrVal(BSTR val) { n1.n2.n3.bstrVal = val; }

};
+/


/*
struct VARIANT {
	LONG[4] mmmm;
}
*/
alias VARIANT * LPVARIANT;
alias VARIANT VARIANTARG;
alias VARIANT * LPVARIANTARG;

/+
struct _wireBRECORD {
    ULONG fFlags;
    ULONG clSize;
    IRecordInfo pRecInfo;
    byte * pRecord;
};
++++++++++++++++++++/


/+
struct _wireVARIANT {
    DWORD  clSize;
    DWORD  rpcReserved;
    USHORT vt;
    USHORT wReserved1;
    USHORT wReserved2;
    USHORT wReserved3;
    [switch_type(ULONG), switch_is(vt)] union {
    [case(VT_I4)]       LONG          lVal;         /* VT_I4                */
    [case(VT_UI1)]      BYTE          bVal;         /* VT_UI1               */
    [case(VT_I2)]       SHORT         iVal;         /* VT_I2                */
    [case(VT_R4)]       FLOAT         fltVal;       /* VT_R4                */
    [case(VT_R8)]       DOUBLE        dblVal;       /* VT_R8                */
    [case(VT_BOOL)]     VARIANT_BOOL  boolVal;      /* VT_BOOL              */
    [case(VT_ERROR)]    SCODE         scode;        /* VT_ERROR             */
    [case(VT_CY)]       CY            cyVal;        /* VT_CY                */
    [case(VT_DATE)]     DATE          date;         /* VT_DATE              */
    [case(VT_BSTR)]     wireBSTR      bstrVal;      /* VT_BSTR              */
    [case(VT_UNKNOWN)]  IUnknown *    punkVal;      /* VT_UNKNOWN           */
    [case(VT_DISPATCH)] IDispatch *   pdispVal;     /* VT_DISPATCH          */
    [case(VT_ARRAY)]    wireSAFEARRAY parray;       /* VT_ARRAY             */

    [case(VT_RECORD, VT_RECORD|VT_BYREF)]
                        wireBRECORD   brecVal;      /* VT_RECORD            */

    [case(VT_UI1|VT_BYREF)]
                        BYTE *        pbVal;        /* VT_BYREF|VT_UI1      */
    [case(VT_I2|VT_BYREF)]
                        SHORT *       piVal;        /* VT_BYREF|VT_I2       */
    [case(VT_I4|VT_BYREF)]
                        LONG *        plVal;        /* VT_BYREF|VT_I4       */
    [case(VT_R4|VT_BYREF)]
                        FLOAT *       pfltVal;      /* VT_BYREF|VT_R4       */
    [case(VT_R8|VT_BYREF)]
                        DOUBLE *      pdblVal;      /* VT_BYREF|VT_R8       */
    [case(VT_BOOL|VT_BYREF)]
                        VARIANT_BOOL *pboolVal;     /* VT_BYREF|VT_BOOL     */
    [case(VT_ERROR|VT_BYREF)]
                        SCODE *       pscode;       /* VT_BYREF|VT_ERROR    */
    [case(VT_CY|VT_BYREF)]
                        CY *          pcyVal;       /* VT_BYREF|VT_CY       */
    [case(VT_DATE|VT_BYREF)]
                        DATE *        pdate;        /* VT_BYREF|VT_DATE     */
    [case(VT_BSTR|VT_BYREF)]
                        wireBSTR *    pbstrVal;     /* VT_BYREF|VT_BSTR     */
    [case(VT_UNKNOWN|VT_BYREF)]
                        IUnknown **   ppunkVal;     /* VT_BYREF|VT_UNKNOWN  */
    [case(VT_DISPATCH|VT_BYREF)]
                        IDispatch **  ppdispVal;    /* VT_BYREF|VT_DISPATCH */
    [case(VT_ARRAY|VT_BYREF)]
                        wireSAFEARRAY *pparray;     /* VT_BYREF|VT_ARRAY    */
    [case(VT_VARIANT|VT_BYREF)]
                        wireVARIANT * pvarVal;      /* VT_BYREF|VT_VARIANT  */

    [case(VT_I1)]       CHAR          cVal;         /* VT_I1                */
    [case(VT_UI2)]      USHORT        uiVal;        /* VT_UI2               */
    [case(VT_UI4)]      ULONG         ulVal;        /* VT_UI4               */
    [case(VT_INT)]      INT           intVal;       /* VT_INT               */
    [case(VT_UINT)]     UINT          uintVal;      /* VT_UINT              */
    [case(VT_DECIMAL)]  DECIMAL       decVal;       /* VT_DECIMAL           */

    [case(VT_BYREF|VT_DECIMAL)]
                        DECIMAL *     pdecVal;      /* VT_BYREF|VT_DECIMAL  */
    [case(VT_BYREF|VT_I1)]
                        CHAR *        pcVal;        /* VT_BYREF|VT_I1       */
    [case(VT_BYREF|VT_UI2)]
                        USHORT *      puiVal;       /* VT_BYREF|VT_UI2      */
    [case(VT_BYREF|VT_UI4)]
                        ULONG *       pulVal;       /* VT_BYREF|VT_UI4      */
    [case(VT_BYREF|VT_INT)]
                        INT *         pintVal;      /* VT_BYREF|VT_INT      */
    [case(VT_BYREF|VT_UINT)]
                        UINT *        puintVal;     /* VT_BYREF|VT_UINT     */
    [case(VT_EMPTY)]    ;                           /* nothing              */
    [case(VT_NULL)]     ;                           /* nothing              */
    };
};
+/

//########################################################################
//     End of VARIANT & SAFEARRAY
//########################################################################


//TypeInfo stuff.

alias LONG DISPID;
alias DISPID MEMBERID;
alias DWORD HREFTYPE;

enum TYPEKIND {
    TKIND_ENUM = 0,
    TKIND_RECORD,
    TKIND_MODULE,
    TKIND_INTERFACE,
    TKIND_DISPATCH,
    TKIND_COCLASS,
    TKIND_ALIAS,
    TKIND_UNION,
    TKIND_MAX                   /* end of enum marker */
}
union TD_00{
        TYPEDESC * lptdesc;
        ARRAYDESC * lpadesc;
		  HREFTYPE hreftype;
};

struct TYPEDESC {
    TD_00 u;
    VARTYPE vt;
}

struct ARRAYDESC {
    TYPEDESC tdescElem;         /* element type */
    USHORT cDims;               /* dimension count */
    SAFEARRAYBOUND[1] rgbounds; /* var len array of bounds */
}

// parameter description
struct PARAMDESCEX {
    ULONG cBytes;               /* size of this structure */
    VARIANTARG varDefaultValue; /* default value of this parameter */
}
alias PARAMDESCEX * LPPARAMDESCEX;

struct PARAMDESC {
    LPPARAMDESCEX pparamdescex; /* valid if PARAMFLAG_FHASDEFAULT bit is set */
    USHORT wParamFlags;         /* IN, OUT, etc */
}
alias PARAMDESC * LPPARAMDESC;

const USHORT PARAMFLAG_NONE         = 0x00;
const USHORT PARAMFLAG_FIN          = 0x01;
const USHORT PARAMFLAG_FOUT         = 0x02;
const USHORT PARAMFLAG_FLCID        = 0x04;
const USHORT PARAMFLAG_FRETVAL      = 0x08;
const USHORT PARAMFLAG_FOPT         = 0x10;
const USHORT PARAMFLAG_FHASDEFAULT  = 0x20;
const USHORT PARAMFLAG_FHASCUSTDATA = 0x40;

struct IDLDESC {
    ULONG_PTR dwReserved;
    USHORT wIDLFlags;           /* IN, OUT, etc */
}
alias IDLDESC * LPIDLDESC;

const USHORT IDLFLAG_NONE    = PARAMFLAG_NONE;
const USHORT IDLFLAG_FIN     = PARAMFLAG_FIN;
const USHORT IDLFLAG_FOUT    = PARAMFLAG_FOUT;
const USHORT IDLFLAG_FLCID   = PARAMFLAG_FLCID;
const USHORT IDLFLAG_FRETVAL = PARAMFLAG_FRETVAL;


struct ELEMDESC {    /* a format that MIDL likes */
    TYPEDESC tdesc;             /* the type of the element */
    PARAMDESC paramdesc;        /* IDLDESC is a subset of PARAMDESC */
}

struct TYPEATTR {
    GUID guid;                  /* the GUID of the TypeInfo */
    LCID lcid;                  /* locale of member names and doc strings */
    DWORD dwReserved;
    MEMBERID memidConstructor;  /* ID of constructor, MEMBERID_NIL if none */
    MEMBERID memidDestructor;   /* ID of destructor, MEMBERID_NIL if none */
    LPOLESTR lpstrSchema;
    ULONG cbSizeInstance;       /* the size of an instance of this type */
    TYPEKIND typekind;          /* the kind of type this typeinfo describes */
    WORD cFuncs;                /* number of functions */
    WORD cVars;                 /* number of variables / data members */
    WORD cImplTypes;            /* number of implemented interfaces */
    WORD cbSizeVft;             /* the size of this types virtual func table */
    WORD cbAlignment;           /* specifies the alignment requirements for
                                   an instance of this type,
                                   0 = align on 64k boundary
                                   1 = byte align
                                   2 = word align
                                   4 = dword align... */
    WORD wTypeFlags;
    WORD wMajorVerNum;          /* major version number */
    WORD wMinorVerNum;          /* minor version number */
    TYPEDESC tdescAlias;        /* if typekind == TKIND_ALIAS this field
                                   specifies the type for which this type
                                   is an alias */
    IDLDESC idldescType;        /* IDL attributes of the described type */
}
alias TYPEATTR * LPTYPEATTR;


struct DISPPARAMS {
    VARIANTARG * rgvarg;
    DISPID * rgdispidNamedArgs;
    UINT cArgs;
    UINT cNamedArgs;
}

struct EXCEPINFO {
    WORD  wCode;            /* An error code describing the error. */
    WORD  wReserved;
    BSTR  bstrSource;       /* A source of the exception */
    BSTR  bstrDescription;  /* A description of the error */
    BSTR  bstrHelpFile;     /* Fully qualified drive, path, and file name */
    DWORD dwHelpContext;    /* help context of topic within the help file */
    ULONG pvReserved;
    ULONG pfnDeferredFillIn;
    SCODE scode;
}
/+

cpp_quote("#else /* 0 */")
cpp_quote("typedef struct tagEXCEPINFO {")
cpp_quote("    WORD  wCode;")
cpp_quote("    WORD  wReserved;")
cpp_quote("    BSTR  bstrSource;")
cpp_quote("    BSTR  bstrDescription;")
cpp_quote("    BSTR  bstrHelpFile;")
cpp_quote("    DWORD dwHelpContext;")
cpp_quote("    PVOID pvReserved;")
cpp_quote("    HRESULT (__stdcall *pfnDeferredFillIn)(struct tagEXCEPINFO *);")
cpp_quote("    SCODE scode;")
cpp_quote("} EXCEPINFO, * LPEXCEPINFO;")
cpp_quote("#endif /* 0 */")
+/

enum CALLCONV {
    CC_FASTCALL = 0,
    CC_CDECL = 1,
    CC_MSCPASCAL,
    CC_PASCAL = CC_MSCPASCAL,
    CC_MACPASCAL,
    CC_STDCALL,
    CC_FPFASTCALL,
    CC_SYSCALL,
    CC_MPWCDECL,
    CC_MPWPASCAL,
    CC_MAX          /* end of enum marker */
}
enum FUNCKIND {
    FUNC_VIRTUAL,
    FUNC_PUREVIRTUAL,
    FUNC_NONVIRTUAL,
    FUNC_STATIC,
    FUNC_DISPATCH
}

enum INVOKEKIND {
    INVOKE_FUNC = 1,
    INVOKE_PROPERTYGET = 2,
    INVOKE_PROPERTYPUT = 4,
    INVOKE_PROPERTYPUTREF = 8
}

struct FUNCDESC {
    MEMBERID memid;
    SCODE * lprgscode;
    ELEMDESC * lprgelemdescParam; /* array of param types */
    FUNCKIND funckind;
    INVOKEKIND invkind;
    CALLCONV callconv;
    SHORT cParams;
    SHORT cParamsOpt;
    SHORT oVft;
    SHORT cScodes;
    ELEMDESC elemdescFunc;
    WORD wFuncFlags;
}
alias FUNCDESC * LPFUNCDESC;

enum VARKIND {
    VAR_PERINSTANCE,
    VAR_STATIC,
    VAR_CONST,
    VAR_DISPATCH
}
/* IMPLTYPE Flags */
const USHORT IMPLTYPEFLAG_FDEFAULT      = 0x1;
const USHORT IMPLTYPEFLAG_FSOURCE       = 0x2;
const USHORT IMPLTYPEFLAG_FRESTRICTED   = 0x4;
const USHORT IMPLTYPEFLAG_FDEFAULTVTABLE= 0x8;

union VD_u {
        /* offset of variable within the instance */
	ULONG oInst;
	VARIANT * lpvarValue; /* the value of the constant */
}
struct VARDESC {
    MEMBERID memid;
    LPOLESTR lpstrSchema;
    VD_u u;
    ELEMDESC elemdescVar;
    WORD     wVarFlags;
    VARKIND  varkind;
}
alias VARDESC * LPVARDESC;

enum TYPEFLAGS {
    TYPEFLAG_FAPPOBJECT = 0x01,
    TYPEFLAG_FCANCREATE = 0x02,
    TYPEFLAG_FLICENSED = 0x04,
    TYPEFLAG_FPREDECLID = 0x08,
    TYPEFLAG_FHIDDEN = 0x10,
    TYPEFLAG_FCONTROL = 0x20,
    TYPEFLAG_FDUAL = 0x40,
    TYPEFLAG_FNONEXTENSIBLE = 0x80,
    TYPEFLAG_FOLEAUTOMATION = 0x100,
    TYPEFLAG_FRESTRICTED = 0x200,
    TYPEFLAG_FAGGREGATABLE = 0x400,
    TYPEFLAG_FREPLACEABLE = 0x800,
    TYPEFLAG_FDISPATCHABLE = 0x1000,
    TYPEFLAG_FREVERSEBIND = 0x2000
}

enum FUNCFLAGS {
    FUNCFLAG_FRESTRICTED = 0x1,
    FUNCFLAG_FSOURCE = 0x2,
    FUNCFLAG_FBINDABLE = 0x4,
    FUNCFLAG_FREQUESTEDIT = 0x8,
    FUNCFLAG_FDISPLAYBIND = 0x10,
    FUNCFLAG_FDEFAULTBIND = 0x20,
    FUNCFLAG_FHIDDEN = 0x40,
    FUNCFLAG_FUSESGETLASTERROR = 0x80,
    FUNCFLAG_FDEFAULTCOLLELEM = 0x100,
    FUNCFLAG_FUIDEFAULT = 0x200,
    FUNCFLAG_FNONBROWSABLE = 0x400,
    FUNCFLAG_FREPLACEABLE = 0x800,
    FUNCFLAG_FIMMEDIATEBIND = 0x1000
}

enum VARFLAGS {
    VARFLAG_FREADONLY = 0x1,
    VARFLAG_FSOURCE = 0x2,
    VARFLAG_FBINDABLE = 0x4,
    VARFLAG_FREQUESTEDIT = 0x8,
    VARFLAG_FDISPLAYBIND = 0x10,
    VARFLAG_FDEFAULTBIND = 0x20,
    VARFLAG_FHIDDEN = 0x40,
    VARFLAG_FRESTRICTED = 0x80,
    VARFLAG_FDEFAULTCOLLELEM = 0x100,
    VARFLAG_FUIDEFAULT = 0x200,
    VARFLAG_FNONBROWSABLE = 0x400,
    VARFLAG_FREPLACEABLE = 0x800,
    VARFLAG_FIMMEDIATEBIND = 0x1000
}

struct CLEANLOCALSTORAGE {
    IUnknown pInterface;      /* interface that is responsible for storage */
    PVOID pStorage;             /* the storage being managed by interface */
    DWORD flags;                /* which interface, what storage */
}

struct CUSTDATAITEM {
    GUID guid;           /* guid identifying this custom data item */
    VARIANTARG varValue; /* value of this custom data item */
}
alias CUSTDATAITEM * LPCUSTDATAITEM;

struct CUSTDATA {
    DWORD cCustData;            /* number of custom data items in rgCustData */
    LPCUSTDATAITEM prgCustData;
                                /* array of custom data items */
}
alias CUSTDATA * LPCUSTDATA;


interface ICreateTypeInfo: IUnknown
{
    HRESULT SetGuid( REFGUID guid );
    HRESULT SetTypeFlags( UINT uTypeFlags );
    HRESULT SetDocString( LPOLESTR pStrDoc );
    HRESULT SetHelpContext( DWORD dwHelpContext);
    HRESULT SetVersion( WORD wMajorVerNum, WORD wMinorVerNum );
    HRESULT AddRefTypeInfo( ITypeInfo pTInfo, HREFTYPE * phRefType );
    HRESULT AddFuncDesc( UINT index, FUNCDESC * pFuncDesc            );
    HRESULT AddImplType( UINT index, HREFTYPE hRefType             );
    HRESULT SetImplTypeFlags( UINT index, INT implTypeFlags            );
    HRESULT SetAlignment( WORD cbAlignment             );
    HRESULT SetSchema( LPOLESTR pStrSchema            );
    HRESULT AddVarDesc( UINT index, VARDESC * pVarDesc            );
    HRESULT SetFuncAndParamNames( UINT index, LPOLESTR * rgszNames, UINT cNames );
    HRESULT SetVarName( UINT index, LPOLESTR szName         );
    HRESULT SetTypeDescAlias( TYPEDESC * pTDescAlias    );
    HRESULT DefineFuncAsDllEntry( UINT index,LPOLESTR szDllName,LPOLESTR szProcName            );
    HRESULT SetFuncDocString( UINT index, LPOLESTR szDocString            );
    HRESULT SetVarDocString(UINT index,LPOLESTR szDocString            );
    HRESULT SetFuncHelpContext(UINT index,DWORD dwHelpContext            );
    HRESULT SetVarHelpContext(UINT index,DWORD dwHelpContext            );
    HRESULT SetMops(UINT index,BSTR bstrMops            );
    HRESULT SetTypeIdldesc(IDLDESC * pIdlDesc            );
    HRESULT LayOut();
}
alias ICreateTypeInfo LPCREATETYPEINFO;

interface ICreateTypeInfo2: ICreateTypeInfo
{
	HRESULT DeleteFuncDesc(UINT index);
	HRESULT DeleteFuncDescByMemId(MEMBERID memid,INVOKEKIND invKind);
	HRESULT DeleteVarDesc(UINT index);
	HRESULT DeleteVarDescByMemId(MEMBERID memid);
	HRESULT DeleteImplType(UINT index);
	HRESULT SetCustData(REFGUID guid,VARIANT * pVarVal);
	HRESULT SetFuncCustData(UINT index,REFGUID guid,VARIANT * pVarVal);
	HRESULT SetParamCustData(UINT indexFunc,UINT indexParam,REFGUID guid,VARIANT * pVarVal);
	HRESULT SetVarCustData(UINT index,REFGUID guid,VARIANT * pVarVal);
	HRESULT SetImplTypeCustData(UINT index,REFGUID guid,VARIANT * pVarVal);
	HRESULT SetHelpStringContext(ULONG dwHelpStringContext);
	HRESULT SetFuncHelpStringContext(UINT index,ULONG dwHelpStringContext);
	HRESULT SetVarHelpStringContext(UINT index,ULONG dwHelpStringContext);
	HRESULT Invalidate();
	HRESULT SetName(LPOLESTR szName);
}
alias ICreateTypeInfo2 LPCREATETYPEINFO2;

interface ICreateTypeLib : IUnknown
{
	HRESULT CreateTypeInfo(LPOLESTR szName,TYPEKIND tkind,ICreateTypeInfo * ppCTInfo);
	HRESULT SetName(LPOLESTR szName);
	HRESULT SetVersion(WORD wMajorVerNum,WORD wMinorVerNum);
	HRESULT SetGuid(REFGUID guid);
	HRESULT SetDocString( LPOLESTR szDoc);
	HRESULT SetHelpFileName(LPOLESTR szHelpFileName);
	HRESULT SetHelpContext(DWORD dwHelpContext);
	HRESULT SetLcid(LCID lcid);
	HRESULT SetLibFlags(UINT uLibFlags);
	HRESULT SaveAllChanges();
}
alias ICreateTypeLib LPCREATETYPELIB;

interface ICreateTypeLib2 : ICreateTypeLib
{
	HRESULT DeleteTypeInfo(LPOLESTR szName);
	HRESULT SetCustData(REFGUID guid,VARIANT * pVarVal);
	HRESULT SetHelpStringContext(ULONG dwHelpStringContext);
	HRESULT SetHelpStringDll(LPOLESTR szFileName);
}

interface IDispatch : IUnknown
{
HRESULT GetTypeInfoCount(UINT * pctinfo);
HRESULT GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo * ppTInfo);
HRESULT GetIDsOfNames(REFCIID riid, LPCOLESTR * rgszNames, UINT cNames, LCID lcid, DISPID * rgDispId);
HRESULT Invoke(DISPID dispIdMember,REFIID riid,LCID lcid,WORD wFlags,DISPPARAMS* pDispParams,VARIANT* pVarResult,EXCEPINFO* pExcepInfo,UINT* puArgErr);
}
alias IDispatch LPDISPATCH;
const DISPID DISPID_UNKNOWN = cast(DISPID)-1;
const DISPID DISPID_VALUE = cast(DISPID)0;
const DISPID DISPID_PROPERTYPUT = cast(DISPID)-3;
const DISPID DISPID_NEWENUM = cast(DISPID)-4;
const DISPID DISPID_EVALUATE = cast(DISPID)-5;
const DISPID DISPID_CONSTRUCTOR = cast(DISPID)-6;
const DISPID DISPID_DESTRUCTOR = cast(DISPID)-7;
const DISPID DISPID_COLLECT = cast(DISPID)-8;

/+++++++++++++++++++++++++++++++++++++++

[
    object,
    uuid(00020404-0000-0000-C000-000000000046),
    pointer_default(unique)
]

interface IEnumVARIANT : IUnknown
{
    typedef [unique] IEnumVARIANT* LPENUMVARIANT;

    [local]
    HRESULT Next(
                [in] ULONG celt,
                [out, size_is(celt), length_is(*pCeltFetched)] VARIANT * rgVar,
                [out] ULONG * pCeltFetched
            );

    [call_as(Next)]
    HRESULT RemoteNext(
                [in] ULONG celt,
                [out, size_is(celt), length_is(*pCeltFetched)] VARIANT * rgVar,
                [out] ULONG * pCeltFetched
            );

    HRESULT Skip(
                [in] ULONG celt
            );

    HRESULT Reset(
            );

    HRESULT Clone(
                [out] IEnumVARIANT ** ppEnum
            );
}


+/
enum DESCKIND {
        DESCKIND_NONE = 0,
        DESCKIND_FUNCDESC,
        DESCKIND_VARDESC,
        DESCKIND_TYPECOMP,
        DESCKIND_IMPLICITAPPOBJ,
        DESCKIND_MAX
}


union BINDPTR {
        FUNCDESC  * lpfuncdesc;
        VARDESC   * lpvardesc;
        ITypeComp lptcomp;
}
alias BINDPTR * LPBINDPTR;

interface ITypeComp : IUnknown
{

    HRESULT Bind(LPOLESTR szName,ULONG lHashVal,WORD wFlags,
ITypeInfo * ppTInfo,DESCKIND * pDescKind,BINDPTR * pBindPtr
            );


    HRESULT BindType( LPOLESTR szName,ULONG lHashVal,
						ITypeInfo * ppTInfo,
						ITypeComp * ppTComp
            );

}

interface ITypeInfo : IUnknown
{
    HRESULT GetTypeAttr(TYPEATTR ** ppTypeAttr);
    HRESULT GetTypeComp( ITypeComp * ppTComp );
    HRESULT GetFuncDesc( UINT index, FUNCDESC ** ppFuncDesc );
    HRESULT GetVarDesc( UINT index,VARDESC ** ppVarDesc);
    HRESULT GetNames(MEMBERID memid,BSTR * rgBstrNames,UINT cMaxNames,UINT * pcNames);
    HRESULT GetRefTypeOfImplType(UINT index,HREFTYPE * pRefType);
    HRESULT GetImplTypeFlags(UINT index,INT * pImplTypeFlags);
    HRESULT GetIDsOfNames(LPOLESTR * rgszNames,UINT cNames,MEMBERID * pMemId);
    HRESULT Invoke(PVOID pvInstance,MEMBERID memid,WORD wFlags,DISPPARAMS * pDispParams,VARIANT * pVarResult,EXCEPINFO * pExcepInfo,UINT * puArgErr);
    HRESULT GetDocumentation(MEMBERID memid,BSTR * pBstrName,BSTR * pBstrDocString,DWORD * pdwHelpContext,BSTR * pBstrHelpFile);
    HRESULT GetDllEntry(MEMBERID memid,INVOKEKIND invKind,BSTR * pBstrDllName,BSTR * pBstrName,WORD * pwOrdinal);
    HRESULT GetRefTypeInfo(HREFTYPE hRefType,ITypeInfo * ppTInfo);
    HRESULT AddressOfMember(MEMBERID memid,INVOKEKIND invKind,PVOID * ppv);
    HRESULT CreateInstance(IUnknown pUnkOuter,REFIID riid,PVOID * ppvObj);
    HRESULT GetMops(MEMBERID memid,BSTR * pBstrMops);
    HRESULT GetContainingTypeLib( ITypeLib ** ppTLib,UINT * pIndex);
    void ReleaseTypeAttr(TYPEATTR * pTypeAttr );
    void ReleaseFuncDesc( FUNCDESC * pFuncDesc  );
    void ReleaseVarDesc(VARDESC * pVarDesc            );
}
alias ITypeInfo LPTYPEINFO;

interface ITypeInfo2 : ITypeInfo
{
	HRESULT GetTypeKind(TYPEKIND * pTypeKind);
	HRESULT GetTypeFlags(ULONG * pTypeFlags);
	HRESULT GetFuncIndexOfMemId(MEMBERID memid,INVOKEKIND invKind,UINT * pFuncIndex);
	HRESULT GetVarIndexOfMemId(MEMBERID memid,UINT * pVarIndex);
	HRESULT GetCustData(REFGUID guid,VARIANT * pVarVal);
	HRESULT GetFuncCustData(UINT index,REFGUID guid,VARIANT * pVarVal);
	HRESULT GetParamCustData(UINT indexFunc,UINT indexParam,REFGUID guid,VARIANT * pVarVal);
	HRESULT GetVarCustData(UINT index,REFGUID guid,VARIANT * pVarVal);
	HRESULT GetImplTypeCustData(UINT index,REFGUID guid,VARIANT * pVarVal);
	HRESULT GetDocumentation2(MEMBERID memid,LCID lcid,BSTR *pbstrHelpString,DWORD *pdwHelpStringContext,BSTR *pbstrHelpStringDll);
	HRESULT GetAllCustData(CUSTDATA * pCustData);
	HRESULT GetAllFuncCustData(UINT index,CUSTDATA * pCustData);
	HRESULT GetAllParamCustData(UINT indexFunc,UINT indexParam,CUSTDATA * pCustData);
	HRESULT GetAllVarCustData(UINT index,CUSTDATA * pCustData);
	HRESULT GetAllImplTypeCustData(UINT index,CUSTDATA * pCustData);
}

alias ITypeInfo2 LPTYPEINFO2;

enum SYSKIND {
        SYS_WIN16 = 0,
        SYS_WIN32,
        SYS_MAC
}

enum LIBFLAGS {
        LIBFLAG_FRESTRICTED = 0x01,
        LIBFLAG_FCONTROL = 0x02,
        LIBFLAG_FHIDDEN = 0x04,
        LIBFLAG_FHASDISKIMAGE = 0x08
}

struct TLIBATTR {
        GUID guid;
        LCID lcid;
        SYSKIND syskind;
        WORD wMajorVerNum;
        WORD wMinorVerNum;
        WORD wLibFlags;
}
alias TLIBATTR * LPTLIBATTR;

interface ITypeLib : IUnknown
{
    UINT GetTypeInfoCount(
            );

    HRESULT GetTypeInfo(
	UINT index,
ITypeInfo * ppTInfo
            );

HRESULT GetTypeInfoType(
	UINT index,
	TYPEKIND * pTKind
            );

   HRESULT GetTypeInfoOfGuid(
	REFGUID guid,
	ITypeInfo * ppTinfo
            );

    HRESULT GetLibAttr(
			TLIBATTR ** ppTLibAttr
);

    HRESULT GetTypeComp(ITypeComp * ppTComp            );

    HRESULT GetDocumentation(INT index,BSTR * pBstrName,BSTR * pBstrDocString,DWORD * pdwHelpContext,BSTR * pBstrHelpFile
            );

    HRESULT IsName(LPOLESTR szNameBuf,ULONG lHashVal,BOOL * pfName
            );

    HRESULT FindName(
			LPOLESTR szNameBuf,
			ULONG lHashVal,
			ITypeInfo * ppTInfo,
			MEMBERID * rgMemId,
			USHORT * pcFound
	);

    void ReleaseTLibAttr(		TLIBATTR * pTLibAttr            );
}

alias ITypeLib  LPTYPELIB;

interface ITypeLib2 : ITypeLib
{
	HRESULT GetCustData(REFGUID guid,VARIANT * pVarVal);
	HRESULT GetLibStatistics(ULONG * pcUniqueNames,ULONG * pcchUniqueNames);
	HRESULT GetDocumentation2(INT index,LCID lcid,BSTR *pbstrHelpString,DWORD *pdwHelpStringContext,BSTR *pbstrHelpStringDll);
	HRESULT GetAllCustData(CUSTDATA * pCustData);
}
alias ITypeLib2 LPTYPELIB2;

enum CHANGEKIND {
        CHANGEKIND_ADDMEMBER,
        CHANGEKIND_DELETEMEMBER,
        CHANGEKIND_SETNAMES,
        CHANGEKIND_SETDOCUMENTATION,
        CHANGEKIND_GENERAL,
        CHANGEKIND_INVALIDATE,
        CHANGEKIND_CHANGEFAILED,
        CHANGEKIND_MAX,
        ADDMEMBER    = CHANGEKIND_ADDMEMBER,
        DELETEMEMBER = CHANGEKIND_DELETEMEMBER,
        SETNAMES     = CHANGEKIND_SETNAMES,
        SETDOCUMENTATION = CHANGEKIND_SETDOCUMENTATION,
        GENERAL          = CHANGEKIND_GENERAL,
        INVALIDATE       = CHANGEKIND_INVALIDATE,
        CHANGEFAILED     = CHANGEKIND_CHANGEFAILED,
        MAX       = CHANGEKIND_MAX
}

interface ITypeChangeEvents: IUnknown
{
    // notification messages used by the dynamic typeinfo protocol.
    HRESULT RequestTypeChange(CHANGEKIND changeKind,ITypeInfo pTInfoBefore,LPOLESTR pStrName,INT * pfCancel);
    HRESULT AfterTypeChange(CHANGEKIND changeKind,ITypeInfo pTInfoAfter,LPOLESTR pStrName);
}
alias ITypeChangeEvents LPTYPECHANGEEVENTS;

interface IErrorInfo: IUnknown
{
	HRESULT GetGUID( GUID * pGUID );
	HRESULT GetSource(BSTR * pBstrSource);
	HRESULT GetDescription(BSTR * pBstrDescription);
	HRESULT GetHelpFile(BSTR * pBstrHelpFile);
	HRESULT GetHelpContext(DWORD * pdwHelpContext);
}
alias IErrorInfo LPERRORINFO;

interface ICreateErrorInfo: IUnknown
{
	HRESULT SetGUID(REFGUID rguid);
	HRESULT SetSource(LPOLESTR szSource);
	HRESULT SetDescription(LPOLESTR szDescription);
	HRESULT SetHelpFile(LPOLESTR szHelpFile);
	HRESULT SetHelpContext(DWORD dwHelpContext);
}
alias ICreateErrorInfo LPCREATEERRORINFO;

interface ISupportErrorInfo: IUnknown
{
	HRESULT InterfaceSupportsErrorInfo(REFIID riid);
}
alias ISupportErrorInfo LPSUPPORTERRORINFO;

interface ITypeFactory : IUnknown
{
	HRESULT CreateFromTypeInfo(ITypeInfo pTypeInfo,REFIID riid, IUnknown *ppv);
}

interface ITypeMarshal : IUnknown
{
    HRESULT Size(PVOID pvType,DWORD dwDestContext,PVOID pvDestContext,ULONG * pSize);
    HRESULT Marshal(PVOID pvType,DWORD dwDestContext,PVOID pvDestContext,ULONG cbBufferLength,BYTE  * pBuffer,ULONG * pcbWritten);
    HRESULT Unmarshal(PVOID pvType,DWORD dwFlags,ULONG cbBufferLength,BYTE  * pBuffer,ULONG * pcbRead);
    HRESULT Free(PVOID pvType);
}


interface IRecordInfo: IUnknown
{
	HRESULT RecordInit(PVOID pvNew);
	HRESULT RecordClear(PVOID pvExisting);
	HRESULT RecordCopy(PVOID pvExisting,PVOID pvNew);
	HRESULT GetGuid(GUID * pguid);
	HRESULT GetName(BSTR * pbstrName);
	HRESULT GetSize(ULONG * pcbSize);
	HRESULT GetTypeInfo(ITypeInfo * ppTypeInfo);
	HRESULT GetField(PVOID pvData,LPCOLESTR szFieldName,VARIANT * pvarField);
	HRESULT GetFieldNoCopy(PVOID pvData,LPCOLESTR szFieldName,VARIANT * pvarField,PVOID * ppvDataCArray);
	HRESULT PutField(ULONG wFlags,PVOID pvData,LPCOLESTR szFieldName,VARIANT * pvarField);
	HRESULT PutFieldNoCopy(ULONG wFlags,PVOID pvData,LPCOLESTR szFieldName,VARIANT * pvarField);
	HRESULT GetFieldNames(ULONG * pcNames,BSTR * rgBstrNames);
	BOOL IsMatchingType(IRecordInfo pRecordInfo);
	PVOID RecordCreate();
	HRESULT RecordCreateCopy(PVOID pvSource,PVOID * ppvDest);
	HRESULT RecordDestroy(PVOID pvRecord);
}
alias IRecordInfo LPRECORDINFO;

} // extern(WIndows);


