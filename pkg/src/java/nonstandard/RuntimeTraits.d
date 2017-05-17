/**
 * Provides runtime traits, which provide much of the functionality of tango.core.Traits and
 * is-expressions, as well as some functionality that is only available at runtime, using
 * runtime type information.
 *
 * Authors: Chris Wright (dhasenan) <dhasenan@gmail.com>
 * License: tango license, apache 2.0
 * Copyright (c) 2009, CHRISTOPHER WRIGHT
 */
module java.nonstandard.RuntimeTraits;
import java.lang.all;

version(Tango){
    alias ClassInfo ConstClassInfo;
    alias TypeInfo ConstTypeInfo;
} else { // Phobos
    mixin("alias const(TypeInfo_Class) ConstClassInfo;");
    mixin("alias const(TypeInfo) ConstTypeInfo;");
}

// Only DWT
public bool isJavaPrimitive( in TypeInfo type ){
    return isBool(type) || isInteger(type) || isCharacter(type) || isFloat(type);
}

public TypeInfo_Class getTypeInfo( in ClassInfo ci ){
    return null;
}

public TypeInfo_Class getSuperclass( in ClassInfo ci ){
    return getSuperclass(getTypeInfo(ci));
}
public TypeInfo_Class getSuperclass( in TypeInfo ti ){
    return null;
}

public TypeInfo_Interface[] getInterfaces( in ClassInfo ci ){
    return getInterfaces(getTypeInfo(ci));
}
public TypeInfo_Interface[] getInterfaces( in TypeInfo ti ){
    return null;
}

public String getName( in ClassInfo ci ){
    return ci.name;
}
public String getName( in TypeInfo ti ){
    if( isClass(ti) ){
        return getName( asClass(ti));
    }
    return null;
}

// End DWT. Start Tango...
/// If the given type represents a typedef, return the actual type.
ConstTypeInfo realType (in TypeInfo type)
{
    // TypeInfo_Typedef.next() doesn't return the actual type.
    // I think it returns TypeInfo_Typedef.base.next().
    // So, a slightly different method.
    auto def = cast(TypeInfo_Typedef) type;
    if (def !is null)
    {
        return def.base;
    }
    return type;
}

/// If the given type represents a class, return its ClassInfo; else return null;
ConstClassInfo asClass (in TypeInfo type)
{
    if (isInterface (type))
    {
        auto klass = cast(TypeInfo_Interface) type;
        return klass.info;
    }
    if (isClass (type))
    {
        auto klass = cast(TypeInfo_Class) type;
        return klass.info;
    }
    return null;
}

/** Returns true iff one type is an ancestor of the other, or if the types are the same.
 * If either is null, returns false. */
bool isDerived (in ClassInfo derived, in ClassInfo base)
{
    if (derived is null || base is null)
        return false;
    ConstClassInfo* pderived = &derived;
    do
        if (*pderived is base)
            return true;
    while ((pderived = &derived.base) !is null);
    return false;
}

/** Returns true iff implementor implements the interface described
 * by iface. This is an expensive operation (linear in the number of
 * interfaces and base classes).
 */
bool implements (in ClassInfo implementor, in ClassInfo iface)
{
    foreach (info; applyInterfaces (implementor))
    {
        if (iface is info)
            return true;
    }
    return false;
}

/** Returns true iff an instance of class test is implicitly castable to target.
 * This is an expensive operation (isDerived + implements). */
bool isImplicitly (in ClassInfo test, in ClassInfo target)
{
    // Keep isDerived first.
    // isDerived will be much faster than implements.
    return (isDerived (test, target) || implements (test, target));
}

/** Returns true iff an instance of type test is implicitly castable to target.
 * If the types describe classes or interfaces, this is an expensive operation. */
bool isImplicitly (in TypeInfo test, in TypeInfo target)
{
    // A lot of special cases. This is ugly.
    if (test is target)
        return true;
    if (isStaticArray (test) && isDynamicArray (target) && valueType (test) is valueType (target))
    {
        // you can implicitly cast static to dynamic (currently) if they
        // have the same value type. Other casts should be forbidden.
        return true;
    }
    auto klass1 = asClass (test);
    auto klass2 = asClass (target);
    if (isClass (test) && isClass (target))
    {
        return isDerived (klass1, klass2);
    }
    if (isInterface (test) && isInterface (target))
    {
        return isDerived (klass1, klass2);
    }
    if (klass1 && klass2)
    {
        return isImplicitly (klass1, klass2);
    }
    if (klass1 || klass2)
    {
        // no casts from class to non-class
        return false;
    }
    if ((isSignedInteger (test) && isSignedInteger (target)) || (isUnsignedInteger (test) && isUnsignedInteger (target)) || (isFloat (
            test) && isFloat (target)) || (isCharacter (test) && isCharacter (target)))
    {
        return test.tsize () <= target.tsize ();
    }
    if (isSignedInteger (test) && isUnsignedInteger (target))
    {
        // potential loss of data
        return false;
    }
    if (isUnsignedInteger (test) && isSignedInteger (target))
    {
        // if the sizes are the same, you could be losing data
        // the upper half of the range wraps around to negatives
        // if the target type is larger, you can safely hold it
        return test.tsize () < target.tsize ();
    }
    // delegates and functions: no can do
    // pointers: no
    // structs: no
    return false;
}

