module java.lang.Class;

import java.lang.util;
import java.lang.String;
import java.lang.reflect.Method;
import java.lang.reflect.Field;
import java.lang.reflect.Package;
import java.lang.reflect.Constructor;

class Class {
    bool desiredAssertionStatus(){
        implMissing(__FILE__, __LINE__ );
        return false;
    }
    static Class forName(String className){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    static Class fromType(T)(){
        return null;
    }
    static Class fromObject(T)(T t){
        static assert( is(T==class)||is(T==interface));
        return null;
    }
    //static Class forName(String name, bool initialize, ClassLoader loader){
    //    implMissing(__FILE__, __LINE__ );
    //    return null;
    //}
    Class[] getClasses(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    //ClassLoader getClassLoader(){
    //    implMissing(__FILE__, __LINE__ );
    //    return null;
    //}
    Class getComponentType(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Constructor getConstructor(Class parameterTypes...){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Constructor[] getConstructors(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Class[] getDeclaredClasses(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Constructor getDeclaredConstructor(Class parameterTypes...){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Constructor[] getDeclaredConstructors(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Field getDeclaredField(String name){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Field[] getDeclaredFields(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Method getDeclaredMethod(String name, Class parameterTypes...){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Method[] getDeclaredMethods(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Class getDeclaringClass(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Field getField(String name){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Field[] getFields(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Class[] getInterfaces(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Method getMethod(String name, Class[] parameterTypes...){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Method[] getMethods(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    int getModifiers(){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    String getName(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Package getPackage(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    //ProtectionDomain getProtectionDomain(){
    //    implMissing(__FILE__, __LINE__ );
    //    return null;
    //}
    //URL getResource(String name){
    //    implMissing(__FILE__, __LINE__ );
    //    return null;
    //}
    //InputStream getResourceAsStream(String name){
    //    implMissing(__FILE__, __LINE__ );
    //    return null;
    //}
    //Object[] getSigners(){
    //    implMissing(__FILE__, __LINE__ );
    //    return null;
    //}
    String getSimpleName(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    Class getSuperclass(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    bool isArray(){
        implMissing(__FILE__, __LINE__ );
        return false;
    }
    bool isAssignableFrom(Class cls){
        implMissing(__FILE__, __LINE__ );
        return false;
    }
    bool isInstance(Object obj){
        implMissing(__FILE__, __LINE__ );
        return false;
    }
    bool isInterface(){
        implMissing(__FILE__, __LINE__ );
        return false;
    }
    bool isPrimitive(){
        implMissing(__FILE__, __LINE__ );
        return false;
    }
    Object newInstance(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    override
    String toString(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
}
