/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module java.io.OutputStream;

import java.lang.all;

public abstract class OutputStream {

    public this(){
    }

    public abstract void write( int b );

    public void write( in byte[] b ){
        foreach( bv; b ){
            write(bv);
        }
    }

    public void write( in byte[] b, ptrdiff_t off, ptrdiff_t len ){
        write(b[off .. off+len]);
    }

    public void flush(){
    }

    public void close(){
    }
}