///
ConstClassInfo[] baseClasses (in ClassInfo type)
{
    if (type is null)
        return null;
    ConstClassInfo[] types;
    ConstClassInfo* ptype = &type;
    while ((ptype = &ptype.base) !is null)
        types ~= *ptype;
    return types;
}

/** Returns a list of all interfaces that this type implements, directly
 * or indirectly. This includes base interfaces of types the class implements,
 * and interfaces that base classes implement, and base interfaces of interfaces
 * that base classes implement. This is an expensive operation. */
ConstClassInfo[] baseInterfaces (in ClassInfo type)
{
    if (type is null)
        return null;
    ConstClassInfo[] types = directInterfaces (type);
    ConstClassInfo* ptype = &type;
    while ((ptype = &ptype.base) !is null)
    {
        types ~= interfaceGraph (*ptype);
    }
    return types;
}

/** Returns all the interfaces that this type directly implements, including
 * inherited interfaces. This is an expensive operation.
 *
 * Examples:
 * ---
 * interface I1 {}
 * interface I2 : I1 {}
 * class A : I2 {}
 *
 * auto interfaces = interfaceGraph (A.classinfo);
 * // interfaces = [I1.classinfo, I2.classinfo]
 * ---
 *
 * ---
 * interface I1 {}
 * interface I2 {}
 * class A : I1 {}
 * class B : A, I2 {}
 *
 * auto interfaces = interfaceGraph (B.classinfo);
 * // interfaces = [I2.classinfo]
 * ---
 */
ConstClassInfo[] interfaceGraph (in ClassInfo type)
{
    ConstClassInfo[] info;
    foreach (iface; type.interfaces)
    {
        info ~= iface.classinfo;
        info ~= interfaceGraph (iface.classinfo);
    }
    return info;
}

/** Iterate through all interfaces that type implements, directly or indirectly, including base interfaces. */
struct applyInterfaces
{
    ///
    int opApply (int delegate (ref ConstClassInfo) dg)
    {
        int result = 0;
        ConstClassInfo* ptype = &type;
        for (; *ptype !is null; ptype = &type.base)
        {
            foreach (iface; ptype.interfaces)
            {
                result = dg (iface.classinfo);
                if (result)
                    return result;
                result = applyInterfaces (iface.classinfo).opApply (dg);
                if (result)
                    return result;
            }
        }
        return result;
    }

    ConstClassInfo type;
}

///
ConstClassInfo[] baseTypes (in ClassInfo type)
{
    if (type is null)
        return null;
    return baseClasses (type) ~ baseInterfaces (type);
}

///
version(Tango){
    ModuleInfo moduleOf (in ClassInfo type)
    {
        foreach (modula; ModuleInfo)
            foreach (klass; modula.localClasses)
                if (klass is type)
                    return modula;
        return null;
    }
} else { // Phobos
    ModuleInfo* moduleOf (in ClassInfo type)
    {
        foreach (modula; ModuleInfo)
            foreach (klass; modula.localClasses)
                if (klass is type)
                    return modula;
        return null;
    }
}

/// Returns a list of interfaces that this class directly implements.
ConstClassInfo[] directInterfaces (in ClassInfo type)
{
    ConstClassInfo[] types;
    foreach (iface; type.interfaces)
        types ~= iface.classinfo;
    return types;
}

/** Returns a list of all types that are derived from the given type. This does not
 * count interfaces; that is, if type is an interface, you will only get derived
 * interfaces back. It is an expensive operations. */
ConstClassInfo[] derivedTypes (in ClassInfo type)
{
    ConstClassInfo[] types;
    foreach (modula; ModuleInfo)
        foreach (klass; modula.localClasses)
            if (isDerived (klass, type) && (klass !is type))
                types ~= klass;
    return types;
}

