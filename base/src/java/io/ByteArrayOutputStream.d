/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module java.io.ByteArrayOutputStream;

public import java.io.OutputStream;
import java.lang.all;

version(Tango){
    import tango.io.device.Array;
} else { // Phobos
    import std.outbuffer;
}

public class ByteArrayOutputStream : java.io.OutputStream.OutputStream {

    version(Tango){
        protected Array buffer;
    } else { // Phobos
        protected OutBuffer buffer;
    }

    public this (){
        version(Tango){
            buffer = new Array(0, 1);
        } else { // Phobos
            buffer = new OutBuffer();
        }
    }

    public this ( int par_size ){
        version(Tango){
            buffer = new Array(par_size, 1);
        } else { // Phobos
            buffer = new OutBuffer();
            buffer.reserve(par_size);
        }
    }

    public override void write( int b ){
        synchronized {
            version(Tango){
                byte[1] a = b & 0xFF;
                buffer.append(a);
            } else { // Phobos
                buffer.write(cast(ubyte)(b & 0xFF));
            }
        }
    }

    public override void write( in byte[] b, ptrdiff_t off, ptrdiff_t len ){
        synchronized {
            version(Tango){
                buffer.append( b[ off .. off + len ] );
            } else { // Phobos
                buffer.write( cast(ubyte[]) b[ off .. off + len ]);
            }
        }
    }

    public override void write( in byte[] b ){
        synchronized {
            version(Tango){
                buffer.append( b );
            } else { // Phobos
                buffer.write( cast(ubyte[]) b );
            }
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
            version(Tango){
                return cast(byte[]) buffer.slice();
            } else { // Phobos
                return cast(byte[]) buffer.toBytes();
            }
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


