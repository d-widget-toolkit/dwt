module java.util.AbstractList;

import java.lang.all;
import java.util.Collection;
import java.util.AbstractCollection;
import java.util.List;
import java.util.ListIterator;
import java.util.Iterator;

abstract class AbstractList : AbstractCollection, List {
    this(){
    }

    public void add(int index, Object element){
        throw new UnsupportedOperationException();
    }
    public bool add(String o){
        return add(stringcast(o));
    }
    override
    public bool add(Object o){
        add(size(), o);
        return true;
    }
    override
    public bool addAll(Collection c){
        throw new UnsupportedOperationException();
    }
    public bool addAll(int index, Collection c){
        throw new UnsupportedOperationException();
    }
    override
    public void clear(){
        throw new UnsupportedOperationException();
    }
    override
    public bool contains(Object o){ return super.contains(o); }
    public bool contains(String str){ return contains(stringcast(str)); }
    override
    public bool     containsAll(Collection c){ return super.containsAll(c); }
    override
    public abstract equals_t opEquals(Object o);

    public abstract Object get(int index);

    override
    public abstract hash_t  toHash();

    public int    indexOf(Object o){
        auto it = listIterator();
        int idx = 0;
        while(it.hasNext()){
            auto t = it.next();
            if( t is null ? o is null : t == o){
                return idx;
            }
            idx++;
        }
        return -1;
    }
    override
    public bool     isEmpty(){
        return super.isEmpty();
    }
    override
    public Iterator iterator(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public int    lastIndexOf(Object o){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    public ListIterator   listIterator(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public ListIterator   listIterator(int index){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public Object         remove(int index){
        throw new UnsupportedOperationException();
    }
    protected void         removeRange(int fromIndex, int toIndex){
    }
    override
    public bool     remove(Object o){ return super.remove(o); }
    override
    public bool     remove(String o){ return super.remove(o); }
    override
    public bool     removeAll(Collection c){ return super.removeAll(c); }
    override
    public bool     retainAll(Collection c){ return super.retainAll(c); }
    public Object set(int index, Object element){
        throw new UnsupportedOperationException();
    }
    public List   subList(int fromIndex, int toIndex){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public Object[] toArray(){ return super.toArray(); }
    override
    public Object[] toArray(Object[] a){ return super.toArray(a); }
    override
    public String[] toArray(String[] a){ return super.toArray(a); }
    public int opApply (int delegate(ref Object value) dg){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    override
    public String toString(){
        return super.toString();
    }
}

