/** 
 * Stuff for working with narrow strings.
 * Safe because of strong type checking.
 * 
 * Authors: Denis Shelomovskij <verylonglogin.reg@gmail.com>
 */
module java.nonstandard.SafeUtf;

import java.nonstandard.UtfBase;

private const bool UTFTypeCheck = true;
mixin(UtfBaseText);

unittest {
    auto s = "abаб回家\U00064321\U00064321d"; assert(s.length == 1+1+2+2+3+3+4+4+1);
    auto ws = "abаб回家\U00064321\U00064321d"w; assert(ws.length == 1+1+1+1+1+1+2+2+1);
    auto dchars = "abаб回家\U00064321\U00064321d"d;
    auto  starts  = [1, 1, 1,0, 1,0, 1,0,0, 1,0,0, 1,0,0,0, 1,0,0,0, 1];
    auto wstarts  = [1, 1, 1,   1,   1,     1,     1,0,     1,0    , 1];
    assert(s.length == starts.length);
    assert(ws.length == wstarts.length);
    
    auto  strides = [1, 1, 2, 2, 3, 3, 4, 4, 1];
    auto wstrides = [1, 1, 1, 1, 1, 1, 2, 2, 1];
    auto shifts0 = [0, 1, 1+1, 1+1+2, 1+1+2+2, 1+1+2+2+3, 1+1+2+2+3+3, 1+1+2+2+3+3+4, 1+1+2+2+3+3+4+4];
    assert(strides.length == dchars.length);
    assert(wstrides.length == dchars.length);
    assert(shifts0.length == dchars.length);
    
    UTF8index prevStart = 0;
    UCSindex n = 0;
    foreach(UTF8index i, char ch; s) {
        assert(s.isUTF8sequenceStart(i) == starts[i]);
        if(starts[i]) {
            s.validateUTF8index(i);
            assert(s.UTF8strideAt(i) == strides[n]);
            assert(s.toUTF8shift(0, n) == shifts0[n]);
            assert(s.toUTF8shift(shifts0[n], -n) == -shifts0[n]);
            if(i) assert(s.offsetBefore(i) == prevStart);
            assert(s[0 .. val(i)].UCScount == n);
            assert(s[val(i) .. $].UCScount == strides.length - n);
            
            UTF8shift di;
            assert(s.dcharAt(i, di) == dchars[n]);
            assert(di == strides[n]);
            if(i) assert(s.dcharBefore(i) == s.dcharAt(prevStart));
            if(i) assert(s.dcharAfter(prevStart) == s.dcharAt(i));
            auto dcharStr = s[val(i) .. val(i) + strides[n]];
            assert(s.dcharAsStringAt(i, di) == dcharStr && di == dcharStr.length);
            assert(dcharToString(s.dcharAt(i)) == dcharStr);
            prevStart = i;
            ++n;
        }
        UTF8index t = i;
        s.adjustUTF8index(t);
        assert(t == prevStart);
    }
    
    n = 0;
    foreach(UTF16index i, wchar ch; ws)
        if(wstarts[i]) {
            //s.validateUTF16index(i);
            UTF16shift di;
            assert(ws.dcharAt(i, di) == dchars[n]);
            assert(di == wstrides[n]);
            ++n;
        }
    
    s.validateUTF8index(s.length);
}