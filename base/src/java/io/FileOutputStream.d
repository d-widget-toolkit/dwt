/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module java.io.FileOutputStream;

public import java.io.File;
public import java.io.OutputStream;

import java.lang.all;

static import std.stdio;

public class FileOutputStream : java.io.OutputStream.OutputStream {

    alias java.io.OutputStream.OutputStream.write write;
    alias java.io.OutputStream.OutputStream.close close;
    private std.stdio.File fc;

    public this ( String name ){
        fc = std.stdio.File( name, "wb" );
    }

    public this ( String name, bool append ){
        fc = std.stdio.File( name, append ? "ab" : "wb" );
    }

    public this ( java.io.File.File file ){
        this( file.toString );
    }

    public this ( java.io.File.File file, bool append ){
        this( file.toString, append );
    }

    public override void write( int b ){
        ubyte[1] a = b & 0xFF;
        fc.rawWrite(a);
    }

    public override void close(){
        fc.close();
    }

    public void finalize(){
        implMissing( __FILE__, __LINE__ );
    }


}


