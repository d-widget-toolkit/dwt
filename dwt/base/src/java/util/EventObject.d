module java.util.EventObject;

import java.lang.all;

class EventObject {
    protected Object source;

    public this(Object source) {
        if (source is null)
        throw new IllegalArgumentException( "null arg" );
        this.source = source;
    }

    public Object getSource() {
        return source;
    }

    public override String toString() {
        return this.classinfo.name ~ "[source=" ~ source.toString() ~ "]";
    }
}

