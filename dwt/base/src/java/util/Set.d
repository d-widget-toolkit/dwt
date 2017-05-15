module java.util.Set;

import java.lang.all;
import java.util.Collection;
import java.util.Iterator;

interface Set : Collection {
    public bool     add(Object o);
    public bool     add(String o);
    public bool     addAll(Collection c);
    public void     clear();
    public bool     contains(Object o);
    public bool     contains(String o);
    public bool     containsAll(Collection c);
    public equals_t opEquals(Object o);
    public hash_t   toHash();
    public bool     isEmpty();
    public Iterator iterator();
    public bool     remove(Object o);
    public bool     remove(String o);
    public bool     removeAll(Collection c);
    public bool     retainAll(Collection c);
    public int      size();
    public Object[] toArray();
    public Object[] toArray(Object[] a);
    public String   toString();

    // only for D
    public int opApply (int delegate(ref Object value) dg);
}