///
bool isDynamicArray (in TypeInfo type)
{
    // This implementation is evil.
    // Array typeinfos are named TypeInfo_A?, and defined individually for each
    // possible type aside from structs. For example, typeinfo for int[] is
    // TypeInfo_Ai; for uint[], TypeInfo_Ak.
    // So any TypeInfo with length 11 and starting with TypeInfo_A is an array
    // type.
    // Also, TypeInfo_Array is an array type.
    auto type2 = realType (type);
    return ((type2.classinfo.name[9] == 'A') && (type2.classinfo.name.length == 11)) || ((cast(TypeInfo_Array) type2) !is null);
}

///
bool isStaticArray (in TypeInfo type)
{
    auto type2 = realType (type);
    return (cast(TypeInfo_StaticArray) type2) !is null;
}

/** Returns true iff the given type is a dynamic or static array (false for associative
 * arrays and non-arrays). */
bool isArray (in TypeInfo type)
{
    auto type2 = realType (type);
    return isDynamicArray (type2) || isStaticArray (type2);
}

///
bool isAssociativeArray (in TypeInfo type)
{
    auto type2 = realType (type);
    return (cast(TypeInfo_AssociativeArray) type2) !is null;
}

///
bool isCharacter (in TypeInfo type)
{
    auto type2 = realType (type);
    return (type2 is typeid(char) || type2 is typeid(wchar) || type2 is typeid(dchar));
}

///
bool isString (in TypeInfo type)
{
    auto type2 = realType (type);
    return isArray (type2) && isCharacter (valueType (type2));
}

///
bool isUnsignedInteger (in TypeInfo type)
{
    auto type2 = realType (type);
    return (type2 is typeid(uint) || type2 is typeid(ulong) || type2 is typeid(ushort) || type2 is typeid(ubyte));
}

///
bool isSignedInteger (in TypeInfo type)
{
    auto type2 = realType (type);
    return (type2 is typeid(int) || type2 is typeid(long) || type2 is typeid(short) || type2 is typeid(byte));
}

///
bool isInteger (in TypeInfo type)
{
    auto type2 = realType (type);
    return isSignedInteger (type2) || isUnsignedInteger (type2);
}

///
bool isBool (in TypeInfo type)
{
    auto type2 = realType (type);
    return (type2 is typeid(bool));
}

///
bool isFloat (in TypeInfo type)
{
    auto type2 = realType (type);
    return (type2 is typeid(float) || type2 is typeid(double) || type2 is typeid(real));
}

///
bool isPrimitive (in TypeInfo type)
{
    auto type2 = realType (type);
    return (isArray (type2) || isAssociativeArray (type2) || isCharacter (type2) || isFloat (type2) || isInteger (type2));
}

/// Returns true iff the given type represents an interface.
bool isInterface (in TypeInfo type)
{
    return (cast(TypeInfo_Interface) type) !is null;
}

///
bool isPointer (in TypeInfo type)
{
    auto type2 = realType (type);
    return (cast(TypeInfo_Pointer) type2) !is null;
}

/// Returns true iff the type represents a class (false for interfaces).
bool isClass (in TypeInfo type)
{
    auto type2 = realType (type);
    return (cast(TypeInfo_Class) type2) !is null;
}

///
bool isStruct (in TypeInfo type)
{
    auto type2 = realType (type);
    return (cast(TypeInfo_Struct) type2) !is null;
}

///
bool isFunction (in TypeInfo type)
{
    auto type2 = realType (type);
    return ((cast(TypeInfo_Function) type2) !is null) || ((cast(TypeInfo_Delegate) type2) !is null);
}

/** Returns true iff the given type is a reference type. */
bool isReferenceType (in TypeInfo type)
{
    return isClass (type) || isPointer (type) || isDynamicArray (type);
}

/** Returns true iff the given type represents a user-defined type.
 * This does not include functions, delegates, aliases, or typedefs. */
bool isUserDefined (in TypeInfo type)
{
    return isClass (type) || isStruct (type);
}

/** Returns true for all value types, false for all reference types.
 * For functions and delegates, returns false (is this the way it should be?). */
bool isValueType (in TypeInfo type)
{
    return !(isDynamicArray (type) || isAssociativeArray (type) || isPointer (type) || isClass (type) || isFunction (
            type));
}

/** The key type of the given type. For an array, size_t; for an associative
 * array T[U], U. */
ConstTypeInfo keyType (in TypeInfo type)
{
    auto type2 = realType (type);
    auto assocArray = cast(TypeInfo_AssociativeArray) type2;
    if (assocArray)
        return assocArray.key;
    if (isArray (type2))
        return typeid(size_t);
    return null;
}

