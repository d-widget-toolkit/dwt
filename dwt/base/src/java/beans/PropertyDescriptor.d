module java.beans.PropertyDescriptor;

import java.beans.FeatureDescriptor;

import java.lang.all;
import java.lang.reflect.Method;

class PropertyDescriptor : FeatureDescriptor {
    this(String propertyName, Class beanClass){
        implMissing(__FILE__, __LINE__);
    }

    this(String propertyName, Class beanClass, String getterName, String setterName){
        implMissing(__FILE__, __LINE__);
    }

    this(String propertyName, Method getter, Method setter){
        implMissing(__FILE__, __LINE__);
    }

    override
    equals_t opEquals(Object obj){
        implMissing(__FILE__, __LINE__);
        return 0;
    }

    Class getPropertyEditorClass(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    Class getPropertyType(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    Method getReadMethod(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    Method getWriteMethod(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    bool isBound(){
        implMissing(__FILE__, __LINE__);
        return false;
    }

    bool isConstrained(){
        implMissing(__FILE__, __LINE__);
        return false;
    }

    void setBound(bool bound){
        implMissing(__FILE__, __LINE__);
    }

    void setConstrained(bool constrained){
        implMissing(__FILE__, __LINE__);
    }

    void setPropertyEditorClass(Class propertyEditorClass){
        implMissing(__FILE__, __LINE__);
    }

    void setReadMethod(Method getter){
        implMissing(__FILE__, __LINE__);
    }

    void setWriteMethod(Method setter){
        implMissing(__FILE__, __LINE__);
    }

}

