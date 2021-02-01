module java.util.HashSet;

import java.lang.all;
import java.util.Set;
import java.util.Collection;
import java.util.Iterator;

version(Tango){
    static import tango.util.container.HashSet;
} else { // Phobos
}

/**
 * This class implements the {@code Set} interface, backed by a hash table
 * (actually a {@code HashMap} instance).  It makes no guarantees as to the
 * iteration order of the set; in particular, it does not guarantee that the
 * order will remain constant over time.  This class permits the {@code null}
 * element.
 */
class HashSet : Set {
    version(Tango){
        alias tango.util.container.HashSet.HashSet!(Object) SetType;
        private SetType set;
    } else { // Phobos
        alias SetType = void[0][Object];
        private SetType set;
    }

    /**
     * Constructs a new, empty set.
     */
    public this(){
        version(Tango){
            set = new SetType();
        } else { // Phobos
            // already initialized (to null)
        }
    }

    /**
     * Constructs a new set containing the elements in the specified
     * collection.
     *
     * @param c the collection whose elements are to be placed into this set.
     */
    public this(Collection c){
        version(Tango){
            set = new SetType();
            addAll(c);
        } else { // Phobos
            // already initialized (to null)
            this.addAll(c);
        }
    }

    /**
     * Constructs a new, empty set.
     *
     * D2/Phobos: This method has no difference compared to `this()`.
     *
     * @param initialCapacity the initial capacity of the hash table.
     */
    public this(int initialCapacity){
        version(Tango){
            set = new SetType();
        } else { // Phobos
            // already initialized (to null)
        }
    }

    /**
     * Constructs a new, empty set.
     *
     * D2/Phobos: This method has no difference compared to `this()`.
     *
     * @param initialCapacity the initial capacity of the hash map
     * @param loadFactor the load factor of the hash map
     */
    public this(int initialCapacity, float loadFactor){
        version(Tango){
            set = new SetType(loadFactor);
        } else { // Phobos
            // already initialized (to null)
        }
    }

    /**
     * Adds the specified element to this set if it is not already present.
     * More formally, adds the specified element {@code e} to this set if
     * this set contains no element {@code e2} such that
     * {@code Objects.equals(e, e2)}.
     * If this set already contains the element, the call leaves the set
     * unchanged and returns {@code false}.
     *
     * @param e element to be added to this set
     * @return {@code true} if this set did not already contain the specified
     * element
     */
    public bool add(Object o) {
        version(Tango) {
            return set.add(o);
        } else { // Phobos
            static if (__traits(hasMember, .object, "update"))
            {
                bool res = false;
                set.update(o, {
                    res = true;
                    return (void[0]).init;
                }, (ref void[0] v) {
                    /* Keep "return" for D versions < 2.092.0 */
                    return v;
                });
                return res;
            }
            else
            {
                /* D versions < 2.082.0  */
                if (this.contains(o)) return false;
                set[o] = (void[0]).init;
                return true;
            }
        }
    }

    /// Ditto
    public bool add(String o) {
        return add(stringcast(o));
    }

    /**
     * Adds all of the elements in the specified collection to this set if
     * they're not already present (optional operation).  If the specified
     * collection is also a set, the {@code addAll} operation effectively
     * modifies this set so that its value is the <i>union</i> of the two
     * sets.  The behavior of this operation is undefined if the specified
     * collection is modified while the operation is in progress.
     *
     * @param  c collection containing elements to be added to this set
     * @return {@code true} if this set changed as a result of the call
     *
     * @throws UnsupportedOperationException if the {@code addAll} operation
     *         is not supported by this set
     * @throws ClassCastException if the class of an element of the
     *         specified collection prevents it from being added to this set
     * @throws NullPointerException if the specified collection contains one
     *         or more null elements and this set does not permit null
     *         elements, or if the specified collection is null
     * @throws IllegalArgumentException if some property of an element of the
     *         specified collection prevents it from being added to this set
     * @see #add(Object)
     */
    public bool addAll(Collection c) {
        bool res = false;
        foreach( o; c ){
            res |= add(o);
        }
        return res;
    }

    /**
     * Removes all of the elements from this set.
     * The set will be empty after this call returns.
     */
    public void clear() {
        version(Tango) {
            set.clear();
        } else { // Phobos
            set.clear();
        }
    }

    /**
     * Returns {@code true} if this set contains the specified element.
     * More formally, returns {@code true} if and only if this set
     * contains an element {@code e} such that
     * {@code Objects.equals(o, e)}.
     *
     * @param o element whose presence in this set is to be tested
     * @return {@code true} if this set contains the specified element
     */
    public bool contains(Object o){
        version(Tango){
            return set.contains(o);
        } else { // Phobos
            foreach (e; set.byKey)
            {
                if (o is null && e is null) return true;
                if (o == e) return true;
            }
            return false;
        }
    }

    /// Ditto
    public bool contains(String o) {
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

    /**
     * Returns {@code true} if this set contains no elements.
     *
     * @return {@code true} if this set contains no elements
     */
    public bool isEmpty() {
        version(Tango){
            return set.isEmpty();
        } else { // Phobos
            import std.range : empty;
            return empty(set);
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

    /**
     * Removes the specified element from this set if it is present.
     * More formally, removes an element {@code e} such that
     * {@code Objects.equals(o, e)},
     * if this set contains such an element.  Returns {@code true} if
     * this set contained the element (or equivalently, if this set
     * changed as a result of the call).  (This set will not contain the
     * element once the call returns.)
     *
     * @param o object to be removed from this set, if present
     * @return {@code true} if the set contained the specified element
     */
    public bool remove(Object o) {
        version(Tango) {
            return set.remove(o);
        } else { // Phobos
            return set.remove(o);
        }
    }

    /// Ditto
    public bool remove(String o){
        return remove(stringcast(o));
    }

    public bool    removeAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }
    public bool    retainAll(Collection c){
        implMissing( __FILE__, __LINE__ );
        return false;
    }

    /**
     * Returns the number of elements in this set (its cardinality).
     *
     * @return the number of elements in this set (its cardinality)
     */
    public int    size(){
        version(Tango){
            return set.size();
        } else { // Phobos
            return cast(int)set.length;
        }
    }

    /**
     * Returns an array containing all of the elements in this set.
     * If this set makes any guarantees as to what order its elements
     * are returned by its iterator, this method must return the
     * elements in the same order.
     *
     * <p>The returned array will be "safe" in that no references to it
     * are maintained by this set.  (In other words, this method must
     * allocate a new array even if this set is backed by an array).
     * The caller is thus free to modify the returned array.
     *
     * <p>This method acts as bridge between array-based and collection-based
     * APIs.
     *
     * @return an array containing all the elements in this set
     */
    public Object[] toArray(){
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
            return set.keys;
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
            int result = 0;
            foreach(e; set.byKey) {
                result = dg(e);

                if (result)
                    break;
            }
            return result;
        }
    }
}
