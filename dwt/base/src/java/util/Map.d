module java.util.Map;

import java.lang.all;
import java.util.Set;
import java.util.Collection;

interface Map {
    interface Entry {
        equals_t   opEquals(Object o);
        Object     getKey();
        Object     getValue();
        version(Tango){
            public hash_t   toHash();
        } else { // Phobos
            mixin(`@safe nothrow public hash_t   toHash();`);
        }
        Object     setValue(Object value);
    }
    public void clear();
    public bool containsKey(Object key);
    public bool containsKey(String key);
    public bool containsValue(Object value);
    public Set  entrySet();
    public equals_t opEquals(Object o);
    public Object get(Object key);
    public Object get(String key);
    version(Tango){
        public hash_t   toHash();
    } else { // Phobos
        mixin(`@safe nothrow public hash_t   toHash();`);
    }
    public bool isEmpty();
    public Set    keySet();
    public Object put(Object key, Object value);
    public Object put(String key, Object value);
    public Object put(Object key, String value);
    public Object put(String key, String value);
    public void   putAll(Map t);
    public Object remove(Object key);
    public Object remove(String key);
    public int    size();
    public Collection values();

    // only for D
    public int opApply (int delegate(ref Object value) dg);
    public int opApply (int delegate(ref Object key, ref Object value) dg);
}
class MapEntry : Map.Entry {
    Map map;
    Object key;
    this( Map map, Object key){
        this.map = map;
        this.key = key;
    }
    public override equals_t opEquals(Object o){
        if( auto other = cast(MapEntry)o){

            if(( getKey() is null ? other.getKey() is null : getKey() == other.getKey() )  &&
               ( getValue() is null ? other.getValue() is null : getValue() == other.getValue() )){
                return true;
            }
            return false;
        }
        return false;
    }
    public Object getKey(){
        return key;
    }
    public Object getValue(){
        return map.get(key);
    }
    public override hash_t toHash(){
        return ( key   is null ? 0 : key.toHash()   ) ^
               ( 0 );
    }
    public Object     setValue(Object value){
        return map.put( key, value );
    }

}

