module java.util.Arrays;

import java.lang.all;
import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
version(Tango){
    static import tango.core.Array;
} else { // Phobos
}

class Arrays {
    public static bool equals(T)(T[] a, T[] b){
        if( a.length !is b.length ){
            return false;
        }
        for( int i = 0; i < a.length; i++ ){
            if( a[i] is null && b[i] is null ){
                continue;
            }
            if( a[i] !is null && b[i] !is null && a[i] == b[i] ){
                continue;
            }
            return false;
        }
        return true;
    }
/+    public static bool equals(Object[] a, Object[] b){
        if( a.length !is b.length ){
            return false;
        }
        for( int i = 0; i < a.length; i++ ){
            if( a[i] is null && b[i] is null ){
                continue;
            }
            if( a[i] !is null && b[i] !is null && a[i] == b[i] ){
                continue;
            }
            return false;
        }
        return true;
    }
+/
    static int binarySearch( T )( T[] a, T b ){
        if( tango.core.Array.bsearch( a, b )){
            tango.core.Array.lbound( a, b );
        }
        else{
            return -(tango.core.Array.lbound( a, b ))-1;
        }
    }
    static void sort( T )( T[] a ){
        tango.core.Array.sort( a );
    }
    static void sort( T )( T[] a, Comparator c ){
        static if( is( T : char[] )){
            bool isLess( String o1, String o2 ){
                return c.compare( stringcast(o1), stringcast(o2) ) < 0;
            }
        }
        else{
            bool isLess( T o1, T o2 ){
                return c.compare( cast(Object)o1, cast(Object)o2 ) < 0;
            }
        }
        tango.core.Array.sort( a, &isLess );
    }
    static List    asList(T)(T[] a) {
        static if( is(T==String)){
            if( a.length is 0 ) return Collections.EMPTY_LIST;
            ArrayList res = new ArrayList( a.length );
            foreach( o; a ){
                res.add( stringcast(o));
            }
            return res;
        }
        else{
            static assert( is(T==interface) || is(T==class), "asList");
            if( a.length is 0 ) return Collections.EMPTY_LIST;
            ArrayList res = new ArrayList( a.length );
            foreach( o; a ){
                res.add( cast(Object)o);
            }
            return res;
        }
    }
    public static void fill( char[] str, char c ){
        str[] = c;
    }
}

