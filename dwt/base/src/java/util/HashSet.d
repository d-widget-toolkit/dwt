module java.util.HashSet;

import java.lang.all;
import java.util.Set;
import java.util.Collection;
import java.util.Iterator;

version(Tango){
    static import tango.util.container.HashSet;
} else { // Phobos
}

class HashSet : Set {
    version(Tango){
        alias tango.util.container.HashSet.HashSet!(Object) SetType;
        private SetType set;
    } else { // Phobos
    }

    public this(){
        version(Tango){
            set = new SetType();
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    public this(Collection c){
        version(Tango){
            set = new SetType();
            addAll(c);
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    public this(int initialCapacity){
        version(Tango){
            set = new SetType();
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    public this(int initialCapacity, float loadFactor){
        version(Tango){
            set = new SetType(loadFactor);
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    public bool    add(Object o){
        version(Tango){
            return set.add(o);
        } else { // Phobos
            implMissingInPhobos();
            return false;
        }
    }
    public bool    add(String o){
        return add(stringcast(o));
    }
    public bool    addAll(Collection c){
        bool res = false;
        foreach( o; c ){
            res |= add(o);
        }
        return res;
    }
    public void   clear(){
        version(Tango){
            set.clear();
        } else { // Phobos
            implMissingInPhobos();
        }
    }
    public bool    contains(Object o){
        version(Tango){
            return set.contains(o);
        } else { // Phobos
            implMissingInPhobos();
            return false;
        }
    }
    public bool     contains(String o){
        return contains(stringcast(o));
    }
    public bool    containsAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    public override equals_t    opEquals(Object o){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    public override hash_t    toHash(){
        implMissingSafe( __FILE__, __LINE__ );
        return 0;
    }
    public bool    isEmpty(){
        version(Tango){
            return set.isEmpty();
        } else { // Phobos
            implMissingInPhobos();
            return false;
        }
    }
    version(Tango){
        class LocalIterator : Iterator {
            SetType.Iterator iter;
            Object nextElem;
            this( SetType.Iterator iter){
                this.iter = iter;
            }
            public bool hasNext(){
                return iter.next(nextElem);
            }
            public Object next(){
                return nextElem;
            }
            public void  remove(){
                iter.remove();
            }
        }
    } else { // Phobos
    }
    public Iterator   iterator(){
        version(Tango){
            return new LocalIterator(set.iterator());
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public bool    remove(Object o){
        version(Tango){
            return set.remove(o);
        } else { // Phobos
            implMissingInPhobos();
            return false;
        }
    }
    public bool remove(String key){
        return remove(stringcast(key));
    }
    public bool    removeAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    public bool    retainAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    public int    size(){
        version(Tango){
            return set.size();
        } else { // Phobos
            implMissingInPhobos();
            return 0;
        }
    }
    public Object[]   toArray(){
        version(Tango){
            Object[] res;
            res.length = size();
            int idx = 0;
            foreach( o; set ){
                res[idx] = o;
                idx++;
            }
            return res;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }
    public Object[]   toArray(Object[] a){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public override String toString(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    // only for D
    public int opApply (int delegate(ref Object value) dg){
        version(Tango){
            return set.opApply(dg);
        } else { // Phobos
            implMissingInPhobos();
            return 0;
        }
    }

}

