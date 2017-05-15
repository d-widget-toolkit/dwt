module java.text.CharacterIterator;

import java.lang.all;

interface CharacterIterator {
    static const wchar DONE = '\u00FF';
    Object clone();
    char   current();
    char   first();
    int    getBeginIndex();
    int    getEndIndex();
    int    getIndex();
    char   last();
    char   next();
    char   previous();
    char   setIndex(int position);
}


