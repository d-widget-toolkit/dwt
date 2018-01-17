/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module java.util.zip.InflaterInputStream;

import java.lang.all;
import java.io.InputStream;
version(Tango){
    import tango.io.stream.Zlib;
    import tango.io.device.Conduit;
    version(Windows){
        pragma(lib,"zlib.lib");
    }
    else{
        pragma(lib,"zlib");
    }
} else { // Phobos
    import std.zlib;
}

version(Tango){
    class InputStreamWrapper : tango.io.model.IConduit.InputStream {

        java.io.InputStream.InputStream istr;

        this( java.io.InputStream.InputStream istr ){
            this.istr = istr;
        }

        ptrdiff_t read (void[] dst){
            int res = istr.read( cast(byte[])dst );
            return res;
        }

        tango.io.model.IConduit.IConduit conduit (){
            implMissing(__FILE__,__LINE__);
            return null;
        }

        void close (){
            istr.close();
        }
        tango.io.model.IConduit.InputStream input (){
            implMissing(__FILE__,__LINE__);
            return null;
        }
        long seek (long offset, Anchor anchor = Anchor.Begin){
            implMissing(__FILE__,__LINE__);
            return 0;
        }
        void[] load (ptrdiff_t max = -1){
            implMissing(__FILE__,__LINE__);
            return null;
        }
        IOStream flush (){
            implMissing(__FILE__,__LINE__);
            return null;
        }
    }
} else { // Phobos
}


public class InflaterInputStream : java.io.InputStream.InputStream {

    alias java.io.InputStream.InputStream.read read;
    alias java.io.InputStream.InputStream.skip skip;
    alias java.io.InputStream.InputStream.available available;
    alias java.io.InputStream.InputStream.close close;
    alias java.io.InputStream.InputStream.mark mark;
    alias java.io.InputStream.InputStream.reset reset;
    alias java.io.InputStream.InputStream.markSupported markSupported;

    protected byte[] buf;
    protected int len;
    package bool usesDefaultInflater = false;

    version(Tango){
        ZlibInput tangoIstr;
    } else { // Phobos
    }

    public this ( java.io.InputStream.InputStream istr ){
        version(Tango){
            tangoIstr = new ZlibInput( new InputStreamWrapper(istr ));
        } else { // Phobos
            implMissingInPhobos();
        }
    }

    override
    public int read(){
        version(Tango){
            ubyte[1] data;
            uint res = tangoIstr.read( data );
            if( res !is 1 ){
                return data[0] & 0xFF;
            }
            return -1;
        } else { // Phobos
            implMissingInPhobos();
            return -1;
        }
    }

    override
    public ptrdiff_t read( byte[] b, ptrdiff_t off, ptrdiff_t len ){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    override
    public ptrdiff_t available(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    override
    public long skip( long n ){
        implMissing( __FILE__, __LINE__ );
        return 0L;
    }

    override
    public void close(){
        implMissing( __FILE__, __LINE__ );
    }

    public void fill(){
        implMissing( __FILE__, __LINE__ );
    }

    override
    public bool markSupported(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    override
    public synchronized void mark( int readlimit ){
        implMissing( __FILE__, __LINE__ );
    }

    override
    public synchronized void reset(){
        implMissing( __FILE__, __LINE__ );
    }
}


