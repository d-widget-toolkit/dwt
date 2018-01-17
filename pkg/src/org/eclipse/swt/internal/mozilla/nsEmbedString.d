module org.eclipse.swt.internal.mozilla.nsEmbedString;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsStringAPI;
import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

scope class nsEmbedString
{
    this(wchar[] s)
    {
        nsresult result;
        result = NS_StringContainerInit2(&str, s.ptr, s.length, 0);
        if (XPCOM.NS_FAILED(result)) 
            throw new Exception("Init string container fail");
    }

    this()
    {
        nsresult result;
        result = NS_StringContainerInit(&str);
        if (XPCOM.NS_FAILED(result)) 
            throw new Exception("Init string container fail");
    }

    nsAString* opCast()
    {
        return cast(nsAString*)&str;
    }

    wchar[] toString16()
    {
        wchar* buffer = null;
        PRBool terminated;
        uint len = NS_StringGetData(cast(nsAString*)&str, &buffer, &terminated);
        return buffer[0 .. len].dup;
    }
    
    override String toString()
    {
        return String_valueOf(this.toString16());
    }
    ~this()
    {
        NS_StringContainerFinish(&str);
    }
private:
    nsStringContainer str;
}


scope class nsEmbedCString
{
    this(char[] s)
    {
        nsresult result;
        result = NS_CStringContainerInit2(&str, s.ptr, s.length, 0);
        if (XPCOM.NS_FAILED(result)) 
            throw new Exception("Init string container fail");
    }

    this()
    {
        nsresult result;
        result = NS_CStringContainerInit(&str);
        if (XPCOM.NS_FAILED(result)) 
            throw new Exception("Init string container fail");
    }

    nsACString* opCast()
    {
        return cast(nsACString*)&str;
    }

    override String toString()
    {
        char* buffer = null;
        PRBool terminated;
        uint len = NS_CStringGetData(cast(nsACString*)&str, &buffer, &terminated);
        return buffer[0 .. len]._idup();
    }

    ~this()
    {
        NS_CStringContainerFinish(&str);
    }
private:
    nsCStringContainer str;
}

