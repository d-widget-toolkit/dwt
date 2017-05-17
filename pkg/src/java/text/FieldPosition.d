module java.text.FieldPosition;

import java.lang.all;
// FIXME see dmd bug 2878
//import java.text.Format;

class FieldPosition {
    //this(java.text.Format.Format.Field attribute){
    //    implMissing(__FILE__, __LINE__);
    //}

    //this(java.text.Format.Format.Field attribute, int fieldID){
    //    implMissing(__FILE__, __LINE__);
    //}

    this(int field){
        implMissing(__FILE__, __LINE__);
    }

    override equals_t opEquals(Object obj){
        implMissing(__FILE__, __LINE__);
        return false;
    }
    int getBeginIndex(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    int getEndIndex(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    int getField(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    //java.text.Format.Format.Field getFieldAttribute(){
    //    implMissing(__FILE__, __LINE__);
    //    return null;
    //}
    override hash_t toHash(){
        implMissingSafe(__FILE__, __LINE__);
        return 0;
    }
    void setBeginIndex(int bi){
        implMissing(__FILE__, __LINE__);
    }
    void setEndIndex(int ei){
        implMissing(__FILE__, __LINE__);
    }
    override
    String toString(){
        implMissing(__FILE__, __LINE__);
        return null;
    }
}

