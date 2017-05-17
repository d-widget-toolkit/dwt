module java.util.Collections;

import java.lang.all;
import java.util.Collection;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.List;
import java.util.Iterator;
import java.util.ListIterator;
import java.util.Enumeration;
import java.util.ArrayList;
import java.util.Comparator;

class Collections {
    private static void unsupported(){
        throw new UnsupportedOperationException();
    }

    private static List EMPTY_LIST_;
    public static List EMPTY_LIST(){
        if( EMPTY_LIST_ is null ){
            synchronized(Collections.classinfo ){
                if( EMPTY_LIST_ is null ){
                    EMPTY_LIST_ = new ArrayList(0);
                }
            }
        }
        return EMPTY_LIST_;
    }
    private static Map EMPTY_MAP_;
    public static Map EMPTY_MAP(){
        if( EMPTY_MAP_ is null ){
            synchronized(Collections.classinfo ){
                if( EMPTY_MAP_ is null ){
                    EMPTY_MAP_ = new TreeMap();
                }
            }
        }
        return EMPTY_MAP_;
    }
    private static Set EMPTY_SET_;
    public static Set EMPTY_SET(){
        if( EMPTY_SET_ is null ){
            synchronized(Collections.classinfo ){
                if( EMPTY_SET_ is null ){
                    EMPTY_SET_ = new TreeSet();
                }
            }
        }
        return EMPTY_SET_;
    }
    static class UnmodifiableIterator : Iterator {
        Iterator it;
        this(Iterator it){
            this.it = it;
        }
        public bool hasNext(){
            return it.hasNext();
        }
        public Object next(){
            return it.next();
        }
        public void  remove(){
            unsupported();
        }
    }
    static class UnmodifiableListIterator : ListIterator {
        ListIterator it;
        this(ListIterator it){
            this.it = it;
        }
        public void   add(Object o){
            unsupported();
        }
        public void   add(String o){
            unsupported();
        }
        public bool   hasNext(){
            return it.hasNext();
        }
        public bool   hasPrevious(){
            return it.hasPrevious();
        }
        public Object next(){
            return it.next();
        }
        public int    nextIndex(){
            return it.nextIndex();
        }
        public Object previous(){
            return it.previous();
        }
        public int    previousIndex(){
            return it.previousIndex();
        }
        public void   remove(){
            unsupported();
        }
        public void   set(Object o){
            unsupported();
        }
    }
    static class UnmodifieableList : List {
        List list;
        this(List list){
            this.list = list;
        }
        public void     add(int index, Object element){
            unsupported();
        }
        public bool     add(Object o){
            unsupported();
            return false; // make compiler happy
        }
        public bool     add(String o){
            unsupported();
            return false; // make compiler happy
        }
        public bool     addAll(Collection c){
            unsupported();
            return false; // make compiler happy
        }
        public bool     addAll(int index, Collection c){
            unsupported();
            return false; // make compiler happy
        }
        public void     clear(){
            unsupported();
        }
        public bool     contains(Object o){
            return list.contains(o);
        }
        public bool     contains(String o){
            return list.contains(o);
        }
        public bool     containsAll(Collection c){
            return list.containsAll(c);
        }
        override
        public equals_t      opEquals(Object o){
            return cast(equals_t)list.opEquals(o);
        }
        public Object   get(int index){
            return list.get(index);
        }
        override
        public hash_t   toHash(){
            return list.toHash();
        }
        public int      indexOf(Object o){
            return list.indexOf(o);
        }
        public bool     isEmpty(){
            return list.isEmpty();
        }
        public Iterator iterator(){
            return new UnmodifiableIterator( list.iterator() );
        }
        public int      lastIndexOf(Object o){
            return list.lastIndexOf(o);
        }
        public ListIterator   listIterator(){
            return new UnmodifiableListIterator( list.listIterator() );
        }
        public ListIterator   listIterator(int index){
            return new UnmodifiableListIterator( list.listIterator(index) );
        }
        public Object   remove(int index){
            unsupported();
            return null; // make compiler happy
        }
        public bool     remove(Object o){
            unsupported();
            return false; // make compiler happy
        }
        public bool     remove(String o){
            unsupported();
            return false; // make compiler happy
        }
        public bool     removeAll(Collection c){
            unsupported();
            return false; // make compiler happy
        }
        public bool     retainAll(Collection c){
            unsupported();
            return false; // make compiler happy
        }
        public Object   set(int index, Object element){
            unsupported();
            return null; // make compiler happy
        }
        public int      size(){
            return list.size();
        }
        public List     subList(int fromIndex, int toIndex){
            return new UnmodifieableList( list.subList(fromIndex,toIndex));
        }
        public Object[] toArray(){
            return list.toArray();
        }
        public Object[] toArray(Object[] a){
            return list.toArray(a);
        }
        public String[] toArray(String[] a){
            return list.toArray(a);
        }
        public int opApply (int delegate(ref Object value) dg){
            implMissing(__FILE__, __LINE__ );
            return 0;
        }
        public int opApply (int delegate(ref Object key, ref Object value) dg){
            implMissing(__FILE__, __LINE__ );
            return 0;
        }
        override
        public String toString(){
            return list.toString();
        }
    }
    static int binarySearch(List list, Object key){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    static int binarySearch(List list, Object key, Comparator c){
        implMissing( __FILE__, __LINE__ );
        return 0;
    }
    public static List unmodifiableList( List list ){
        return new UnmodifieableList(list);
    }
    public static Map unmodifiableMap( Map list ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public static Set unmodifiableSet( Set list ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public static List singletonList( Object o ){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    public static Set singleton( Object o ){
        TreeSet res = new TreeSet();
        res.add(o);
        return res;
    }
    public static void     sort(List list){
        implMissing( __FILE__, __LINE__ );
    }
    public static void     sort(List list, Comparator c){
        implMissing( __FILE__, __LINE__ );
    }

    static Collection   synchronizedCollection(Collection c){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
    static class SynchronizedList : List {
        private List list;
        private this( List list ){
            this.list = list;
        }
        // Collection
        public int opApply (int delegate(ref Object value) dg){ synchronized(this){ return this.list.opApply(dg); } }
        // List
        public void     add(int index, Object element){ synchronized(this){ return this.list.add(index, element); } }
        public bool     add(Object o){ synchronized(this){ return this.list.add(o); } }
        public bool     add(String o){ synchronized(this){ return this.list.add(o); } }
        public bool     addAll(Collection c){ synchronized(this){ return this.list.addAll(c); } }
        public bool     addAll(int index, Collection c){ synchronized(this){ return this.list.addAll(index, c); } }
        public void     clear(){ synchronized(this){ return this.list.clear(); } }
        public bool     contains(Object o){ synchronized(this){ return this.list.contains(o); } }
        public bool     contains(String o){ synchronized(this){ return this.list.contains(o); } }
        public bool     containsAll(Collection c){ synchronized(this){ return this.list.containsAll(c); } }
        override
        public equals_t      opEquals(Object o){ synchronized(this){ return cast(equals_t)this.list.opEquals(o); } }
        public Object   get(int index){ synchronized(this){ return this.list.get(index); } }
        override
        public hash_t   toHash(){ return this.list.toHash(); }
        public int      indexOf(Object o){ synchronized(this){ return this.list.indexOf(o); } }
        public bool     isEmpty(){ synchronized(this){ return this.list.isEmpty(); } }
        public Iterator iterator(){ synchronized(this){ return this.list.iterator(); } }
        public int      lastIndexOf(Object o){ synchronized(this){ return this.list.lastIndexOf(o); } }
        public ListIterator   listIterator(){ synchronized(this){ return this.list.listIterator(); } }
        public ListIterator   listIterator(int index){ synchronized(this){ return this.list.listIterator(index); } }
        public Object   remove(int index){ synchronized(this){ return this.list.remove(index); } }
        public bool     remove(Object o){ synchronized(this){ return this.list.remove(o); } }
        public bool     remove(String o){ synchronized(this){ return this.list.remove(o); } }
        public bool     removeAll(Collection c){ synchronized(this){ return this.list.removeAll(c); } }
        public bool     retainAll(Collection c){ synchronized(this){ return this.list.retainAll(c); } }
        public Object   set(int index, Object element){ synchronized(this){ return this.list.set(index,element); } }
        public int      size(){ synchronized(this){ return this.list.size(); } }
        public List     subList(int fromIndex, int toIndex){ synchronized(this){ return this.list.subList(fromIndex,toIndex); } }
        public Object[] toArray(){ synchronized(this){ return this.list.toArray(); } }
        public Object[] toArray(Object[] a){ synchronized(this){ return this.list.toArray(a); } }
        public String[] toArray(String[] a){ synchronized(this){ return this.list.toArray(a); } }
        override
        public String toString(){ synchronized(this){ return this.list.toString(); } }
    }
    static List     synchronizedList(List list){
        return new SynchronizedList(list);
    }

    static class SynchronizedMap : Map {
        private Map map;
        //interface Entry {
        //    int   opEquals(Object o);
        //    Object     getKey();
        //    Object     getValue();
        //    hash_t     toHash();
        //    Object     setValue(Object value);
        //}
        private this( Map map ){
            this.map = map;
        }
        public void clear(){ synchronized(this){ this.map.clear(); } }
        public bool containsKey(Object key){ synchronized(this){ return this.map.containsKey(key); } }
        public bool containsKey(String key){ synchronized(this){ return this.map.containsKey(key); } }
        public bool containsValue(Object value){ synchronized(this){ return this.map.containsValue(value); } }
        public Set  entrySet(){ synchronized(this){ return this.map.entrySet(); } }
        override
        public equals_t opEquals(Object o){ synchronized(this){ return this.map.opEquals(o); } }
        public Object get(Object key){ synchronized(this){ return this.map.get(key); } }
        public Object get(String key){ synchronized(this){ return this.map.get(key); } }
        override
        public hash_t toHash(){ return this.map.toHash(); }
        public bool isEmpty(){ synchronized(this){ return this.map.isEmpty(); } }
        public Set    keySet(){ synchronized(this){ return this.map.keySet(); } }
        public Object put(Object key, Object value){ synchronized(this){ return this.map.put(key,value); } }
        public Object put(String key, Object value){ synchronized(this){ return this.map.put(key,value); } }
        public Object put(Object key, String value){ synchronized(this){ return this.map.put(key,value); } }
        public Object put(String key, String value){ synchronized(this){ return this.map.put(key,value); } }
        public void   putAll(Map t){ synchronized(this){ return this.map.putAll(t); } }
        public Object remove(Object key){ synchronized(this){ return this.map.remove(key); } }
        public Object remove(String key){ synchronized(this){ return this.map.remove(key); } }
        public int    size(){ synchronized(this){ return this.map.size(); } }
        public Collection values(){ synchronized(this){ return this.map.values(); } }

        // only for D
        public int opApply (int delegate(ref Object value) dg){ synchronized(this){ return this.map.opApply( dg ); } }
        public int opApply (int delegate(ref Object key, ref Object value) dg){ synchronized(this){ return this.map.opApply( dg ); } }
    }
    static Map  synchronizedMap(Map m){
        return new SynchronizedMap(m);
    }
    static Set  synchronizedSet(Set s){
        implMissing( __FILE__, __LINE__ );
        return null;
    }
//     static SortedMap    synchronizedSortedMap(SortedMap m){
//         implMissing( __FILE__, __LINE__ );
//         return null;
//     }
//     static SortedSet    synchronizedSortedSet(SortedSet s){
//         implMissing( __FILE__, __LINE__ );
//         return null;
//     }
    static void     reverse(List list) {
        Object[] data = list.toArray();
        for( int idx = 0; idx < data.length; idx++ ){
            list.set( cast(int)/*64bit*/data.length -1 -idx, data[idx] );
        }
    }
    static class LocalEnumeration : Enumeration {
        Object[] data;
        this( Object[] data ){
            this.data = data;
        }
        public bool hasMoreElements(){
            return data.length > 0;
        }
        public Object nextElement(){
            Object res = data[0];
            data = data[ 1 .. $ ];
            return res;
        }
    }
    static Enumeration     enumeration(Collection c){
        return new LocalEnumeration( c.toArray() );
    }
}

