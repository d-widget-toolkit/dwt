/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others. All rights reserved.
 * The contents of this file are made available under the terms
 * of the GNU Lesser General Public License (LGPL) Version 2.1 that
 * accompanies this distribution (lgpl-v21.txt).  The LGPL is also
 * available at http://www.gnu.org/licenses/lgpl.html.  If the version
 * of the LGPL at http://www.gnu.org is different to the version of
 * the LGPL accompanying this distribution and there is any conflict
 * between the two license versions, the terms of the LGPL accompanying
 * this distribution shall govern.
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.internal.accessibility.gtk.ATK;

import java.lang.all;


import org.eclipse.swt.internal.Library;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.internal.c.atk;
import org.eclipse.swt.internal.c.gtk;

version(Tango){
    import tango.core.Traits;
    import tango.core.Tuple;
} else { // Phobos
    import std.traits;
    import std.typetuple;
}

alias org.eclipse.swt.internal.c.atk.AtkObjectFactory AtkObjectFactory;
alias org.eclipse.swt.internal.c.atk.AtkObjectClass AtkObjectClass;
alias org.eclipse.swt.internal.c.atk.AtkActionIface AtkActionIface;
alias org.eclipse.swt.internal.c.atk.AtkComponentIface AtkComponentIface;
alias org.eclipse.swt.internal.c.atk.AtkHypertextIface AtkHypertextIface;
alias org.eclipse.swt.internal.c.atk.AtkSelectionIface AtkSelectionIface;
alias org.eclipse.swt.internal.c.atk.AtkTextIface AtkTextIface;
alias org.eclipse.swt.internal.c.atk.AtkObject AtkObject;
alias org.eclipse.swt.internal.c.atk.AtkStateSet AtkStateSet;
alias org.eclipse.swt.internal.c.atk.AtkObjectFactoryClass AtkObjectFactoryClass;
alias org.eclipse.swt.internal.c.atk.AtkHyperlink AtkHyperlink;

alias org.eclipse.swt.internal.c.gtk.GtkAccessible GtkAccessible;

private AtkActionIface* ATK_ACTION_GET_IFACE( AtkObject* ){
    return null;
}
private AtkComponentIface* ATK_COMPONENT_GET_IFACE( AtkObject* ){
    return null;
}
private AtkObjectFactoryClass* ATK_OBJECT_FACTORY_CLASS( void* ){
    return null;
}
private AtkSelectionIface* ATK_SELECTION_GET_IFACE( AtkObject* ){
    return null;
}
private AtkTextIface* ATK_TEXT_GET_IFACE(AtkObject*){
    return null;
}
private GtkAccessible* GTK_ACCESSIBLE(AtkObject*){
    return null;
}


template NameOfFunc(alias f) {
    // Note: highly dependent on the .stringof formatting
    // the value begins with "& " which is why the first two chars are cut off
    version( LDC ){
        // stringof in LLVMDC is "&foobar"
        const char[] NameOfFunc = (&f).stringof[1 .. $];
    }
    else{
        // stringof in DMD is "& foobar"
        const char[] NameOfFunc = (&f).stringof[2 .. $];
    }
}

template ForwardGtkAtkCFunc( alias cFunc ) {
    version(Tango){
        alias ParameterTupleOf!(cFunc) P;
        alias ReturnTypeOf!(cFunc) R;
        mixin("public static R " ~ NameOfFunc!(cFunc) ~ "( P p ){
            lock.lock();
            scope(exit) lock.unlock();
            return cFunc(p);
        }");
    } else { // Phobos
        alias ParameterTypeTuple!(cFunc) P;
        alias ReturnType!(cFunc) R;
        mixin("public static R " ~ NameOfFunc!(cFunc) ~ "( P p ){
            lock.lock();
            scope(exit) lock.unlock();
            return cFunc(p);
        }");
    }
}
/+
// alternative template implementation, might be more stable
template ForwardGtkOsCFunc(String name) {
  alias typeof(mixin(name)) func;
  alias ParameterTupleOf!(func) Params;
  alias ReturnTypeOf!(func) Ret;
  mixin("public static Ret "~name~"( Params p ) {
    return ."~name~"(p);
  }");
}
+/

public class ATK : OS {

