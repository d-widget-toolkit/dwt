/**
 * Authors: Frank Benoit <keinfarbton@googlemail.com>
 */
module java.io.File;

import java.lang.all;


static import std.file;
static import std.path;
static import std.string; //for toStringz
version(Posix) static import core.sys.posix.unistd; //for access

public class File {

    public static char separatorChar;
    public static String separator;
    public static char pathSeparatorChar;
    public static String pathSeparator;

    private String mFilePath;

    static this(){
        separator = std.path.dirSeparator;
        separatorChar = std.path.dirSeparator[0];
        pathSeparator = std.path.pathSeparator;
        pathSeparatorChar = std.path.pathSeparator[0];
    }

    private static String toStd( String path ){
        return path;
    }
    private static String join( String path, String file ){
        return std.path.buildPath( toStd(path), toStd(file) );
    }

    public this ( String pathname ){
        mFilePath = toStd( pathname );
    }

    public this ( String parent, String child ){
        mFilePath = join( parent, child );
    }

    public this ( java.io.File.File parent, String child ){
        mFilePath = std.path.buildPath( parent.mFilePath, toStd(child) );
    }

    public int getPrefixLength(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    public String getName(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public String getParent(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public java.io.File.File getParentFile(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public String getPath(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public bool isAbsolute(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public String getAbsolutePath(){
        return std.path.absolutePath(mFilePath);
    }

    public java.io.File.File getAbsoluteFile(){
        return new File( getAbsolutePath() );
    }

    public String getCanonicalPath(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public java.io.File.File getCanonicalFile(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public bool canRead(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool canWrite(){
        version(Windows) { //Windows's ACL isn't supported
            return !(std.file.getAttributes(mFilePath) & 1); //FILE_ATTRIBUTE_READONLY = 1
        } else version(Posix) {
            return core.sys.posix.unistd.access (std.string.toStringz(mFilePath), 2) is 0; //W_OK = 2
        } else
            static assert(0);
    }

    public bool exists(){
        return std.file.exists(mFilePath);
    }

    public bool isDirectory(){
        return std.file.isDir(mFilePath);
    }

    public bool isFile(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool isHidden(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public long lastModified(){
        implMissing( __FILE__, __LINE__ );
        return 0L;
    }

    public long length(){
        implMissing( __FILE__, __LINE__ );
        return 0L;
    }

    public bool createNewFile(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool delete_KEYWORDESCAPE(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public void deleteOnExit(){
        implMissing( __FILE__, __LINE__ );
    }

    public String[] list(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public java.io.File.File[] listFiles(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public bool mkdir(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool mkdirs(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool renameTo( java.io.File.File dest ){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool setLastModified( long time ){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public bool setReadOnly(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    public static java.io.File.File[] listRoots(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public static java.io.File.File createTempFile( String prefix, String suffix, java.io.File.File directory ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public static java.io.File.File createTempFile( String prefix, String suffix ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    public int compareTo( java.io.File.File pathname ){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    override
    public String toString(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }


}


