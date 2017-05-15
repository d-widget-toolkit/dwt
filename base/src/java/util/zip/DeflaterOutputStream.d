/**
 * Authors: kntroh <knt.roh@gmail.com>
 */
module java.util.zip.DeflaterOutputStream;

version (Tango) {
    version (Windows) {
        pragma (lib, "zlib.lib");
    } else {
        pragma (lib, "zlib");
    }

    import tango.io.stream.Zlib;
    import tango.io.model.IConduit;

    class OutputStreamWrapper : tango.io.model.IConduit.OutputStream {

        java.io.OutputStream.OutputStream _ostr;

        this (java.io.OutputStream.OutputStream ostr) {
            _ostr = ostr;
        }

        override
        size_t write (void[] src) {
            _ostr.write(cast(byte[]) src);
            return src.length;
        }
        override
        IOStream flush() {
            _ostr.flush();
            return this;
        }
        override
        void close() {
            _ostr.close();
        }

        override
        long seek(long offset, Anchor anchor = Anchor.Begin) {
            implMissing(__FILE__,__LINE__);
            return 0;
        }
        override
        IConduit conduit() {
            implMissing(__FILE__,__LINE__);
            return null;
        }
        override
        OutputStream copy(tango.io.model.IConduit.InputStream src, size_t max = -1) {
            implMissing(__FILE__,__LINE__);
            return null;
        }
        override
        OutputStream output() {
            implMissing(__FILE__,__LINE__);
            return null;
        }
    }
} else { // Phobos
    import std.zlib;
}

import java.lang.all;

class DeflaterOutputStream : java.io.OutputStream.OutputStream {

    version (Tango) {
        private ZlibOutput _ostr;
    } else { // Phobos
        private java.io.OutputStream.OutputStream _ostr;
        private Compress _compress;
    }

    protected byte[] buf;

    this (java.io.OutputStream.OutputStream ostr) {
        version (Tango) {
            _ostr = new ZlibOutput(new OutputStreamWrapper(ostr));
        } else { // Phobos
            _ostr = ostr;
            _compress = new Compress();
        }
    }

    protected void deflate() {
        version (Tango) {
            _ostr.write(buf);
        } else { // Phobos
            auto bytes = _compress.compress(buf);
            if (0 < bytes.length) {
                _ostr.write(cast(byte[]) bytes);
            }
        }
        buf.length = 0;
    }

    void finish() {
        version (Tango) {
            _ostr.commit();
        } else { // Phobos
            auto bytes = _compress.flush(Z_FINISH);
            if (0 < bytes.length) {
                _ostr.write(cast(byte[]) bytes);
                _ostr.flush();
            }
        }
    }

    override
    public void write(int b) {
        byte[1] bytes;
        bytes[0] = cast(byte) (b & 0xFF);
        write(bytes, 0, bytes.length);
    }

    override
    public void write(in byte[] b) {
        write(b, 0, cast(int)b.length);
    }

    override
    void write(in byte[] b, ptrdiff_t off, ptrdiff_t len) {
        buf ~= b[off .. off + len];
        deflate();
    }

    override
    void flush() {
        deflate();
        _ostr.flush();
    }

    override
    void close() {
        finish();
        _ostr.close();
    }
}
