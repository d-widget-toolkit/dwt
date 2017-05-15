module java.util.Stack;

import java.lang.all;
import java.util.Vector;
import java.util.Iterator;
import java.util.ListIterator;
import java.util.Set;
import java.util.List;
import java.util.Collection;

class Stack : Vector {
    this(){
    }
    override
    void   add(int index, Object element){
        implMissing( __FILE__, __LINE__ );
    }
    override
    bool    add(Object o){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    public bool    add(String o){
        return add(stringcast(o));
    }
    override
    bool    addAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    bool    addAll(int index, Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    void   addElement(Object obj){
        implMissing( __FILE__, __LINE__ );
    }
    override
    int    capacity(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    override
    void   clear(){
        implMissing( __FILE__, __LINE__ );
    }
    override
    Object     clone(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    bool    contains(Object elem){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    bool    containsAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    void   copyInto(Object[] anArray){
        implMissing( __FILE__, __LINE__ );
    }
    override
    Object     elementAt(int index){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
//     Enumeration    elements(){
//         implMissing( __FILE__, __LINE__ );
//         return null;
//     }
    override
    void   ensureCapacity(int minCapacity){
        implMissing( __FILE__, __LINE__ );
    }
    override
    equals_t opEquals(Object o){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    Object     firstElement(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    Object     get(int index){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    hash_t    toHash(){
        implMissingSafe( __FILE__, __LINE__ );
        return 0;
    }
    override
    int    indexOf(Object elem){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    override
    int    indexOf(Object elem, int index){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    override
    void   insertElementAt(Object obj, int index){
        implMissing( __FILE__, __LINE__ );
    }
//     bool    isEmpty(){
//         implMissing( __FILE__, __LINE__ );
//         return false;
//     }
    override
    Iterator   iterator(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    Object     lastElement(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    int    lastIndexOf(Object elem){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    override
    int    lastIndexOf(Object elem, int index){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    override
    ListIterator   listIterator(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    ListIterator   listIterator(int index){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    Object     remove(int index){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    bool    remove(Object o){
        implMissing( __FILE__, __LINE__ );
        return false;
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
    void   removeAllElements(){
        implMissing( __FILE__, __LINE__ );
    }
    override
    bool    removeElement(Object obj){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    void   removeElementAt(int index){
        implMissing( __FILE__, __LINE__ );
    }
    override
    protected  void     removeRange(int fromIndex, int toIndex){
        implMissing( __FILE__, __LINE__ );
    }
    override
    bool    retainAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    override
    Object     set(int index, Object element){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    void   setElementAt(Object obj, int index){
        implMissing( __FILE__, __LINE__ );
    }
    override
    void   setSize(int newSize){
        implMissing( __FILE__, __LINE__ );
    }
    override
    int    size(){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    override
    List   subList(int fromIndex, int toIndex){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    Object[]   toArray(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    Object[]   toArray(Object[] a){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    String[]   toArray(String[] a){
        implMissing( __FILE__, __LINE__ );
        return null;
    }

    // from Stack
    override
    String     toString(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    override
    void   trimToSize(){
        implMissing( __FILE__, __LINE__ );
    }
    bool     empty(){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    Object     peek(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    Object     pop(){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    Object     push(Object item){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    int    search(Object o){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

    // only for D
    override
    public int opApply (int delegate(ref Object value) dg){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }

}