    /** Constants */
    public static const int ATK_RELATION_LABELLED_BY = 4;
    public static const int ATK_ROLE_CHECK_BOX = 7;
    public static const int ATK_ROLE_COMBO_BOX = 11;
    public static const int ATK_ROLE_DIALOG = 16;
    public static const int ATK_ROLE_DRAWING_AREA = 18;
    public static const int ATK_ROLE_WINDOW = 68;
    public static const int ATK_ROLE_LABEL = 28;
    public static const int ATK_ROLE_LIST = 30;
    public static const int ATK_ROLE_LIST_ITEM = 31;
    public static const int ATK_ROLE_MENU = 32;
    public static const int ATK_ROLE_MENU_BAR = 33;
    public static const int ATK_ROLE_MENU_ITEM = 34;
    public static const int ATK_ROLE_PAGE_TAB = 36;
    public static const int ATK_ROLE_PAGE_TAB_LIST = 37;
    public static const int ATK_ROLE_PROGRESS_BAR = 41;
    public static const int ATK_ROLE_PUSH_BUTTON = 42;
    public static const int ATK_ROLE_RADIO_BUTTON = 43;
    public static const int ATK_ROLE_SCROLL_BAR = 47;
    public static const int ATK_ROLE_SEPARATOR = 49;
    public static const int ATK_ROLE_SLIDER = 50;
    public static const int ATK_ROLE_TABLE = 54;
    public static const int ATK_ROLE_TABLE_CELL = 55;
    public static const int ATK_ROLE_TABLE_COLUMN_HEADER = 56;
    public static const int ATK_ROLE_TABLE_ROW_HEADER = 57;
    public static const int ATK_ROLE_TEXT = 60;
    public static const int ATK_ROLE_TOOL_BAR = 62;
    public static const int ATK_ROLE_TOOL_TIP = 63;
    public static const int ATK_ROLE_TREE = 64;
    public static const int ATK_STATE_ARMED = 2;
    public static const int ATK_STATE_BUSY = 3;
    public static const int ATK_STATE_CHECKED = 4;
    public static const int ATK_STATE_DEFUNCT = 5;
    public static const int ATK_STATE_EDITABLE = 6;
    public static const int ATK_STATE_ENABLED = 7;
    public static const int ATK_STATE_EXPANDED = 9;
    public static const int ATK_STATE_FOCUSABLE = 10;
    public static const int ATK_STATE_FOCUSED = 11;
    public static const int ATK_STATE_MULTISELECTABLE = 16;
    public static const int ATK_STATE_PRESSED = 18;
    public static const int ATK_STATE_RESIZABLE = 19;
    public static const int ATK_STATE_SELECTABLE = 20;
    public static const int ATK_STATE_SELECTED = 21;
    public static const int ATK_STATE_SHOWING = 23;
    public static const int ATK_STATE_TRANSIENT = 26;
    public static const int ATK_STATE_VISIBLE = 28;
    public static const int ATK_TEXT_BOUNDARY_CHAR = 0;
    public static const int ATK_TEXT_BOUNDARY_WORD_START = 1;
    public static const int ATK_TEXT_BOUNDARY_WORD_END = 2;
    public static const int ATK_TEXT_BOUNDARY_SENTENCE_START = 3;
    public static const int ATK_TEXT_BOUNDARY_SENTENCE_END = 4;
    public static const int ATK_TEXT_BOUNDARY_LINE_START = 5;
    public static const int ATK_TEXT_BOUNDARY_LINE_END = 6;
    public static const int ATK_XY_WINDOW = 1;

    /** Signals */
    public static const String selection_changed = "selection_changed";
    public static const String text_changed_insert = "text_changed::insert";
    public static const String text_changed_delete = "text_changed::delete";
    public static const String text_caret_moved = "text_caret_moved";
    public static const String text_selection_changed = "text_selection_changed";

    mixin ForwardGtkAtkCFunc!(.ATK_ACTION_GET_IFACE );
    mixin ForwardGtkAtkCFunc!(.ATK_COMPONENT_GET_IFACE);
    mixin ForwardGtkAtkCFunc!(.ATK_OBJECT_FACTORY_CLASS );
    mixin ForwardGtkAtkCFunc!(.ATK_SELECTION_GET_IFACE );
    mixin ForwardGtkAtkCFunc!(.ATK_TEXT_GET_IFACE );
    mixin ForwardGtkAtkCFunc!(.GTK_ACCESSIBLE );
    mixin ForwardGtkAtkCFunc!(.atk_focus_tracker_notify );
    mixin ForwardGtkAtkCFunc!(.atk_get_default_registry );
    mixin ForwardGtkAtkCFunc!(.atk_object_factory_create_accessible );
    mixin ForwardGtkAtkCFunc!(.atk_object_factory_get_accessible_type );
    mixin ForwardGtkAtkCFunc!(.atk_object_initialize );
    mixin ForwardGtkAtkCFunc!(.atk_object_ref_relation_set );
    mixin ForwardGtkAtkCFunc!(.atk_registry_get_factory );
    mixin ForwardGtkAtkCFunc!(.atk_registry_set_factory_type );
    mixin ForwardGtkAtkCFunc!(.atk_relation_set_get_n_relations );
    mixin ForwardGtkAtkCFunc!(.atk_relation_set_get_relation );
    mixin ForwardGtkAtkCFunc!(.atk_relation_set_remove );
    mixin ForwardGtkAtkCFunc!(.atk_state_set_add_state );
    mixin ForwardGtkAtkCFunc!(.atk_state_set_new );

}


