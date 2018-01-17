module java.util.Vector;

import java.lang.all;
import java.util.AbstractList;
import java.util.List;
import java.util.Collection;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.ListIterator;

class Vector : AbstractList, List {
    Object[] vect;
    int used;
    int capacityIncrement = 32;
    public this(){
    }
    public this(Collection c){
        implMissing( __FILE__, __LINE__ );
    }
    public this(int initialCapacity){
        vect.length = initialCapacity;
    }
    public this(int initialCapacity, int capacityIncrement){
        implMissing( __FILE__, __LINE__ );
    }
    override
    public void   add(int index, Object element){
        implMissing( __FILE__, __LINE__ );
    }
    override
    public bool    add(Object o){
        if( used + 1 >= vect.length ){
            vect.length = vect.length + capacityIncrement;
        }
        vect[used] = o;
        used++;
        return true;
    }
    override
    public bool    add(String o){
        return add(stringcast(o));
    }
    override
    public bool    addAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    public bool    addAll(int index, Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    public void   addElement(Object obj){
        add(obj);
    }
    public int    capacity(){
        return cast(int)/*64bit*/vect.length;
    }
    override
    public void   clear(){
        used = 0;
    }
    public Object     clone(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public bool    contains(Object elem){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    public bool    contains(String str){
        return contains(stringcast(str));
    }
    override
    public bool    containsAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    public void   copyInto(void*[] anArray){
        implMissing( __FILE__, __LINE__ );
    }
    //public void   copyInto(Object[] anArray){
    //    implMissing( __FILE__, __LINE__ );
    //}
    public Object     elementAt(int index){
        return get(index);
    }
    public Enumeration    elements(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
   public  void   ensureCapacity(int minCapacity){
        implMissing( __FILE__, __LINE__ );
    }
    override
    public equals_t opEquals(Object o){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    public Object     firstElement(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public Object     get(int index){
        if( index >= used || index < 0 ){
            throw new ArrayIndexOutOfBoundsException( __FILE__, __LINE__ );
        }
        return vect[index];
    }
    override
    public hash_t    toHash(){
        implMissingSafe( __FILE__, __LINE__ );
        return 0;
    }
    override
    public int    indexOf(Object elem){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    public int    indexOf(Object elem, int index){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    public void   insertElementAt(Object obj, int index){
        implMissing( __FILE__, __LINE__ );
    }
    override
    public bool    isEmpty(){
        return used is 0;
    }
    override
    public Iterator   iterator(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public Object     lastElement(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public int    lastIndexOf(Object elem){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    public int    lastIndexOf(Object elem, int index){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    override
    public ListIterator   listIterator(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public ListIterator   listIterator(int index){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public Object     remove(int index){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public bool    remove(Object o){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    public bool remove(String key){
        return remove(stringcast(key));
    }
    override
    public bool    removeAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    public void   removeAllElements(){
        implMissing( __FILE__, __LINE__ );
    }
    public bool    removeElement(Object obj){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    public void   removeElementAt(int index){
        implMissing( __FILE__, __LINE__ );
    }
    override
    protected  void     removeRange(int fromIndex, int toIndex){
        implMissing( __FILE__, __LINE__ );
    }
    override
    public bool    retainAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    public Object     set(int index, Object element){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public void   setElementAt(Object obj, int index){
        implMissing( __FILE__, __LINE__ );
    }
    public void   setSize(int newSize){
        implMissing( __FILE__, __LINE__ );
    }
    override
    public int    size(){
        return used;
    }
    override
    public List   subList(int fromIndex, int toIndex){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public Object[]   toArray(){
        return vect[ 0 .. used ].dup;
    }
    override
    public Object[]   toArray(Object[] a){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    String[]   toArray(String[] a){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    public String     toString(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public void   trimToSize(){
        implMissing( __FILE__, __LINE__ );
    }

    // only for D
    override
    public int opApply (int delegate(ref Object value) dg){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

}

