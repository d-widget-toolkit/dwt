module java.beans.PropertyChangeSupport;

import java.lang.all;
import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeEvent;

version(Tango){
    static import tango.core.Array;
} else { // Phobos

}
class PropertyChangeSupport {
    PropertyChangeListener[][ String ] listeners;
    Object obj;
    this(Object obj){
        this.obj = obj;
    }
    void addPropertyChangeListener(PropertyChangeListener listener){
        addPropertyChangeListener( "", listener );
    }
    void addPropertyChangeListener(String propertyName, PropertyChangeListener listener){
        PropertyChangeListener[] list;
        if( auto l = propertyName in listeners ){
            list = *l;
        }
        list ~= listener;
        version(Tango){
            propertyName = propertyName.dup;
        }
        listeners[ propertyName ] = list;
    }
    void firePropertyChange(String propertyName, bool oldValue, bool newValue){
        firePropertyChange( propertyName, Boolean.valueOf(oldValue), Boolean.valueOf(newValue) );
    }
    void firePropertyChange(String propertyName, int oldValue, int newValue){
        firePropertyChange( propertyName, new Integer(oldValue), new Integer(newValue) );
    }
    void firePropertyChange(String propertyName, Object oldValue, Object newValue){
        PropertyChangeListener[] list;
        if( auto l = propertyName in listeners ){
            list = *l;
        }
        auto evt = new PropertyChangeEvent( obj, propertyName, oldValue, newValue );
        foreach( listener; list ){
            if( listener ){
                listener.propertyChange( evt );
            }
        }
    }
    void removePropertyChangeListener(PropertyChangeListener listener){
        removePropertyChangeListener( "", listener );
    }
    void removePropertyChangeListener(String propertyName, PropertyChangeListener listener){
        if( auto list = propertyName in listeners ){
            version(Tango){
                list.length = tango.core.Array.remove( *list, listener );
            } else {
                implMissing( __FILE__, __LINE__ );
            }
            if( list.length > 0 ){
                version(Tango){
                    propertyName = propertyName.dup;
                }
                listeners[ propertyName ] = *list;
            }
            else{
                listeners.remove( propertyName );
            }
        }
    }
}


