module java.lang.ThreadLocal;
import java.lang.util;

class ThreadLocal{
    Object tls;
    this(){
        tls = initialValue();
    }
    Object get(){
        return tls;
    }
    protected  Object initialValue(){
        return null;
    }
    void set(Object value){
        tls = value;
    }
}
