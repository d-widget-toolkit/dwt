module java.text.MessageFormat;

static import java.lang.util;
import java.lang.all;
import java.text.Format;

class MessageFormat : java.text.Format.Format {
    public static String format( String frmt, Object[] args... ){
        switch( args.length ){
        case 0: return java.lang.util.Format(frmt);
        case 1: return java.lang.util.Format(frmt, args[0]);
        case 2: return java.lang.util.Format(frmt, args[0], args[1]);
        case 3: return java.lang.util.Format(frmt, args[0], args[1], args[2]);
        case 4: return java.lang.util.Format(frmt, args[0], args[1], args[2], args[3]);
        case 5: return java.lang.util.Format(frmt, args[0], args[1], args[2], args[3], args[4]);
        default:
            implMissing(__FILE__, __LINE__ );
            return null;
        }
    }
}