/** The value type of the given type -- given T[] or T[n], T; given T[U],
 * T; given T*, T; anything else, null. */
ConstTypeInfo valueType (in TypeInfo type)
{
    auto type2 = realType (type);
    if (isArray (type2))
        return type2.next;
    auto assocArray = cast(TypeInfo_AssociativeArray) type2;
    if (assocArray)
        return assocArray.value;
    auto pointer = cast(TypeInfo_Pointer) type2;
    if (pointer)
        return pointer.m_next;
    return null;
}

/** If the given type represents a delegate or function, the return type
 * of that function. Otherwise, null. */
ConstTypeInfo returnType (in TypeInfo type)
{
    auto type2 = realType (type);
    auto delegat = cast(TypeInfo_Delegate) type2;
    if (delegat)
        return delegat.next;
    auto func = cast(TypeInfo_Function) type2;
    if (func)
        return func.next;
    return null;
}

debug (UnitTest)
{

    interface I1
    {
    }

    interface I2
    {
    }

    interface I3
    {
    }

    interface I4
    {
    }

    class A
    {
    }

    class B : A, I1
    {
    }

    class C : B, I2, I3
    {
    }

    class D : A, I1
    {
        int foo (int i)
        {
            return i;
        }
    }

    struct S1
    {
    }

    unittest {
        // Struct-related stuff.
        auto type = typeid(S1);
        assert (isStruct (type));
        assert (isValueType (type));
        assert (isUserDefined (type));
        assert (!isClass (type));
        assert (!isPointer (type));
        assert (null is returnType (type));
        assert (!isPrimitive (type));
        assert (valueType (type) is null);
    }

    unittest {
        auto type = A.classinfo;
        assert (baseTypes (type) == [Object.classinfo]);
        assert (baseClasses (type) == [Object.classinfo]);
        assert (baseInterfaces (type).length == 0);
        type = C.classinfo;
        assert (baseClasses (type) == [B.classinfo, A.classinfo, Object.classinfo]);
        assert (baseInterfaces (type) == [I2.classinfo, I3.classinfo, I1.classinfo]);
        assert (baseTypes (type) == [B.classinfo, A.classinfo, Object.classinfo, I2.classinfo, I3.classinfo,
                I1.classinfo]);
    }

    unittest {
        assert (isPointer (typeid(S1*)));
        assert (isArray (typeid(S1[])));
        assert (valueType (typeid(S1*)) is typeid(S1));
        auto d = new D;
        assert (returnType (typeid(typeof(&d.foo))) is typeid(int));
        assert (isFloat (typeid(real)));
        assert (isFloat (typeid(double)));
        assert (isFloat (typeid(float)));
        assert (!isFloat (typeid(creal)));
        assert (!isFloat (typeid(cdouble)));
        assert (!isInteger (typeid(float)));
        assert (!isInteger (typeid(creal)));
        assert (isInteger (typeid(ulong)));
        assert (isInteger (typeid(ubyte)));
        assert (isCharacter (typeid(char)));
        assert (isCharacter (typeid(wchar)));
        assert (isCharacter (typeid(dchar)));
        assert (!isCharacter (typeid(ubyte)));
        assert (isArray (typeid(typeof("hello"))));
        assert (isCharacter (typeid(typeof("hello"[0]))));
        assert (valueType (typeid(typeof("hello"))) is typeid(typeof('h')));
        assert (isString (typeid(typeof("hello"))), typeof("hello").stringof);
        auto staticString = typeid(typeof("hello"d));
        auto dynamicString = typeid(typeof("hello"d[0 .. $]));
        assert (isString (staticString));
        assert (isStaticArray (staticString));
        assert (isDynamicArray (dynamicString), dynamicString.toString () ~ dynamicString.classinfo.name);
        assert (isString (dynamicString));

        auto type = typeid(int[char[]]);
        assert (valueType (type) is typeid(int), valueType (type).toString ());
        assert (keyType (type) is typeid(char[]), keyType (type).toString ());
        void delegate (int) dg = (int i)
        {
        };
        assert (returnType (typeid(typeof(dg))) is typeid(void));
        assert (returnType (typeid(int delegate (int))) is typeid(int));

        assert (!isDynamicArray (typeid(int[4])));
        assert (isStaticArray (typeid(int[4])));
    }

    unittest {
        enum myint : int {
            init = int.init
        }
        assert (typeid(myint) !is null, "null typeid(myint)");
        assert (isInteger (typeid(myint)));
    }

}

