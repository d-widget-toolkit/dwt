/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */

module java.io.InputStream;

import java.lang.all;

public abstract class InputStream {


    public this (){
    }

    public abstract int read();

    public int read( byte[] b ){
        foreach( uint idx, ref byte val; b ){
            int c = read();
            if( c == -1 ){
                return ( idx == 0 ) ? -1 : idx;
            }
            b[ idx] = cast(byte)( c & 0xFF );
        }
        return cast(int)/*64bit*/b.length;
    }

    public ptrdiff_t read( byte[] b, ptrdiff_t off, ptrdiff_t len ){
        return read( b[ off .. off+len ] );
    }

    public long skip( long n ){
        implMissing( __FILE__, __LINE__ );
        return 0L;
    }

    public ptrdiff_t available(){
        return 0;
    }

    public void close(){
        implMissing( __FILE__, __LINE__ );
    }

    public synchronized void mark( int readlimit ){
        implMissing( __FILE__, __LINE__ );
    }

    public synchronized void reset(){
        implMissing( __FILE__, __LINE__ );
    }

    public bool markSupported(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }


}


