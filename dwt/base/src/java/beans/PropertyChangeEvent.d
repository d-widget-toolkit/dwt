module java.beans.PropertyChangeEvent;

import java.lang.all;
import java.util.EventObject;

class PropertyChangeEvent : EventObject {
    private String propertyName;
    private Object oldValue;
    private Object newValue;
    private Object propagationId;

    this( Object source, String propertyName, Object oldValue, Object newValue) {
        super( source );
        this.propertyName = propertyName;
        this.oldValue = oldValue;
        this.newValue = newValue;
    }
    Object getNewValue(){
        return newValue;
    }
    Object getOldValue(){
        return oldValue;
    }
    Object getPropagationId(){
        return propagationId;
    }
    String getPropertyName(){
        return propertyName;
    }
    void setPropagationId(Object propagationId){
        this.propagationId = propagationId;
    }
    public override String toString() {
        return this.classinfo.name ~ "[source=" ~ source.toString() ~ "]";
    }
}

