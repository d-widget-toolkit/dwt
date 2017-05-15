module java.util.IdentityHashMap;

import java.lang.all;
import java.util.Map;
import java.util.HashSet;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Set;

version(Tango){
    static import tango.util.container.HashMap;
} else { // Phobos
}

class IdentityHashMap : Map {
    version(Tango){
        alias tango.util.container.HashMap.HashMap!(Object,Object) MapType;
        private MapType map;
    } else { // Phobos
    }

    public this(){
        implMissing(__FILE__, __LINE__ );
        version(Tango){
            map = new MapType();
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    public this(int initialCapacity){
        implMissing(__FILE__, __LINE__ );
        this();
    }
    public this(int initialCapacity, float loadFactor){
        implMissing(__FILE__, __LINE__ );
        version(Tango){
            map = new MapType(loadFactor);
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    public this(Map m){
        implMissing(__FILE__, __LINE__ );
        this();
        putAll(m);
    }
    public void clear(){
        version(Tango){
            map.clear();
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    public bool containsKey(Object key){
        version(Tango){
            Object v;
            return map.get(key, v );
        } else { // Phobos
            implMissingInPhobos();
            return false;
        }
    }
    public bool containsKey(String key){
        return containsKey(stringcast(key));
    }
    public bool containsValue(Object value){
        version(Tango){
            return map.contains(value);
        } else { // Phobos
            implMissingInPhobos();
            return false;
        }
    }
    public Set  entrySet(){
        version(Tango){
            HashSet res = new HashSet();
            foreach( k, v; map ){
                res.add( new MapEntry(this,k));
            }
            return res;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public override equals_t opEquals(Object o){
        version(Tango){
            if( auto other = cast(HashMap) o ){
                if( other.size() !is size() ){
                    return false;
                }
                foreach( k, v; map ){
                    Object vo = other.get(k);
                    if( v != vo ){
                        return false;
                    }
                }
                return true;
            }
            return false;
        } else { // Phobos
            implMissingInPhobos();
            return false;
        }
    }
    public Object get(Object key){
        version(Tango){
            if( auto v = key in map ){
                return *v;
            }
            return null;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public Object get(String key){
        return get(stringcast(key));
    }
    public override hash_t toHash(){
        return super.toHash();
    }
    public bool isEmpty(){
        version(Tango){
            return map.isEmpty();
        } else { // Phobos
            implMissingInPhobos();
            return false;
        }
    }
    public Set    keySet(){
        version(Tango){
            HashSet res = new HashSet();
            foreach( k, v; map ){
                res.add(k);
            }
            return res;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public Object put(Object key, Object value){
        version(Tango){
            Object res = null;
            if( auto vold = key in map ){
                res = *vold;
            }
            map[ key ] = value;
            return res;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public Object put(String key, Object value){
        return put( stringcast(key), value );
    }
    public Object put(Object key, String value){
        return put( key, stringcast(value) );
    }
    public Object put(String key, String value){
        return put( stringcast(key), stringcast(value) );
    }
    public void   putAll(Map t){
        version(Tango){
            foreach( k, v; t ){
                map[k] = v;
            }
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    public Object remove(Object key){
        version(Tango){
            if( auto v = key in map ){
                Object res = *v;
                map.remove(key);
                return res;
            }
            map.remove(key);
            return null;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public Object remove(String key){
        return remove(stringcast(key));
    }
    public int    size(){
        version(Tango){
            return map.size();
        } else { // Phobos
            implMissingInPhobos();
            return 0;
        }
    }
    public Collection values(){
        version(Tango){
            ArrayList res = new ArrayList( size() );
            foreach( k, v; map ){
                res.add( v );
            }
            return res;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }

    public int opApply (int delegate(ref Object value) dg){
        version(Tango){
            return map.opApply( dg );
        } else { // Phobos
            implMissingInPhobos();
            return 0;
        }
    }
    public int opApply (int delegate(ref Object key, ref Object value) dg){
        version(Tango){
            return map.opApply( dg );
        } else { // Phobos
            implMissingInPhobos();
            return 0;
        }
    }
}

