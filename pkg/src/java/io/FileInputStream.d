/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module java.io.FileInputStream;

import java.lang.all;
import java.io.File;
import java.io.InputStream;

version(Tango){
    import TangoFile = tango.io.device.File;
} else { // Phobos
    static import std.stdio;
}

public class FileInputStream : java.io.InputStream.InputStream {

    alias java.io.InputStream.InputStream.read read;

    version(Tango){
        private TangoFile.File conduit;
    } else { // Phobos
        private std.stdio.File conduit;
    }
    private ubyte[] buffer;
    private int buf_pos;
    private int buf_size;
    private enum int BUFFER_SIZE = 0x10000;
    private bool eof;

    public this ( String name ){
        version(Tango){
            conduit = new TangoFile.File( name );
        } else { // Phobos
            conduit = std.stdio.File( name, "rb" );
        }
        buffer = new ubyte[]( BUFFER_SIZE );
    }

    public this ( java.io.File.File file ){
        implMissing( __FILE__, __LINE__ );
        version(Tango){
            conduit = new TangoFile.File( file.getAbsolutePath(), TangoFile.File.ReadExisting );
        } else { // Phobos
            conduit = std.stdio.File( file.getAbsolutePath(), "rb" );
        }
        buffer = new ubyte[]( BUFFER_SIZE );
    }

    public override int read(){
        version(Tango){
            if( eof ){
                return -1;
            }
            try{
                if( buf_pos == buf_size ){
                    buf_pos = 0;
                    buf_size = conduit.input.read( buffer );
                }
                if( buf_size <= 0 ){
                    eof = true;
                    return -1;
                }
                assert( buf_pos < BUFFER_SIZE, Format( "{0} {1}", buf_pos, buf_size ) );
                assert( buf_size <= BUFFER_SIZE );
                int res = cast(int) buffer[ buf_pos ];
                buf_pos++;
                return res;
            }
            catch( IOException e ){
                eof = true;
                return -1;
            }
        } else { // Phobos
            if( eof ){
                return -1;
            }
            try{
                if( buf_pos == buf_size ){
                    buf_pos = 0;
                    buf_size = cast(int)/*64bit*/conduit.rawRead( buffer ).length;
                }
                if( buf_size <= 0 ){
                    eof = true;
                    return -1;
                }
                assert( buf_pos < BUFFER_SIZE, Format( "{} {}", buf_pos, buf_size ) );
                assert( buf_size <= BUFFER_SIZE );
                int res = cast(int) buffer[ buf_pos ];
                buf_pos++;
                return res;
            }
            catch( IOException e ){
                eof = true;
                return -1;
            }
        }
    }

    override
    public long skip( long n ){
        implMissing( __FILE__, __LINE__ );
        return 0L;
    }

    override
    public ptrdiff_t available(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    public override void close(){
        conduit.close();
    }
}


