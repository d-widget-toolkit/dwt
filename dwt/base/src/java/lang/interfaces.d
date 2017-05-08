module java.lang.interfaces;

import java.lang.String;

interface Cloneable{
}

interface Comparable {
    int compareTo(Object o);
}
// is now in java.util.Comparator
//interface Comparator {
//    int compare(Object o1, Object o2);
//}

interface CharSequence {
    char         charAt(int index);
    int          length();
    CharSequence subSequence(int start, int end);
    String       toString();
}

