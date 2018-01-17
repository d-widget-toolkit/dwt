module org.eclipse.swt.internal.mozilla.nsID;

import org.eclipse.swt.internal.mozilla.Common;
import java.lang.all;
import java.text.ParseException;

align(1)
struct nsID
{
    PRUint32 m0;
    PRUint16 m1;
    PRUint16 m2;
    PRUint8[8] m3;

	static nsID opCall(String aIDStr)
	{
        nsID id;
        if(aIDStr == null) throw new ParseException();
        int i = 0;
        with(id) {
            for (; i < 8; i++) m0 = (m0 << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16);
            if (aIDStr.charAt (i) != '-') throw new ParseException ();
            i++;
            for (; i < 13; i++) m1 = cast(short)((m1 << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16));
            if (aIDStr.charAt (i) != '-') throw new ParseException ();
            i++;
            for (; i < 18; i++) m2 = cast(short)((m2 << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16));
            if (aIDStr.charAt (i) != '-') throw new ParseException ();
            i++;
            for (; i < 21; i++) m3[0] = cast(byte)((m3[0] << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16));
            for (; i < 23; i++) m3[1] = cast(byte)((m3[1] << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16));
            if (aIDStr.charAt (i) != '-') throw new ParseException ();
            i++;
            for (; i < 26; i++) m3[2] = cast(byte)((m3[2] << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16));
            for (; i < 28; i++) m3[3] = cast(byte)((m3[3] << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16));
            for (; i < 30; i++) m3[4] = cast(byte)((m3[4] << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16));
            for (; i < 32; i++) m3[5] = cast(byte)((m3[5] << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16));
            for (; i < 34; i++) m3[6] = cast(byte)((m3[6] << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16));
            for (; i < 36; i++) m3[7] = cast(byte)((m3[7] << 4) + Integer.parseInt (aIDStr.substring (i, i + 1), 16));
        }
        return id;
	}

}

alias nsID nsCID;
alias nsID nsIID;
