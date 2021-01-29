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
    foreach(size_t iter, char ch; s) {
        UTF8index idx = iter;
        assert(s.isUTF8sequenceStart(idx) == starts[iter]);
        if (starts[iter]) {
            s.validateUTF8index(idx);
            assert(s.UTF8strideAt(idx) == strides[n]);
            assert(s.toUTF8shift(UTF8index(0), n) == shifts0[n]);
            assert(s.toUTF8shift( UTF8index(shifts0[n]), -n) == -shifts0[n]);
            if (iter) assert(s.offsetBefore(idx) == prevStart);
            assert(s[0 .. val(idx)].UCScount == n);
            assert(s[val(idx) .. $].UCScount == strides.length - n);

            UTF8shift di;
            assert(s.dcharAt(idx, di) == dchars[n]);
            assert(di == strides[n]);
            if (iter) assert(s.dcharBefore(idx) == s.dcharAt(prevStart));
            if (iter) assert(s.dcharAfter(prevStart) == s.dcharAt(idx));
            auto dcharStr = s[val(idx) .. val(idx) + strides[n]];
            assert(s.dcharAsStringAt(idx, di) == dcharStr && di == dcharStr.length);
            assert(dcharToString(s.dcharAt(idx)) == dcharStr);
            prevStart = idx;
            ++n;
        }
        UTF8index t = idx;
        s.adjustUTF8index(t);
        assert(t == prevStart);
    }

    n = 0;
    foreach(UTF16index i, wchar ch; ws)
        if (wstarts[i]) {
            //s.validateUTF16index(i);
            UTF16shift di;
            assert(ws.dcharAt(i, di) == dchars[n]);
            assert(di == wstrides[n]);
            ++n;
        }

    s.validateUTF8index( UTF8index(cast(ptrdiff_t)s.length) );
}
