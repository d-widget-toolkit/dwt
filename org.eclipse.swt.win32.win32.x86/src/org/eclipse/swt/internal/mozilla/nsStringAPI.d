module org.eclipse.swt.internal.mozilla.nsStringAPI;

import java.lang.all;
import org.eclipse.swt.internal.mozilla.Common;

extern (System):

/******************************************************************************

******************************************************************************/

enum
{
    NS_STRING_CONTAINER_INIT_DEPEND = 2,
    NS_STRING_CONTAINER_INIT_ADOPT = 4,
    NS_STRING_CONTAINER_INIT_SUBSTRING = 8,
}

nsresult    NS_StringContainerInit ( nsStringContainer *aContainer );
nsresult    NS_StringContainerInit2( nsStringContainer *aContainer, PRUnichar *aData, PRUint32                                      aDataLength, PRUint32 aFlags );
void        NS_StringContainerFinish(nsStringContainer *aContainer);
PRUint32    NS_StringGetData(nsAString *aStr, PRUnichar **aData, PRBool *aTerminated);
PRUint32    NS_StringGetMutableData(nsAString *aStr, PRUint32 aDataLength, PRUnichar **aData);
PRUnichar * NS_StringCloneData(nsAString *aStr);
nsresult    NS_StringSetData(nsAString *aStr, PRUnichar *aData, PRUint32 aDataLength);
nsresult    NS_StringSetDataRange( nsAString *aStr, PRUint32 aCutOffset, PRUint32 aCutLength,                                     PRUnichar *aData, PRUint32 aDataLength );
nsresult    NS_StringCopy(nsAString *aDestStr, nsAString *aSrcStr);

/******************************************************************************

******************************************************************************/

enum
{
    NS_CSTRING_CONTAINER_INIT_DEPEND = 2,
    NS_CSTRING_CONTAINER_INIT_ADOPT = 4,
    NS_CSTRING_CONTAINER_INIT_SUBSTRING = 8,
}

nsresult    NS_CStringContainerInit( nsCStringContainer *aContainer );
nsresult    NS_CStringContainerInit2( nsCStringContainer *aContainer, char *aData, PRUint32                                          aDataLength, PRUint32 aFlags );
void        NS_CStringContainerFinish( nsCStringContainer *aContainer );
PRUint32    NS_CStringGetData( nsACString *aStr, char **aData, PRBool *aTerminated );
PRUint32    NS_CStringGetMutableData( nsACString *aStr, PRUint32 aDataLength, char **aData );
char *      NS_CStringCloneData( nsACString *aStr);
nsresult    NS_CStringSetData( nsACString *aStr, char *aData, PRUint32 aDataLength );
nsresult    NS_CStringSetDataRange( nsACString *aStr, PRUint32 aCutOffset, 
                                    PRUint32 aCutLength, char *aData, PRUint32 aDataLength );
nsresult    NS_CStringCopy( nsACString *aDestStr, nsACString *aSrcStr );

/******************************************************************************

******************************************************************************/

enum nsCStringEncoding
{
    NS_CSTRING_ENCODING_ASCII,
    NS_CSTRING_ENCODING_UTF8,
    NS_CSTRING_ENCODING_NATIVE_FILESYSTEM,
}

nsresult    NS_CStringToUTF16( nsACString *aSource, int aSrcEncoding, nsAString *aDest );
nsresult    NS_UTF16ToCString( nsAString *aSource, int aDestEncoding, nsACString *aDest );

/******************************************************************************

******************************************************************************/

alias nsAString nsAString_external;
alias nsACString nsACString_external;

//alias nsAString nsEmbedString;
//alias nsACString nsEmbedCString;

struct nsAString
{

    static nsAString opCall(wchar[] s)
    {
        nsAString result;
        NS_StringSetData(&result, cast(PRUnichar*)s, uint.max);
        return result;
    }

    static String16 toString16( nsAString* str )
    {
        wchar* buffer = null;
		PRBool terminated;
		uint len = NS_StringGetData(str, &buffer, &terminated);
		return buffer[0 .. len]._idup();
    }
    
    static String toString( nsAString* str )
    {
        return String_valueOf( nsAString.toString16( str ) );
    }

  private:
    void *v;
}

struct nsACString
{
/+
  static nsACString opCall(char[] s)
  {
    nsACString result;
    NS_CStringSetData(&result, cast(char*)s, uint.max);
    return result;
  }
+/
  private:
    void *v;
}

/******************************************************************************

******************************************************************************/

struct nsStringContainer// : public nsAString
{
private:
	void* v;
	void* d1;
	uint  d2;
	void* d3;
}

struct nsCStringContainer// : public nsACString
{
private:
	void* v;
	void* d1;
	uint  d2;
	void* d3;
}

/******************************************************************************

******************************************************************************/

// import mozilla.xpcom.nsDebug;

alias nsString_external     nsString;
alias nsCString_external    nsCString;
alias nsDependentString_external nsDependentString;
alias nsDependentCString_external nsDependentCString;
alias NS_ConvertASCIItoUTF16_external NS_ConvertASCIItoUTF16;
alias NS_ConvertUTF8toUTF16_external NS_ConvertUTF8toUTF16;
alias NS_ConvertUTF16toUTF8_external NS_ConvertUTF16toUTF8;
alias NS_LossyConvertUTF16toASCII_external NS_LossyConvertUTF16toASCII;
alias nsGetterCopies_external nsGetterCopies;
alias nsCGetterCopies_external nsCGetterCopies;
alias nsDependentSubstring_external nsDependentSubstring;
alias nsDependentCSubstring_external nsDependentCSubstring;

struct nsString_external{}
struct nsCString_external{}
struct nsDependentString_external{}
struct nsDependentCString_external{}
struct NS_ConvertASCIItoUTF16_external{}
struct NS_ConvertUTF8toUTF16_external{}
struct NS_ConvertUTF16toUTF8_external{}
struct NS_LossyConvertUTF16toASCII_external{}

/******************************************************************************

******************************************************************************/

struct nsGetterCopies_external
{
  private:
	alias PRUnichar char_type;
    nsString_external *mString;
    char_type *mData;
}

struct nsCGetterCopies_external
{
  private:
	alias char char_type;
    nsCString_external *mString;
    char_type *mData;
}

/******************************************************************************

******************************************************************************/

struct nsDependentSubstring_external{}
struct nsDependentCSubstring_external{}
