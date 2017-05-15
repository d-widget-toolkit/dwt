/*==========================================================================
 * weakref.d
 *    Written in the D Programming Language (http://www.digitalmars.com/d)
 */
/***************************************************************************
 * Creates a weak reference to a class instance.
 *
 * A weak reference lets you hold onto a pointer to an object without
 * preventing the garbage collector from collecting it.
 * If the garbage collector collects the object then the weak pointer will
 * become 'null'.  Thus one should always check a weak pointer for null
 * before doing anything that depends upon it having a value.
 *
 * Tested with:
 *    DMD 1.025 / Phobos 1.025
 *    DMD 1.025 / Tango 0.99.4
 *
 * Usage example:
---
 class Something {}

 auto a = new Something();
 auto wa = new WeakRef!(Something)(a);
 std.gc.fullCollect();

 // Reference 'a' prevents collection so wa.ptr is non-null
 assert(wa.ptr is a);

 delete a;

 // 'a' is gone now, so wa.ptr magically becomes null
 assert(wa.ptr is null);
---
 *
 *
 * Author:  William V. Baxter III
 * Contributors:
 * Date: 21 Jan 2008
 * Copyright: (C) 2008  William Baxter
 * License: Public Domain where allowed by law, ZLIB/PNG otherwise.
 */
//===========================================================================

module java.nonstandard.WeakRef;

private {
    alias void delegate(Object) DisposeEvt;
    extern (C) void  rt_attachDisposeEvent( Object obj, DisposeEvt evt );
    extern (C) void  rt_detachDisposeEvent( Object obj, DisposeEvt evt );
}

class WeakRef(T : Object) {
private:
    size_t cast_ptr_;
    void unhook(Object o) {
        if (cast(size_t)cast(void*)o == cast_ptr_) {
            rt_detachDisposeEvent(o, &unhook);
            cast_ptr_ = 0;
        }
    }
public:

    this(T tptr) {
        cast_ptr_ = cast(size_t)cast(void*)tptr;
        rt_attachDisposeEvent(tptr, &unhook);
    }
    ~this() {
        T p = ptr();
        if (p) {
            rt_detachDisposeEvent(p, &unhook);
        }
    }
    T ptr() {
        return cast(T)cast(void*)cast_ptr_;
    }
    WeakRef dup() {
        return new WeakRef(ptr());
    }
    equals_t opEquals( Object o ){
        if( auto other = cast( WeakRef!(T) )o ){
            return other.cast_ptr_ is cast_ptr_;
        }
        return false;
    }
    hash_t toHash(){
        return cast_ptr_;
    }
}
