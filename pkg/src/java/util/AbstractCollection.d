module java.util.AbstractCollection;

import java.lang.all;
import java.util.Collection;
import java.util.Iterator;

abstract class AbstractCollection : Collection {
    this(){
    }
    bool        add(Object o){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    bool        addAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    void   clear(){
        implMissing( __FILE__, __LINE__ );
    }
    bool        contains(Object o){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    bool        containsAll(Collection c){
        if( c is null ) throw new NullPointerException();
        foreach( o; c ){
            if( !contains(o) ) return false;
        }
        return true;
    }
    override equals_t opEquals(Object o){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    bool        isEmpty(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    abstract  Iterator      iterator();
    override hash_t toHash(){
        implMissingSafe( __FILE__, __LINE__ );
        return 0;
    }
    bool        remove(Object o){
        throw new UnsupportedOperationException();
    }
    bool        remove(String o){
        return remove(stringcast(o));
    }
    bool        removeAll(Collection c){
        if( c is null ) throw new NullPointerException();
        bool res = false;
        foreach( o; c ){
            res |= remove(o);
        }
        return res;
    }
    bool        retainAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    abstract  int   size();
    Object[]       toArray(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    Object[]       toArray(Object[] a){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    String[]       toArray(String[] a){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    String         toString(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
}

