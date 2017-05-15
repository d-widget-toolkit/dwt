module java.util.Hashtable;

import java.lang.all;
import java.util.Dictionary;
import java.util.Map;
import java.util.Enumeration;
import java.util.Collection;
import java.util.Set;

// no nulls
// synchronized
class Hashtable : Dictionary, Map {

    override
    public Object get(String key){
        return super.get(key);
    }
    override
    public Object put(String key, Object value){
        return super.put(key, value);
    }
    override
    public Object put(Object key, String value){
        return super.put(key, value);
    }
    override
    public Object put(String key, String value){
        return super.put(key, value);
    }
    override
    public Object remove(String key){
        return super.remove(key);
    }

    Object[Object] map;

    // The HashMap  class is roughly equivalent to Hashtable, except that it is unsynchronized and permits nulls.
    public this(){
    }
    public this(int initialCapacity){
        implMissing( __FILE__, __LINE__ );
    }
    public this(int initialCapacity, float loadFactor){
        implMissing( __FILE__, __LINE__ );
    }
    public this(Map t){
        implMissing( __FILE__, __LINE__ );
    }

    class ObjectEnumeration : Enumeration {
        Object[] values;
        int index = 0;
        this( Object[] values ){
            this.values = values;
        }
        public bool hasMoreElements(){
            return index < values.length;
        }
        public Object nextElement(){
            Object res = values[index];
            index++;
            return res;
        }
    }

    override
    Enumeration  elements(){
        return new ObjectEnumeration( map.values );
    }
    override
    Enumeration        keys() {
        return new ObjectEnumeration( map.keys );
    }
    public void clear(){
        synchronized map = null;
    }
    public bool containsKey(Object key){
        synchronized {
            if( auto v = key in map ){
                return true;
            }
            return false;
        }
    }
    public bool containsKey(String key){
        synchronized return containsKey(stringcast(key));
    }
    public bool containsValue(Object value){
        synchronized {
             foreach( k, v; map ){
                 if( v == value ){
                     return true;
                 }
             }
             return false;
        }
    }
    public Set  entrySet(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public equals_t opEquals(Object o){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    override
    public Object get(Object key){
        synchronized {
            if( auto v = key in map ){
                return *v;
            }
            return null;
        }
    }
    override
    public hash_t toHash(){
        implMissingSafe( __FILE__, __LINE__ );
        return 0;
    }
    override
    public bool isEmpty(){
        synchronized return map.length is 0;
    }
    public Set    keySet(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public Object put(Object key, Object value){
        synchronized {
            Object res = null;
            if( auto v = key in map ){
                res = *v;
            }
            map[ key ] = value;
            return res;
        }
    }
//     public Object put(String key, Object value)
//     public Object put(Object key, String value)
//     public Object put(String key, String value)
    public void   putAll(Map t){
        synchronized
        implMissing( __FILE__, __LINE__ );
    }
    override
    public Object remove(Object key){
        synchronized
        implMissing( __FILE__, __LINE__ );
        return null;
    }
//     public Object remove(String key)
    override
    public int    size(){
        synchronized return cast(int)/*64bit*/map.length;
    }
    public Collection values(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    // only for D
    public int opApply (int delegate(ref Object value) dg){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    public int opApply (int delegate(ref Object key, ref Object value) dg){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

}

