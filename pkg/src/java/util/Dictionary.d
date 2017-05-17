module java.util.Dictionary;

import java.lang.all;
import java.util.Enumeration;

class Dictionary {
    public this(){
    }
    abstract  Enumeration   elements();
    abstract  Object        get(Object key);
    Object        get(String key){
        return get(stringcast(key));
    }
    abstract  bool          isEmpty();
    abstract  Enumeration   keys();
    abstract  Object        put(Object key, Object value);
    public Object put(String key, Object value){
        return put(stringcast(key), value);
    }
    public Object put(Object key, String value){
        return put(key, stringcast(value));
    }
    public Object put(String key, String value){
        return put(stringcast(key), stringcast(value));
    }
    abstract  Object        remove(Object key);
    public Object remove(String key){
        return remove(stringcast(key));
    }
    abstract  int   size();
}

