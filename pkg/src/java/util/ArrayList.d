module java.util.ArrayList;

import java.lang.all;
import java.util.AbstractList;
import java.util.List;
import java.util.ListIterator;
import java.util.Collection;
import java.util.Iterator;

class ArrayList : AbstractList, List {
    private Object[] data;

    this(){
    }
    this(int size){
        data.length = size;
        data.length = 0;
    }
    this(Collection col){
        this(cast(int)(col.size*1.1));
        addAll(col);
    }
    override
    void   add(int index, Object element){
        data.length = data.length +1;
        System.arraycopy( data, index, data, index+1, data.length - index -1 );
        data[index] = element;
    }
    override
    bool    add(Object o){
        data ~= o;
        return true;
    }
    override
    public bool    add(String o){
        return add(stringcast(o));
    }
    override
    bool    addAll(Collection c){
        if( c.size() is 0 ) return false;
        size_t idx = data.length;
        data.length = data.length + c.size();
        foreach( o; c ){
            data[ idx++ ] = o;
        }
        return true;
    }
    override
    bool    addAll(int index, Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    void   clear(){
        data.length = 0;
    }
    ArrayList clone(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    bool    contains(Object o){
        foreach( v; data ){
            if( o is v ){
                return true;
            }
            if(( o is null ) || ( v is null )){
                continue;
            }
            if( o == v ){
                return true;
            }
        }
        return false;
    }
    override
    bool    contains(String o){
        return contains(stringcast(o));
    }
    override
    bool    containsAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    equals_t opEquals(Object o){
        if( auto other = cast(ArrayList)o ){
            if( data.length !is other.data.length ){
                return false;
            }
            for( int i = 0; i < data.length; i++ ){
                if( data[i] is other.data[i] ){
                    continue;
                }
                if(( data[i] is null ) || ( other.data[i] is null )){
                    return false;
                }
                if( data[i] == other.data[i] ){
                    continue;
                }
                return false;
            }
            return true;
        }
        return false;
    }
    override
    Object     get(int index){
        return data[index];
    }
    public override hash_t toHash(){
        // http://java.sun.com/j2se/1.4.2/docs/api/java/util/List.html#hashCode()
        hash_t hashCode = 1;
        for( int i = 0; i < data.length; i++ ){
            Object obj = data[i];
            hashCode = 31 * hashCode + (obj is null ? 0 : obj.toHash());
        }
        return hashCode;
    }
    override
    int    indexOf(Object o){
        foreach( i, v; data ){
            if( data[i] is o ){
                return cast(int)/*64bit*/i;
            }
            if(( data[i] is null ) || ( o is null )){
                continue;
            }
            if( data[i] == o ){
                return cast(int)/*64bit*/i;
            }
        }
        return -1;
    }
    override
    bool    isEmpty(){
        return data.length is 0;
    }
    class LocalIterator : Iterator{
        int idx = -1;
        public this(){
        }
        public bool hasNext(){
            return idx+1 < data.length;
        }
        public Object next(){
            idx++;
            Object res = data[idx];
            return res;
        }
        public void  remove(){
            implMissing( __FILE__, __LINE__ );
            this.outer.remove(idx);
            idx--;
        }
    }

    override
    Iterator   iterator(){
        return new LocalIterator();
    }
    override
    int    lastIndexOf(Object o){
        foreach_reverse( i, v; data ){
            if( data[i] is o ){
                return cast(int)/*64bit*/i;
            }
            if(( data[i] is null ) || ( o is null )){
                continue;
            }
            if( data[i] == o ){
                return cast(int)/*64bit*/i;
            }
        }
        return -1;
    }

    class LocalListIterator : ListIterator {
        int idx_next = 0;
        public bool hasNext(){
            return idx_next < data.length;
        }
        public Object next(){
            Object res = data[idx_next];
            idx_next++;
            return res;
        }
        public void  remove(){
            implMissing( __FILE__, __LINE__ );
            this.outer.remove(idx_next);
            idx_next--;
        }
        public void   add(Object o){
            implMissing( __FILE__, __LINE__ );
        }
        public void   add(String o){
            implMissing( __FILE__, __LINE__ );
        }
        public bool   hasPrevious(){
            return idx_next > 0;
        }
        public int    nextIndex(){
            return idx_next;
        }
        public Object previous(){
            idx_next--;
            Object res = data[idx_next];
            return res;
        }
        public int    previousIndex(){
            return idx_next-1;
        }
        public void   set(Object o){
            implMissing( __FILE__, __LINE__ );
        }
    }

    override
    ListIterator   listIterator(){
        return new LocalListIterator();
    }
    override
    ListIterator   listIterator(int index){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    Object     remove(int index){
        Object res = data[index];
        System.arraycopy( data, index+1, data, index, data.length - index - 1 );
        data.length = data.length -1;
        return res;
    }
    override
    bool    remove(Object o){
        int idx = -1;
        for( int i = 0; i < data.length; i++ ){
            if( data[i] is null ? o is null : data[i] == o ){
                idx = i;
                break;
            }
        }
        if( idx is -1 ){
            return false;
        }
        for( int i = idx + 1; i < data.length; i++ ){
            data[i-1] = data[i];
        }
        data.length = data.length - 1;
        return true;
    }
    override
    public bool remove(String key){
        return remove(stringcast(key));
    }
    override
    bool    removeAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    bool    retainAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    protected  void     removeRange(int fromIndex, int toIndex){
        implMissing( __FILE__, __LINE__ );
    }
    override
    Object     set(int index, Object element){
        Object res = data[index];
        data[index] = element;
        return res;
    }
    override
    int    size(){
        return cast(int)/*64bit*/data.length;
    }
    override
    List   subList(int fromIndex, int toIndex){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    Object[]   toArray(){
        return data.dup;
    }
    override
    Object[]   toArray(Object[] a){
        if( data.length <= a.length ){
            a[ 0 .. data.length ] = data;
        }
        else{
            return data.dup;
        }
        if( data.length < a.length ){
            a[data.length] = null;
        }
        return a;
    }
    override
    String[]   toArray(String[] a){
        version(Tango){
            auto res = a;
            if( res.length < data.length ){
                res.length = data.length;
            }
            int idx = 0;
            foreach( o; data ){
                res[idx] = stringcast(o);
            }
            return res;
        } else { // Phobos
            implMissingInPhobos();
            return null;
        }
    }

    // only for D
    override
    public int opApply (int delegate(ref Object value) dg){
        foreach( o; data ){
            auto res = dg( o );
            if( res ) return res;
        }
        return 0;
    }
    override
    public String toString(){
        return super.toString();
    }
}

