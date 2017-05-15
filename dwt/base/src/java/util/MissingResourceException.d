module java.util.MissingResourceException;

import java.lang.all;

class MissingResourceException : Exception {
    String classname;
    String key;
    this( String msg, String classname, String key ){
        super(msg);
        this.classname = classname;
        this.key = key;
    }
}

