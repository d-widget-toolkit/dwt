module java.util.WeakHashMap;


private {
    alias void delegate(Object) DisposeEvt;
    extern (C) void  rt_attachDisposeEvent( Object obj, DisposeEvt evt );
    extern (C) void  rt_detachDisposeEvent( Object obj, DisposeEvt evt );
}


/+
    Is not yet 'weak'
+/
class WeakHashMap {

    static class Ref {
        size_t ptr;
        this(Object k){
            ptr = cast(size_t)cast(void*)k;
        }
        override hash_t toHash(){
            return cast(hash_t)ptr;
        }
        override equals_t opEquals( Object o ){
            if( auto other = cast(Ref)o ){
                return ptr is other.ptr;
            }
            return false;
        }
    }

    private Ref unhookKey;

    private void unhook(Object o) {
        unhookKey.ptr = cast(size_t)cast(void*)o;
        if( auto p = unhookKey in data ){
            rt_detachDisposeEvent(o, &unhook);
            data.remove( unhookKey );
        }
    }

    Object[ Ref ] data;
    version(Tango){
        ClassInfo gcLock;
    } else { // Phobos
        mixin("const ClassInfo gcLock;");
    }
    this(){
        unhookKey = new Ref(null);
        gcLock = ClassInfo.find( "gcx.GCLock" );
    }

    public void put (Object key, Object element){
        auto k = new Ref(key);
        rt_attachDisposeEvent(key, &unhook);
        data[ k ] = element;
    }
    public void remove (Object key){
        scope k = new Ref(key);
        if( auto p = k in data ){
            data.remove( k );
            rt_detachDisposeEvent(key, &unhook);
        }
    }
    public Object get(Object key){
        scope k = new Ref(key);
        if( auto p = k in data ){
            return *p;
        }
        return null;
    }
}
