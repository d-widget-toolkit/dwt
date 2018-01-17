module java.util.SortedSet;

import java.lang.all;
import java.util.Set;
import java.util.Comparator;

interface SortedSet : Set {
    Comparator     comparator();
    Object         first();
    SortedSet      headSet(Object toElement);
    Object         last();
    SortedSet      subSet(Object fromElement, Object toElement);
    SortedSet      tailSet(Object fromElement);
}

