/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module java.io.ByteArrayOutputStream;

public import java.io.OutputStream;
import java.lang.all;

import std.outbuffer;

public class ByteArrayOutputStream : java.io.OutputStream.OutputStream {
    protected OutBuffer buffer;

    public this (){
        buffer = new OutBuffer();
    }

    public this ( int par_size ){
        buffer = new OutBuffer();
        buffer.reserve(par_size);
    }

    public override void write( int b ){
        synchronized {
            buffer.write(cast(ubyte)(b & 0xFF));
        }
    }

    public override void write( in byte[] b, ptrdiff_t off, ptrdiff_t len ){
        synchronized {
            buffer.write( cast(ubyte[]) b[ off .. off + len ]);
        }
    }

    public override void write( in byte[] b ){
        synchronized {
            buffer.write( cast(ubyte[]) b );
        }
    }

    public void writeTo( java.io.OutputStream.OutputStream out_KEYWORDESCAPE ){
        synchronized
        implMissing( __FILE__, __LINE__ );
    }

    public void reset(){
        synchronized
        implMissing( __FILE__, __LINE__ );
    }

    public byte[] toByteArray(){
        synchronized {
            return cast(byte[]) buffer.toBytes();
        }
    }

    public int size(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    public override String toString(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public String toString( String enc ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public String toString( int hibyte ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public override void close(){
        // Nothing.
    }
}


