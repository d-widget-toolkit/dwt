module java.io.PushbackReader;

import java.lang.all;
import java.io.Reader;

class PushbackReader : Reader {

    this( Reader reader ){
        implMissing(__FILE__,__LINE__);
    }
    void unread( char c ){
        implMissing(__FILE__,__LINE__);
    }
    override
    int read(char[] cbuf, int off, int len){
        implMissing(__FILE__,__LINE__);
        return 0;
    }
    override
    void  close(){
        implMissing(__FILE__,__LINE__);
    }

}

