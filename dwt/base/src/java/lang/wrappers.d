module java.lang.wrappers;

import java.lang.util;
import java.lang.String;

abstract class ArrayWrapper{
}
abstract class ValueWrapper{
}

class ArrayWrapperT(T) : ArrayWrapper {
    public T[] array;
    public this( T[] data ){
        array = data;
    }
    version(D_Version2){
        static if( is(T == char )){
            public this( String data ){
                array = data.dup;
            }
        }
    }
    public override equals_t opEquals( Object o ){
        if( auto other = cast(ArrayWrapperT!(T))o){
            return array == other.array;
        }
        return false;
    }
    public override hash_t toHash(){
        return (typeid(T[])).getHash(&array);
    }
    static if( is( T == char )){
        public override String toString(){
            return _idup(array);
        }
    }
}

class ValueWrapperT(T) : ValueWrapper {
    public T value;
    public this( T data ){
        value = data;
    }
    static if( is(T==class) || is(T==interface)){
        public equals_t opEquals( Object other ){
            if( auto o = cast(ValueWrapperT!(T))other ){
                return value == o.value;
            }
            if( auto o = cast(T)other ){
                if( value is o ){
                    return true;
                }
                if( value is null || o is null ){
                    return false;
                }
                return value == o;
            }
            return false;
        }
    }
    else{
        override
        public equals_t opEquals( Object other ){
            if( auto o = cast(ValueWrapperT!(T))other ){
                return value == o.value;
            }
            return false;
        }
        public equals_t opEquals( T other ){
            return value == other;
        }
    }
    public override hash_t toHash(){
        return (typeid(T)).getHash(&value);
    }
}

alias ArrayWrapperT!(byte)    ArrayWrapperByte;
alias ArrayWrapperT!(int)     ArrayWrapperInt;
alias ArrayWrapperT!(Object)  ArrayWrapperObject;
alias ArrayWrapperT!(char)    ArrayWrapperString;
alias ArrayWrapperT!(String)  ArrayWrapperString2;

Object[] StringArrayToObjectArray( String[] strs ){
    Object[] res = new Object[strs.length];
    foreach( idx, str; strs ){
        res[idx] = new ArrayWrapperString(cast(char[])str);
    }
    return res;
}

String stringcast( Object o ){
    if( auto swrapper = cast(ArrayWrapperString) o ){
        return swrapper.toString();
    }
    return null;
}
String[] stringcast( Object[] objs ){
    String[] res = new String[](objs.length);
    foreach( idx, obj; objs ){
        res[idx] = stringcast(obj);
    }
    return res;
}
ArrayWrapperString stringcast( String str ){
    return new ArrayWrapperString( cast(char[])str );
}
ArrayWrapperString[] stringcast( String[] strs ){
    ArrayWrapperString[] res = new ArrayWrapperString[ strs.length ];
    foreach( idx, str; strs ){
        res[idx] = stringcast(str);
    }
    return res;
}

String[] stringArrayFromObject( Object obj ){
    if( auto wrapper = cast(ArrayWrapperString2)obj ){
        return wrapper.array;
    }
    if( auto wrapper = cast(ArrayWrapperObject)obj ){
        String[] res = new String[ wrapper.array.length ];
        foreach( idx, o; wrapper.array ){
            if( auto swrapper = cast(ArrayWrapperString) o ){
                res[idx] = swrapper.toString();
            }
        }
        return res;
    }
    assert( obj is null ); // if not null, it was the wrong type
    return null;
}

T[] arrayFromObject(T)( Object obj ){
    if( auto wrapper = cast(ArrayWrapperObject)obj ){
        T[] res = new T[ wrapper.array.length ];
        foreach( idx, o; wrapper.array ){
            res[idx] = cast(T)o;
        }
        return res;
    }
    assert( obj is null ); // if not null, it was the wrong type
    return null;
}


