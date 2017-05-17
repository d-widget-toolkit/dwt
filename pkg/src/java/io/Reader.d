module java.io.Reader;

import java.lang.util;

class Reader{
    protected Object   lock;
    protected this(){
        implMissing(__FILE__,__LINE__);
    }
    protected this(Object lock){
        implMissing(__FILE__,__LINE__);
    }
    abstract  void  close();
    void mark(int readAheadLimit){
        implMissing(__FILE__,__LINE__);
    }
    bool markSupported(){
        implMissing(__FILE__,__LINE__);
        return false;
    }
    int read(){
        implMissing(__FILE__,__LINE__);
        return 0;
    }
    int read(char[] cbuf){
        implMissing(__FILE__,__LINE__);
        return 0;
    }
    abstract int read(char[] cbuf, int off, int len);
    bool ready(){
        implMissing(__FILE__,__LINE__);
        return false;
    }
    void reset(){
        implMissing(__FILE__,__LINE__);
    }
    long skip(long n){
        implMissing(__FILE__,__LINE__);
        return 0;
    }
}
