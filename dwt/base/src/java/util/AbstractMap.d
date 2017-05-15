module java.util.AbstractMap;

import java.lang.all;
import java.util.Map;
import java.util.Collection;
import java.util.Set;

abstract class AbstractMap : Map {
    public this(){
        implMissing( __FILE__, __LINE__ );
    }
    void   clear(){
        implMissing( __FILE__, __LINE__ );
    }
    protected  Object       clone(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    bool        containsKey(String key){
        return containsKey(stringcast(key));
    }
    bool        containsKey(Object key){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    bool        containsValue(Object value){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    abstract  Set   entrySet();

    public override equals_t       opEquals(Object o){
        if( Map other = cast(Map)o){
            return cast(equals_t)entrySet().opEquals( cast(Object) other.entrySet() );
        }
        return false;
    }

    Object         get(String key){
        return get(stringcast(key));
    }
    Object         get(Object key){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public override hash_t    toHash(){
        implMissingSafe( __FILE__, __LINE__ );
        return 0;
    }
    bool        isEmpty(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    Set    keySet(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    Object         put(String key, String value){
        return put(stringcast(key),stringcast(value));
    }
    Object         put(Object key, String value){
        return put(key,stringcast(value));
    }
    Object         put(String key, Object value){
        return put(stringcast(key),value);
    }
    Object         put(Object key, Object value){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    void   putAll(Map t){
        implMissing( __FILE__, __LINE__ );
    }
    Object         remove(String key){
        return remove(stringcast(key));
    }
    Object         remove(Object key){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    int    size(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    override
    String         toString(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    Collection     values(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public int opApply (int delegate(ref Object value) dg){
        foreach( entry; entrySet() ){
            auto me = cast(Map.Entry)entry;
            auto v = me.getValue();
            int res = dg( v );
            if( res ) return res;
        }
        return 0;
    }
    public int opApply (int delegate(ref Object key, ref Object value) dg){
        foreach( entry; entrySet() ){
            auto me = cast(Map.Entry)entry;
            auto k = me.getKey();
            auto v = me.getValue();
            int res = dg( k, v );
            if( res ) return res;
        }
        return 0;
    } 
 }

