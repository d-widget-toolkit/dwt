module java.util.TreeMap;

import java.lang.all;
import java.util.Map;
import java.util.Set;
import java.util.Collection;
import java.util.SortedMap;
import java.util.TreeSet;
import java.util.ArrayList;
import java.util.Comparator;

version(Tango){
    static import tango.util.container.SortedMap;
} else { // Phobos
}


class TreeMap : Map, SortedMap {
    version(Tango){
        alias tango.util.container.SortedMap.SortedMap!(Object,Object) MapType;
        private MapType map;
    } else { // Phobos
    }


    public this(){
        version(Tango){
            map = new MapType();
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    public this(Comparator c){
        implMissing( __FILE__, __LINE__ );
    }
    public this(Map m){
        implMissing( __FILE__, __LINE__ );
    }
    public this(SortedMap m){
        implMissing( __FILE__, __LINE__ );
    }
    public void clear(){
        version(Tango){
            map.clear();
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    Comparator     comparator(){
        implMissing( __FILE__, __LINE__ );
        return null;
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
            TreeSet res = new TreeSet();
            foreach( k, v; map ){
                res.add( new MapEntry(this,k) );
            }
            return res;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public override equals_t opEquals(Object o){
        version(Tango){
            if( auto other = cast(TreeMap) o ){
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
    Object         firstKey(){
        version(Tango){
            foreach( k; map ){
                return k;
            }
            throw new tango.core.Exception.NoSuchElementException( "TreeMap.firstKey" );
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public Object get(Object key){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public Object get(String key){
        return get(stringcast(key));
    }
    public override hash_t toHash(){
        version(Tango){
            // http://java.sun.com/j2se/1.4.2/docs/api/java/util/AbstractMap.html#hashCode()
            hash_t res = 0;
            foreach( e; entrySet() ){
                res += e.toHash();
            }
            return res;
        } else { // Phobos
            implMissingSafe( __FILE__, __LINE__ );
            return false;
        }
    }
    SortedMap headMap(Object toKey){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public bool isEmpty(){
        version(Tango){
            return map.isEmpty();
        } else { // Phobos
            implMissingInPhobos();
            return false;
        }
    }
    public Set keySet(){
        version(Tango){
            TreeSet res = new TreeSet();
            foreach( k; map ){
                res.add( k );
            }
            return res;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    Object lastKey(){
        version(Tango){
            Object res;
            foreach( k; map ){
                res = k;
            }
            if( map.size() ) return res;
            throw new tango.core.Exception.NoSuchElementException( "TreeMap.lastKey" );
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public Object put(Object key, Object value){
        version(Tango){
            if( map.contains(key) ){ // TODO if tango has opIn_r, then use the "in" operator
                Object res = map[key];
                map[key] = value;
                return res;
            }
            map[key] = value;
            return null;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public Object put(String key, Object value){
        return put(stringcast(key), value);
    }
    public Object put(Object key, String value){
        return put(key, stringcast(value));
    }
    public Object put(String key, String value){
        return put(stringcast(key), stringcast(value));
    }
    public void   putAll(Map t){
        foreach( k, v; t ){
            put( k, v );
        }
    }
    public Object remove(Object key){
        version(Tango){
            Object res;
            map.take(key,res);
            return res;
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
    SortedMap      subMap(Object fromKey, Object toKey){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    SortedMap      tailMap(Object fromKey){
        implMissing( __FILE__, __LINE__ );
        return null;
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

