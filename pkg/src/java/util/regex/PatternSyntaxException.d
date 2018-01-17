module java.util.regex.PatternSyntaxException;

import java.lang.all;


class PatternSyntaxException : IllegalArgumentException {
    this(String desc, String regex, int index) {
        super(desc);
    }
}

