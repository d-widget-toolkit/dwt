module java.lang.ThreadLocal;
import java.lang.util;

version(Tango){
    static import tango.core.Thread;

    class ThreadLocal{
        alias tango.core.Thread.ThreadLocal!(Object) TLSType;
        TLSType tls;
        this(){
            tls = new TLSType( initialValue() );
        }
        Object get(){
            return tls.val();
        }
        protected  Object initialValue(){
            return null;
        }
        void set(Object value){
            return tls.val( value );
        }
    }
} else { // Phobos
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
}
