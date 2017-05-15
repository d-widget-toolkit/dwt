/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.accessibility.AccessibleObject;

import org.eclipse.swt.internal.accessibility.gtk.ATK;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.internal.LONG;
import org.eclipse.swt.accessibility.Accessible;
import org.eclipse.swt.accessibility.AccessibleListener;
import org.eclipse.swt.accessibility.AccessibleControlListener;
import org.eclipse.swt.accessibility.AccessibleTextListener;
import org.eclipse.swt.accessibility.AccessibleEvent;
import org.eclipse.swt.accessibility.AccessibleControlEvent;
import org.eclipse.swt.accessibility.AccessibleTextEvent;
import org.eclipse.swt.accessibility.ACC;
import org.eclipse.swt.accessibility.AccessibleFactory;
import org.eclipse.swt.widgets.Display;
import java.lang.all;
import java.util.Vector;
import java.util.Hashtable;
import java.util.Enumeration;
version(Tango){
    //import tango.text.Util;
} else { // Phobos
}

class AccessibleObject {
    AtkObject* handle;
    int parentType;
    int index = -1, id = ACC.CHILDID_SELF;
    Accessible accessible;
    AccessibleObject parent;
    Hashtable children;
    /*
    * a lightweight object does not correspond to a concrete gtk widget, but
    * to a logical child of a widget (eg.- a CTabItem, which is simply drawn)
    */
    bool isLightweight = false;

    static String actionNamePtr;
    static String descriptionPtr;
    static String keybindingPtr;
    static String namePtr;
    static AccessibleObject[AtkObject*] AccessibleObjects;
    static /*const*/ ptrdiff_t ATK_ACTION_TYPE;
    static /*const*/ ptrdiff_t ATK_COMPONENT_TYPE;
    static /*const*/ ptrdiff_t ATK_HYPERTEXT_TYPE;
    static /*const*/ ptrdiff_t ATK_SELECTION_TYPE;
    static /*const*/ ptrdiff_t ATK_TEXT_TYPE;
    static /*const*/ bool DEBUG;
    static bool static_this_completed = false;

    package static void static_this() {
        if( static_this_completed ) return;
        DEBUG = Display.DEBUG;
        ATK_ACTION_TYPE = ATK.g_type_from_name ("AtkAction");
        ATK_COMPONENT_TYPE = ATK.g_type_from_name ("AtkComponent");
        ATK_HYPERTEXT_TYPE = ATK.g_type_from_name ("AtkHypertext");
        ATK_SELECTION_TYPE = ATK.g_type_from_name ("AtkSelection");
        ATK_TEXT_TYPE = ATK.g_type_from_name ("AtkText");
        static_this_completed = true;
    }

    this (int type, GtkWidget* widget, Accessible accessible, int parentType, bool isLightweight) {
        children = new Hashtable(9);
        handle = cast(AtkObject*)ATK.g_object_new (type, null);
        this.parentType = parentType;
        ATK.atk_object_initialize (handle, widget);
        this.accessible = accessible;
        this.isLightweight = isLightweight;
        AccessibleObjects[handle] = this;
        if (DEBUG) getDwtLogger().info( __FILE__, __LINE__, "new AccessibleObject: {}", handle);
    }

    void addChild (AccessibleObject child) {
        children.put(new LONG(cast(int)child.handle), child);
        child.setParent (this);
    }

    package static extern(C) char* atkAction_get_keybinding (void* obj, int index) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkAction_get_keybinding");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        char* parentResult;
        if (ATK.g_type_is_a (object.parentType, ATK_ACTION_TYPE)) {
            auto superType = cast(AtkActionIface*)ATK.g_type_interface_peek_parent (ATK.ATK_ACTION_GET_IFACE (object.handle));
            AtkActionIface* actionIface = superType;
            if (actionIface.get_keybinding !is null) {
                parentResult = actionIface.get_keybinding( object.handle, index );
            }
        }
        AccessibleListener[] listeners = object.getAccessibleListeners ();
        if (listeners.length is 0) return parentResult;

        AccessibleEvent event = new AccessibleEvent (object);
        event.childID = object.id;
        if (parentResult !is null) {
            String res = fromStringz( parentResult )._idup();
            event.result = res;
        }
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getKeyboardShortcut (event);
        }
        if (event.result is null) return parentResult;
        if (keybindingPtr !is null ) OS.g_free (keybindingPtr.ptr);
        String name = event.result._idup() ~ '\0';
        char* p = cast(char*) OS.g_malloc (name.length);
        keybindingPtr =  p ? cast(String)p[ 0 .. name.length ] : null;
        return cast(char*)keybindingPtr.ptr;
    }

    package static extern(C) char* atkAction_get_name (void* obj, int index) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkAction_get_name");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        char* parentResult;
        if (ATK.g_type_is_a (object.parentType, ATK_ACTION_TYPE)) {
            auto actionIface = cast(AtkActionIface*)ATK.g_type_interface_peek_parent (ATK.ATK_ACTION_GET_IFACE (object.handle));
            if (actionIface.get_name !is null) {
                parentResult = actionIface.get_name( object.handle, index);
            }
        }
        AccessibleControlListener[] listeners = object.getControlListeners ();
        if (listeners.length is 0) return parentResult;

        AccessibleControlEvent event = new AccessibleControlEvent (object);
        event.childID = object.id;
        if (parentResult !is null) {
            auto res = fromStringz( parentResult );
            event.result = res._idup();
        }
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getDefaultAction (event);
        }
        if (event.result is null) return parentResult;
        if (actionNamePtr !is null) OS.g_free (actionNamePtr.ptr);

        String name = event.result._idup() ~ '\0';
        auto p = cast(char*)OS.g_malloc (name.length);
        actionNamePtr =  p ? cast(String)p[ 0 .. name.length ] : null;
        return cast(char*)actionNamePtr.ptr;
    }

    package static extern(C) void atkComponent_get_extents (void* obj, int* x, int* y, int* width, int* height, int coord_type) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkComponent_get_extents");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return;
        *x = 0;
        *y = 0;
        *width = 0;
        *height = 0;
        if (ATK.g_type_is_a (object.parentType, ATK_COMPONENT_TYPE)) {
            auto componentIface = cast(AtkComponentIface*) ATK.g_type_interface_peek_parent (ATK.ATK_COMPONENT_GET_IFACE (object.handle));
            if (componentIface.get_extents !is null) {
                componentIface.get_extents( object.handle, x, y, width, height, coord_type);
            }
        }
        AccessibleControlListener[] listeners = object.getControlListeners ();
        if (listeners.length is 0) return;

        int parentX = *x, parentY = *y;
        int parentWidth = *width, parentHeight = *height;
        AccessibleControlEvent event = new AccessibleControlEvent (object);
        event.childID = object.id;
        event.x = parentX; event.y = parentY;
        event.width = parentWidth; event.height = parentHeight;
        if (coord_type is ATK.ATK_XY_WINDOW) {
            /* translate control -> display, for filling in event to be dispatched */
            auto gtkAccessible = ATK.GTK_ACCESSIBLE (object.handle);
            auto topLevel = ATK.gtk_widget_get_toplevel (gtkAccessible.widget);
            auto window = OS.GTK_WIDGET_WINDOW (topLevel);
            int topWindowX, topWindowY;
            OS.gdk_window_get_origin (window, &topWindowX, &topWindowY);
            event.x += topWindowX;
            event.y += topWindowY;
        }
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getLocation (event);
        }
        if (coord_type is ATK.ATK_XY_WINDOW) {
            /* translate display -> control, for answering to the OS */
            auto gtkAccessible = ATK.GTK_ACCESSIBLE (object.handle);
            auto topLevel = ATK.gtk_widget_get_toplevel (gtkAccessible.widget);
            auto window = OS.GTK_WIDGET_WINDOW (topLevel);
            int topWindowX, topWindowY;
            OS.gdk_window_get_origin (window, &topWindowX, &topWindowY);
            event.x -= topWindowX;
            event.y -= topWindowY;
        }
        *x = event.x;
        *y = event.y;
        *width = event.width;
        *height = event.height;
        //return 0;
    }

    package static extern(C) void atkComponent_get_position (void* obj, int* x, int* y, int coord_type) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkComponent_get_position, object: {} x:{} y:{} coord:{}", atkObject, x, y, coord_type);
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return;
        *x=0;
        *y=0;
        if (ATK.g_type_is_a (object.parentType, ATK_COMPONENT_TYPE)) {
            auto componentIface = cast(AtkComponentIface*)ATK.g_type_interface_peek_parent (ATK.ATK_COMPONENT_GET_IFACE (object.handle));
            if (componentIface.get_extents !is null) {
                componentIface.get_position( object.handle, x, y, coord_type);
            }
        }
        AccessibleControlListener[] listeners = object.getControlListeners ();
        if (listeners.length is 0) return;

        int parentX, parentY;
        parentX = *x;
        parentY = *y;
        AccessibleControlEvent event = new AccessibleControlEvent (object);
        event.childID = object.id;
        event.x = parentX; event.y = parentY;
        if (coord_type is ATK.ATK_XY_WINDOW) {
            /* translate control -> display, for filling in event to be dispatched */
            auto gtkAccessible = ATK.GTK_ACCESSIBLE (object.handle);
            auto topLevel = ATK.gtk_widget_get_toplevel (gtkAccessible.widget);
            auto window = OS.GTK_WIDGET_WINDOW (topLevel);
            int topWindowX, topWindowY;
            OS.gdk_window_get_origin (window, &topWindowX, &topWindowY);
            event.x += topWindowX;
            event.y += topWindowY;
        }
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getLocation (event);
        }
        if (coord_type is ATK.ATK_XY_WINDOW) {
            /* translate display -> control, for answering to the OS */
            auto gtkAccessible = ATK.GTK_ACCESSIBLE (object.handle);
            auto topLevel = ATK.gtk_widget_get_toplevel (gtkAccessible.widget);
            auto window = OS.GTK_WIDGET_WINDOW (topLevel);
            int topWindowX, topWindowY;
            OS.gdk_window_get_origin (window, &topWindowX, &topWindowY);
            event.x -= topWindowX;
            event.y -= topWindowY;
        }
        *x=event.x;
        *y=event.y;
        //return 0;
    }

    //PORTING_FIXME: what about the coord_type? componentIface.get_size( object.handle, width, height, coord_type);
    //package static extern(C) void atkComponent_get_size (void* obj, int* width, int* height, int coord_type) {
    package static extern(C) void atkComponent_get_size (void* obj, int* width, int* height) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkComponent_get_size");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return;
        *width=0;
        *height=0;
        if (ATK.g_type_is_a (object.parentType, ATK_COMPONENT_TYPE)) {
            auto componentIface = cast(AtkComponentIface*)ATK.g_type_interface_peek_parent (ATK.ATK_COMPONENT_GET_IFACE (object.handle));
            if (componentIface.get_extents !is null) {
                //PORTING_FIXME: what about the coord_type? componentIface.get_size( object.handle, width, height, coord_type);
                componentIface.get_size( object.handle, width, height);
            }
        }
        AccessibleControlListener[] listeners = object.getControlListeners ();
        if (listeners.length is 0) return;

        int parentWidth, parentHeight;
        parentWidth= *width;
        parentHeight= *height;
        AccessibleControlEvent event = new AccessibleControlEvent (object);
        event.childID = object.id;
        event.width = parentWidth; event.height = parentHeight;
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getLocation (event);
        }
        *width=event.width;
        *height=event.height;
        //return 0;
    }

    package static extern(C) AtkObject* atkComponent_ref_accessible_at_point (void* obj, int x, int y, int coord_type) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkComponent_ref_accessible_at_point");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        AtkObject* parentResult;
        if (ATK.g_type_is_a (object.parentType, ATK_COMPONENT_TYPE)) {
            auto componentIface = cast(AtkComponentIface*)ATK.g_type_interface_peek_parent (ATK.ATK_COMPONENT_GET_IFACE (object.handle));
            if (componentIface.ref_accessible_at_point !is null) {
                parentResult = componentIface.ref_accessible_at_point( object.handle, x, y, coord_type);
            }
        }
        AccessibleControlListener[] listeners = object.getControlListeners ();
        if (listeners.length is 0) return parentResult;

        AccessibleControlEvent event = new AccessibleControlEvent (object);
        event.childID = object.id;
        event.x = x; event.y = y;
        if (coord_type is ATK.ATK_XY_WINDOW) {
            /* translate control -> display, for filling in the event to be dispatched */
            auto gtkAccessible = ATK.GTK_ACCESSIBLE (object.handle);
            auto topLevel = ATK.gtk_widget_get_toplevel (gtkAccessible.widget);
            auto window = OS.GTK_WIDGET_WINDOW (topLevel);
            int topWindowX, topWindowY;
            OS.gdk_window_get_origin (window, &topWindowX, &topWindowY);
            event.x += topWindowX;
            event.y += topWindowY;
        }
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getChildAtPoint (event);
        }
        if (event.childID is object.id) event.childID = ACC.CHILDID_SELF;
        AccessibleObject accObj = object.getChildByID (event.childID);
        if (accObj !is null) {
            if (parentResult !is null) OS.g_object_unref (parentResult);
            OS.g_object_ref (accObj.handle);
            return accObj.handle;
        }
        return parentResult;
    }

    package static extern(C) AtkHyperlink* atkHypertext_get_link (void* obj, int link_index) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkHypertext_get_link");
        return null;
    }

    package static extern(C) int atkHypertext_get_n_links (void* obj) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkHypertext_get_n_links");
        return 0;   /* read hyperlink's name */
    }

    package static extern(C) int atkHypertext_get_link_index (void* obj, int char_index) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkHypertext_get_link_index");
        return 0;
    }

    package static extern(C) char* atkObject_get_description (AtkObject* atkObject) {
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkObject_get_description");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        char* parentResult;
        auto objectClass = cast(AtkObjectClass*)ATK.g_type_class_peek (object.parentType);
        if (objectClass.get_description !is null) {
            parentResult = objectClass.get_description(object.handle);
        }
        AccessibleListener[] listeners = object.getAccessibleListeners ();
        if (listeners.length is 0) return parentResult;

        AccessibleEvent event = new AccessibleEvent (object);
        event.childID = object.id;
        if (parentResult !is null) {
            event.result = fromStringz( parentResult )._idup();
        }
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getDescription (event);
        }
        if (event.result is null) return parentResult;
        if (descriptionPtr !is null) OS.g_free (descriptionPtr.ptr);

        String name = event.result._idup() ~ '\0';
        char* p = cast(char*)OS.g_malloc (name.length);
        descriptionPtr =  p ? cast(String)p[ 0 .. name.length ] : null;
        return cast(char*)descriptionPtr.ptr;
    }

    package static extern(C) char* atkObject_get_name (AtkObject* atkObject) {
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkObject_get_name: {}", atkObject);
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        char* parentResult;
        auto objectClass = cast(AtkObjectClass*)ATK.g_type_class_peek (object.parentType);
        if (objectClass.get_name !is null) {
            parentResult = objectClass.get_name( object.handle);
        }
        AccessibleListener[] listeners = object.getAccessibleListeners ();
        if (listeners.length is 0) return parentResult;

        AccessibleEvent event = new AccessibleEvent (object);
        event.childID = object.id;
        if (parentResult !is null) {
            event.result = fromStringz( parentResult )._idup();
        }
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getName (event);
        }
        if (event.result is null) return parentResult;
        if (namePtr !is null) OS.g_free (namePtr.ptr);
        String name = event.result._idup() ~ '\0';
        char* p = cast(char*)OS.g_malloc (name.length);
        namePtr =  p ? cast(String)p[ 0 .. name.length ] : null;
        return cast(char*)namePtr.ptr;
    }

    package static extern(C) int atkObject_get_n_children (AtkObject* atkObject) {
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkObject_get_n_children: {}", atkObject);
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return 0;
        int parentResult = 0;
        auto objectClass = cast(AtkObjectClass*)ATK.g_type_class_peek (object.parentType);
        if (objectClass.get_n_children !is null) {
            parentResult = objectClass.get_n_children( object.handle);
        }
        AccessibleControlListener[] listeners = object.getControlListeners ();
        if (listeners.length is 0) return parentResult;

        AccessibleControlEvent event = new AccessibleControlEvent (object);
        event.childID = object.id;
        event.detail = parentResult;
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getChildCount (event);
        }
        return event.detail;
    }

    package static extern(C) int atkObject_get_index_in_parent (AtkObject* atkObject) {
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkObjectCB_get_index_in_parent.  ");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return 0;
        if (object.index !is -1) return object.index;
        auto objectClass = cast(AtkObjectClass*)ATK.g_type_class_peek (object.parentType);
        if (objectClass.get_index_in_parent is null) return 0;
        return objectClass.get_index_in_parent(object. handle);
    }

    package static extern(C) AtkObject* atkObject_get_parent (AtkObject* atkObject) {
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkObject_get_parent: {}", atkObject);
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        if (object.parent !is null) return object.parent.handle;
        auto objectClass = cast(AtkObjectClass*)ATK.g_type_class_peek (object.parentType);
        if (objectClass.get_parent is null) return null;
        return objectClass.get_parent( object.handle);
    }

    package static extern(C) int atkObject_get_role (AtkObject* atkObject) {
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkObject_get_role: {}", atkObject);
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return 0;
        if (object.getAccessibleListeners ().length !is 0) {
            AccessibleControlListener[] listeners = object.getControlListeners ();
            AccessibleControlEvent event = new AccessibleControlEvent (object);
            event.childID = object.id;
            event.detail = -1;
            for (int i = 0; i < listeners.length; i++) {
                listeners [i].getRole (event);
            }
            if (event.detail !is -1) {
                switch (event.detail) {
                    /* Convert from win32 role values to atk role values */
                    case ACC.ROLE_CHECKBUTTON: return ATK.ATK_ROLE_CHECK_BOX;
                    case ACC.ROLE_CLIENT_AREA: return ATK.ATK_ROLE_DRAWING_AREA;
                    case ACC.ROLE_COMBOBOX: return ATK.ATK_ROLE_COMBO_BOX;
                    case ACC.ROLE_DIALOG: return ATK.ATK_ROLE_DIALOG;
                    case ACC.ROLE_LABEL: return ATK.ATK_ROLE_LABEL;
                    case ACC.ROLE_LINK: return ATK.ATK_ROLE_TEXT;
                    case ACC.ROLE_LIST: return ATK.ATK_ROLE_LIST;
                    case ACC.ROLE_LISTITEM: return ATK.ATK_ROLE_LIST_ITEM;
                    case ACC.ROLE_MENU: return ATK.ATK_ROLE_MENU;
                    case ACC.ROLE_MENUBAR: return ATK.ATK_ROLE_MENU_BAR;
                    case ACC.ROLE_MENUITEM: return ATK.ATK_ROLE_MENU_ITEM;
                    case ACC.ROLE_PROGRESSBAR: return ATK.ATK_ROLE_PROGRESS_BAR;
                    case ACC.ROLE_PUSHBUTTON: return ATK.ATK_ROLE_PUSH_BUTTON;
                    case ACC.ROLE_SCROLLBAR: return ATK.ATK_ROLE_SCROLL_BAR;
                    case ACC.ROLE_SEPARATOR: return ATK.ATK_ROLE_SEPARATOR;
                    case ACC.ROLE_SLIDER: return ATK.ATK_ROLE_SLIDER;
                    case ACC.ROLE_TABLE: return ATK.ATK_ROLE_LIST;
                    case ACC.ROLE_TABLECELL: return ATK.ATK_ROLE_LIST_ITEM;
                    case ACC.ROLE_TABLECOLUMNHEADER: return ATK.ATK_ROLE_TABLE_COLUMN_HEADER;
                    case ACC.ROLE_TABLEROWHEADER: return ATK.ATK_ROLE_TABLE_ROW_HEADER;
                    case ACC.ROLE_TABFOLDER: return ATK.ATK_ROLE_PAGE_TAB_LIST;
                    case ACC.ROLE_TABITEM: return ATK.ATK_ROLE_PAGE_TAB;
                    case ACC.ROLE_TEXT: return ATK.ATK_ROLE_TEXT;
                    case ACC.ROLE_TOOLBAR: return ATK.ATK_ROLE_TOOL_BAR;
                    case ACC.ROLE_TOOLTIP: return ATK.ATK_ROLE_TOOL_TIP;
                    case ACC.ROLE_TREE: return ATK.ATK_ROLE_TREE;
                    case ACC.ROLE_TREEITEM: return ATK.ATK_ROLE_LIST_ITEM;
                    case ACC.ROLE_RADIOBUTTON: return ATK.ATK_ROLE_RADIO_BUTTON;
                    case ACC.ROLE_WINDOW: return ATK.ATK_ROLE_WINDOW;
                    default:
                }
            }
        }
        auto objectClass = cast(AtkObjectClass*)ATK.g_type_class_peek (object.parentType);
        if (objectClass.get_role is null) return 0;
        return objectClass.get_role( object.handle);
    }

    package static extern(C) AtkObject* atkObject_ref_child (AtkObject* atkObject, int index) {
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkObject_ref_child: {} of: {}", index, atkObject);
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        object.updateChildren ();
        AccessibleObject accObject = object.getChildByIndex (index);
        if (accObject !is null) {
            OS.g_object_ref (accObject.handle);
            return accObject.handle;
        }
        auto objectClass = cast(AtkObjectClass*)ATK.g_type_class_peek (object.parentType);
        if (objectClass.ref_child is null) return null;
        return objectClass.ref_child( object.handle, index);
    }

    package static extern(C) AtkStateSet * atkObject_ref_state_set (AtkObject* atkObject) {
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkObject_ref_state_set");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        AtkStateSet* parentResult;
        auto objectClass = cast(AtkObjectClass*)ATK.g_type_class_peek (object.parentType);
        if (objectClass.ref_state_set !is null) {
            parentResult = objectClass.ref_state_set( object.handle);
        }
        AccessibleControlListener[] listeners = object.getControlListeners ();
        if (listeners.length is 0) return parentResult;

        auto set = parentResult;
        AccessibleControlEvent event = new AccessibleControlEvent (object);
        event.childID = object.id;
        event.detail = -1;
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getState (event);
        }
        if (event.detail !is -1) {
            /*  Convert from win32 state values to atk state values */
            int state = event.detail;
            if ((state & ACC.STATE_BUSY) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_BUSY);
            if ((state & ACC.STATE_CHECKED) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_CHECKED);
            if ((state & ACC.STATE_EXPANDED) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_EXPANDED);
            if ((state & ACC.STATE_FOCUSABLE) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_FOCUSABLE);
            if ((state & ACC.STATE_FOCUSED) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_FOCUSED);
            if ((state & ACC.STATE_HOTTRACKED) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_ARMED);
            if ((state & ACC.STATE_INVISIBLE) is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_VISIBLE);
            if ((state & ACC.STATE_MULTISELECTABLE) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_MULTISELECTABLE);
            if ((state & ACC.STATE_OFFSCREEN) is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_SHOWING);
            if ((state & ACC.STATE_PRESSED) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_PRESSED);
            if ((state & ACC.STATE_READONLY) is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_EDITABLE);
            if ((state & ACC.STATE_SELECTABLE) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_SELECTABLE);
            if ((state & ACC.STATE_SELECTED) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_SELECTED);
            if ((state & ACC.STATE_SIZEABLE) !is 0) ATK.atk_state_set_add_state (set, ATK.ATK_STATE_RESIZABLE);
            /* Note: STATE_COLLAPSED, STATE_LINKED and STATE_NORMAL have no ATK equivalents */
        }
        return set;
    }

    package static extern(C) int atkSelection_is_child_selected (void* obj, int index) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkSelection_is_child_selected");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return 0;
        int parentResult = 0;
        if (ATK.g_type_is_a (object.parentType, ATK_SELECTION_TYPE)) {
            auto selectionIface = cast(AtkSelectionIface*)ATK.g_type_interface_peek_parent (ATK.ATK_SELECTION_GET_IFACE (object.handle));
            if (selectionIface.is_child_selected !is null) {
                parentResult = selectionIface.is_child_selected( object.handle, index);
            }
        }
        AccessibleControlListener[] listeners = object.getControlListeners ();
        if (listeners.length is 0) return parentResult;

        AccessibleControlEvent event = new AccessibleControlEvent (object);
        event.childID = object.id;
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getSelection (event);
        }
        AccessibleObject accessibleObject = object.getChildByID (event.childID);
        if (accessibleObject !is null) {
            return accessibleObject.index is index ? 1 : 0;
        }
        return parentResult;
    }

    package static extern(C) AtkObject* atkSelection_ref_selection (void* obj, int index) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkSelection_ref_selection");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        AtkObject* parentResult;
        if (ATK.g_type_is_a (object.parentType, ATK_SELECTION_TYPE)) {
            auto selectionIface = cast(AtkSelectionIface*)ATK.g_type_interface_peek_parent (ATK.ATK_SELECTION_GET_IFACE (object.handle));
            if (selectionIface.ref_selection !is null) {
                parentResult = selectionIface.ref_selection( object.handle, index);
            }
        }
        AccessibleControlListener[] listeners = object.getControlListeners ();
        if (listeners.length is 0) return parentResult;

        AccessibleControlEvent event = new AccessibleControlEvent (object);
        event.childID = object.id;
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getSelection (event);
        }
        AccessibleObject accObj = object.getChildByID (event.childID);
        if (accObj !is null) {
            if (parentResult !is null) OS.g_object_unref (parentResult);
            OS.g_object_ref (accObj.handle);
            return accObj.handle;
        }
        return parentResult;
    }

    package static extern(C) int atkText_get_caret_offset (void* obj) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkText_get_caret_offset");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return 0;
        int parentResult = 0;
        if (ATK.g_type_is_a (object.parentType, ATK_TEXT_TYPE)) {
            auto textIface = cast(AtkTextIface*)ATK.g_type_interface_peek_parent (ATK.ATK_TEXT_GET_IFACE (object.handle));
            if (textIface.get_caret_offset !is null) {
                parentResult = textIface.get_caret_offset( object.handle);
            }
        }
        AccessibleTextListener[] listeners = object.getTextListeners ();
        if (listeners.length is 0) return parentResult;

        AccessibleTextEvent event = new AccessibleTextEvent (object);
        event.childID = object.id;
        event.offset = parentResult;
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getCaretOffset (event);
        }
        return event.offset;
    }

    package static extern(C) uint atkText_get_character_at_offset (void* obj, int offset) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkText_get_character_at_offset");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return 0;
        String text = object.getText ();
        if (text !is null) return text[ offset ]; // TODO
        if (ATK.g_type_is_a (object.parentType, ATK_TEXT_TYPE)) {
            auto textIface = cast(AtkTextIface*)ATK.g_type_class_peek (object.parentType);
            if (textIface.get_character_at_offset !is null) {
                return textIface.get_character_at_offset( object.handle, offset);
            }
        }
        return 0;
    }

    package static extern(C) int atkText_get_character_count (void* obj) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkText_get_character_count");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return 0;
        String text = object.getText ();
        if (text !is null) return cast(int)/*64bit*/text.length;
        if (ATK.g_type_is_a (object.parentType, ATK_TEXT_TYPE)) {
            auto textIface = cast(AtkTextIface*)ATK.g_type_class_peek (object.parentType);
            if (textIface.get_character_count !is null) {
                return textIface.get_character_count( object.handle);
            }
        }
        return 0;
    }

    package static extern(C) int atkText_get_n_selections (void* obj) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info( __FILE__, __LINE__, "-->atkText_get_n_selections");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return 0;
        int parentResult = 0;
        if (ATK.g_type_is_a (object.parentType, ATK_TEXT_TYPE)) {
            auto textIface = cast(AtkTextIface*)ATK.g_type_interface_peek_parent (ATK.ATK_TEXT_GET_IFACE (object.handle));
            if (textIface.get_n_selections !is null) {
                parentResult = textIface.get_n_selections( object.handle);
            }
        }
        AccessibleTextListener[] listeners = object.getTextListeners ();
        if (listeners.length is 0) return parentResult;

        AccessibleTextEvent event = new AccessibleTextEvent (object);
        event.childID = object.id;
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getSelectionRange (event);
        }
        return event.length is 0 ? parentResult : 1;
    }

    package static extern(C) char* atkText_get_selection (void* obj, int selection_num, int* start_offset, int* end_offset) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkText_get_selection");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        *start_offset=0;
        *end_offset=0;
        if (ATK.g_type_is_a (object.parentType, ATK_TEXT_TYPE)) {
            auto textIface = cast(AtkTextIface*)ATK.g_type_interface_peek_parent (ATK.ATK_TEXT_GET_IFACE (object.handle));
            if (textIface.get_selection !is null) {
                textIface.get_selection( object.handle, selection_num, start_offset, end_offset );
            }
        }
        AccessibleTextListener[] listeners = object.getTextListeners ();
        if (listeners.length is 0) return null;

        AccessibleTextEvent event = new AccessibleTextEvent (object);
        event.childID = object.id;
        int parentStart;
        int parentEnd;
        parentStart= *start_offset;
        parentEnd= *end_offset;
        event.offset = parentStart;
        event.length = (parentEnd - parentStart);
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getSelectionRange (event);
        }
        *start_offset = event.offset;
        *end_offset = event.offset + event.length;
        return null;
    }

    package static extern(C) char* atkText_get_text (void* obj, int start_offset, int end_offset) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkText_get_text: {},{}", start_offset, end_offset);
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        String text = object.getText ();
        if (text.length > 0) {
            if (end_offset is -1) {
                end_offset = cast(int)/*64bit*/text.length;
            } else {
                end_offset = cast(int)/*64bit*/Math.min (end_offset, text.length );
            }
            start_offset = Math.min (start_offset, end_offset);
            text = text[ start_offset .. end_offset ];
            auto result = cast(char*)OS.g_malloc (text.length+1);
            result[ 0 .. text.length ] = text;
            result[ text.length ] = '\0';
            return result;
        }
        return null;
    }

    package static extern(C) char* atkText_get_text_after_offset (void* obj, int offset_value, int boundary_type, int* start_offset, int* end_offset) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkText_get_text_after_offset");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        auto offset = offset_value;
        String text = object.getText ();
        if (text.length > 0) {
            int length = cast(int)/*64bit*/text.length ;
            offset = Math.min (offset, length - 1);
            int startBounds = offset;
            int endBounds = offset;
            switch (boundary_type) {
                case ATK.ATK_TEXT_BOUNDARY_CHAR: {
                    if (length > offset) endBounds++;
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_WORD_START: {
                    auto wordStart1 = nextIndexOfChar (text, " !?.\n", offset - 1);
                    if (wordStart1 is -1) {
                        startBounds = endBounds = length;
                        break;
                    }
                    wordStart1 = nextIndexOfNotChar (text, " !?.\n", wordStart1);
                    if (wordStart1 is length) {
                        startBounds = endBounds = length;
                        break;
                    }
                    startBounds = wordStart1;
                    auto wordStart2 = nextIndexOfChar (text, " !?.\n", wordStart1);
                    if (wordStart2 is -1) {
                        endBounds = length;
                        break;
                    }
                    endBounds = nextIndexOfNotChar (text, " !?.\n", wordStart2);
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_WORD_END: {
                    auto previousWordEnd = previousIndexOfNotChar (text, " \n", offset);
                    if (previousWordEnd is -1 || previousWordEnd !is offset - 1) {
                        offset = nextIndexOfNotChar (text, " \n", offset);
                    }
                    if (offset is -1) {
                        startBounds = endBounds = length;
                        break;
                    }
                    auto wordEnd1 = nextIndexOfChar (text, " !?.\n", offset);
                    if (wordEnd1 is -1) {
                        startBounds = endBounds = length;
                        break;
                    }
                    wordEnd1 = nextIndexOfNotChar (text, "!?.", wordEnd1);
                    if (wordEnd1 is length) {
                        startBounds = endBounds = length;
                        break;
                    }
                    startBounds = wordEnd1;
                    auto wordEnd2 = nextIndexOfNotChar (text, " \n", wordEnd1);
                    if (wordEnd2 is length) {
                        startBounds = endBounds = length;
                        break;
                    }
                    wordEnd2 = nextIndexOfChar (text, " !?.\n", wordEnd2);
                    if (wordEnd2 is -1) {
                        endBounds = length;
                        break;
                    }
                    endBounds = nextIndexOfNotChar (text, "!?.", wordEnd2);
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_SENTENCE_START: {
                    auto previousSentenceEnd = previousIndexOfChar (text, "!?.", offset);
                    auto previousText = previousIndexOfNotChar (text, " !?.\n", offset);
                    auto sentenceStart1 = 0;
                    if (previousSentenceEnd >= previousText) {
                        sentenceStart1 = nextIndexOfNotChar (text, " !?.\n", offset);
                    } else {
                        sentenceStart1 = nextIndexOfChar (text, "!?.", offset);
                        if (sentenceStart1 is -1) {
                            startBounds = endBounds = length;
                            break;
                        }
                        sentenceStart1 = nextIndexOfNotChar (text, " !?.\n", sentenceStart1);
                    }
                    if (sentenceStart1 is length) {
                        startBounds = endBounds = length;
                        break;
                    }
                    startBounds = sentenceStart1;
                    auto sentenceStart2 = nextIndexOfChar (text, "!?.", sentenceStart1);
                    if (sentenceStart2 is -1) {
                        endBounds = length;
                        break;
                    }
                    endBounds = nextIndexOfNotChar (text, " !?.\n", sentenceStart2);
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_SENTENCE_END: {
                    auto sentenceEnd1 = nextIndexOfChar (text, "!?.", offset);
                    if (sentenceEnd1 is -1) {
                        startBounds = endBounds = length;
                        break;
                    }
                    sentenceEnd1 = nextIndexOfNotChar (text, "!?.", sentenceEnd1);
                    if (sentenceEnd1 is length) {
                        startBounds = endBounds = length;
                        break;
                    }
                    startBounds = sentenceEnd1;
                    auto sentenceEnd2 = nextIndexOfNotChar (text, " \n", sentenceEnd1);
                    if (sentenceEnd2 is length) {
                        startBounds = endBounds = length;
                        break;
                    }
                    sentenceEnd2 = nextIndexOfChar (text, "!?.", sentenceEnd2);
                    if (sentenceEnd2 is -1) {
                        endBounds = length;
                        break;
                    }
                    endBounds = nextIndexOfNotChar (text, "!?.", sentenceEnd2);
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_LINE_START: {
                    auto lineStart1 = text.indexOf( '\n' );
                    if (lineStart1 is -1) {
                        startBounds = endBounds = length;
                        break;
                    }
                    lineStart1 = nextIndexOfNotChar (text, "\n", lineStart1);
                    if (lineStart1 is length) {
                        startBounds = endBounds = length;
                        break;
                    }
                    startBounds = lineStart1;
                    auto lineStart2 = text.indexOf( '\n' );
                    if (lineStart2 is -1) {
                        endBounds = length;
                        break;
                    }
                    lineStart2 = nextIndexOfNotChar (text, "\n", lineStart2);
                    endBounds = lineStart2;
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_LINE_END: {
                    auto lineEnd1 = nextIndexOfChar (text, "\n", offset);
                    if (lineEnd1 is -1) {
                        startBounds = endBounds = length;
                        break;
                    }
                    startBounds = lineEnd1;
                    if (startBounds is length) {
                        endBounds = length;
                        break;
                    }
                    auto lineEnd2 = nextIndexOfChar (text, "\n", lineEnd1 + 1);
                    if (lineEnd2 is -1) {
                        endBounds = length;
                        break;
                    }
                    endBounds = lineEnd2;
                    break;
                }
                default:
            }
            *start_offset=startBounds;
            *end_offset=endBounds;
            text = text[startBounds .. endBounds ];
            auto result = cast(char*)OS.g_malloc (text.length+1);
            result[ 0 .. text.length ] = text;
            result[ text.length ] = '\0';
            return result;
        }
        return null;
    }

    package static extern(C) char* atkText_get_text_at_offset (void* obj, int offset_value, int boundary_type, int* start_offset, int* end_offset) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkText_get_text_at_offset: {} start: {} end: {}", offset_value, start_offset, end_offset);
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        auto offset = offset_value;
        String text = object.getText ();
        if (text.length > 0) {
            auto length = text.length;
            offset = cast(int)/*64bit*/Math.min (offset, length - 1);
            auto startBounds = offset;
            auto endBounds = offset;
            switch (boundary_type) {
                case ATK.ATK_TEXT_BOUNDARY_CHAR: {
                    if (length > offset) endBounds++;
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_WORD_START: {
                    auto wordStart1 = previousIndexOfNotChar (text, " !?.\n", offset);
                    if (wordStart1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    wordStart1 = previousIndexOfChar (text, " !?.\n", wordStart1) + 1;
                    if (wordStart1 is -1) {
                        startBounds = 0;
                        break;
                    }
                    startBounds = wordStart1;
                    auto wordStart2 = nextIndexOfChar (text, " !?.\n", wordStart1);
                    endBounds = nextIndexOfNotChar (text, " !?.\n", wordStart2);
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_WORD_END: {
                    auto wordEnd1 = previousIndexOfNotChar (text, "!?.", offset + 1);
                    wordEnd1 = previousIndexOfChar (text, " !?.\n", wordEnd1);
                    wordEnd1 = previousIndexOfNotChar (text, " \n", wordEnd1 + 1);
                    if (wordEnd1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    startBounds = wordEnd1 + 1;
                    auto wordEnd2 = nextIndexOfNotChar (text, " \n", startBounds);
                    if (wordEnd2 is length) {
                        endBounds = startBounds;
                        break;
                    }
                    wordEnd2 = nextIndexOfChar (text, " !?.\n", wordEnd2);
                    if (wordEnd2 is -1) {
                        endBounds = startBounds;
                        break;
                    }
                    endBounds = nextIndexOfNotChar (text, "!?.", wordEnd2);
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_SENTENCE_START: {
                    auto sentenceStart1 = previousIndexOfNotChar (text, " !?.\n", offset + 1);
                    if (sentenceStart1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    sentenceStart1 = previousIndexOfChar (text, "!?.", sentenceStart1) + 1;
                    startBounds = nextIndexOfNotChar (text, " \n", sentenceStart1);
                    auto sentenceStart2 = nextIndexOfChar (text, "!?.", startBounds);
                    endBounds = nextIndexOfNotChar (text, " !?.\n", sentenceStart2);
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_SENTENCE_END: {
                    auto sentenceEnd1 = previousIndexOfNotChar (text, "!?.", offset + 1);
                    sentenceEnd1 = previousIndexOfChar (text, "!?.", sentenceEnd1);
                    sentenceEnd1 = previousIndexOfNotChar (text, " \n", sentenceEnd1 + 1);
                    if (sentenceEnd1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    startBounds = sentenceEnd1 + 1;
                    auto sentenceEnd2 = nextIndexOfNotChar (text, " \n", startBounds);
                    if (sentenceEnd2 is length) {
                        endBounds = startBounds;
                        break;
                    }
                    sentenceEnd2 = nextIndexOfChar (text, "!?.", sentenceEnd2);
                    if (sentenceEnd2 is -1) {
                        endBounds = startBounds;
                        break;
                    }
                    endBounds = nextIndexOfNotChar (text, "!?.", sentenceEnd2);
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_LINE_START: {
                    startBounds = previousIndexOfChar (text, "\n", offset) + 1;
                    auto lineEnd2 = nextIndexOfChar (text, "\n", startBounds);
                    if (lineEnd2 < length) lineEnd2++;
                    endBounds = lineEnd2;
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_LINE_END: {
                    auto lineEnd1 = previousIndexOfChar (text, "\n", offset);
                    if (lineEnd1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    startBounds = lineEnd1;
                    endBounds = nextIndexOfChar (text, "\n", lineEnd1 + 1);
                    break;
                }
                default:
                    break;
            }
            *start_offset=startBounds;
            *end_offset=endBounds;
            text = text[startBounds .. endBounds];
            auto result = cast(char*) OS.g_malloc (text.length+1);
            result[ 0 .. text.length ] = text;
            result[ text.length ] = '\0';
            return result;
        }
        return null;
    }

    package static extern(C) char* atkText_get_text_before_offset (void* obj, int offset_value, int boundary_type, int* start_offset, int* end_offset) {
        auto atkObject = cast(AtkObject*)obj;
        if (DEBUG) getDwtLogger().info (__FILE__, __LINE__, "-->atkText_get_text_before_offset");
        AccessibleObject object = getAccessibleObject (atkObject);
        if (object is null) return null;
        int offset = offset_value;
        String text = object.getText ();
        if (text.length > 0) {
            auto length = text.length;
            offset = cast(int)/*64bit*/Math.min (offset, length - 1);
            auto startBounds = offset;
            auto endBounds = offset;
            switch (boundary_type) {
                case ATK.ATK_TEXT_BOUNDARY_CHAR: {
                    if (length >= offset && offset > 0) startBounds--;
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_WORD_START: {
                    auto wordStart1 = previousIndexOfChar (text, " !?.\n", offset - 1);
                    if (wordStart1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    auto wordStart2 = previousIndexOfNotChar (text, " !?.\n", wordStart1);
                    if (wordStart2 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    endBounds = wordStart1 + 1;
                    startBounds = previousIndexOfChar (text, " !?.\n", wordStart2) + 1;
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_WORD_END: {
                    auto wordEnd1 =previousIndexOfChar (text, " !?.\n", offset);
                    if (wordEnd1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    wordEnd1 = previousIndexOfNotChar (text, " \n", wordEnd1 + 1);
                    if (wordEnd1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    endBounds = wordEnd1 + 1;
                    auto wordEnd2 = previousIndexOfNotChar (text, " !?.\n", endBounds);
                    wordEnd2 = previousIndexOfChar (text, " !?.\n", wordEnd2);
                    if (wordEnd2 is -1) {
                        startBounds = 0;
                        break;
                    }
                    startBounds = previousIndexOfNotChar (text, " \n", wordEnd2 + 1) + 1;
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_SENTENCE_START: {
                    auto sentenceStart1 = previousIndexOfChar (text, "!?.", offset);
                    if (sentenceStart1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    auto sentenceStart2 = previousIndexOfNotChar (text, "!?.", sentenceStart1);
                    if (sentenceStart2 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    endBounds = sentenceStart1 + 1;
                    startBounds = previousIndexOfChar (text, "!?.", sentenceStart2) + 1;
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_SENTENCE_END: {
                    auto sentenceEnd1 = previousIndexOfChar (text, "!?.", offset);
                    if (sentenceEnd1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    sentenceEnd1 = previousIndexOfNotChar (text, " \n", sentenceEnd1 + 1);
                    if (sentenceEnd1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    endBounds = sentenceEnd1 + 1;
                    auto sentenceEnd2 = previousIndexOfNotChar (text, "!?.", endBounds);
                    sentenceEnd2 = previousIndexOfChar (text, "!?.", sentenceEnd2);
                    if (sentenceEnd2 is -1) {
                        startBounds = 0;
                        break;
                    }
                    startBounds = previousIndexOfNotChar (text, " \n", sentenceEnd2 + 1) + 1;
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_LINE_START: {
                    auto lineStart1 = previousIndexOfChar (text, "\n", offset);
                    if (lineStart1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    endBounds = lineStart1 + 1;
                    startBounds = previousIndexOfChar (text, "\n", lineStart1) + 1;
                    break;
                }
                case ATK.ATK_TEXT_BOUNDARY_LINE_END: {
                    auto lineEnd1 = previousIndexOfChar (text, "\n", offset);
                    if (lineEnd1 is -1) {
                        startBounds = endBounds = 0;
                        break;
                    }
                    endBounds = lineEnd1;
                    startBounds = previousIndexOfChar (text, "\n", lineEnd1);
                    if (startBounds is -1) startBounds = 0;
                    break;
                }
                default:
            }
            *start_offset=startBounds;
            *end_offset=endBounds;
            text = text[startBounds .. endBounds];
            auto result = cast(char*)OS.g_malloc (text.length+1);
            result[ 0 .. text.length ] = text;
            result[ text.length ] = '\0';
            return result;
        }
        return null;
    }

    AccessibleListener[] getAccessibleListeners () {
        if (accessible is null) return new AccessibleListener [0];
        AccessibleListener[] result = accessible.getAccessibleListeners ();
        return result !is null ? result : new AccessibleListener [0];
    }

    static AccessibleObject getAccessibleObject (AtkObject* atkObject) {
        return AccessibleObjects[atkObject];
    }

    AccessibleObject getChildByHandle (AtkObject* handle) {
        return cast(AccessibleObject) children.get( new LONG(handle) );
    }

    AccessibleObject getChildByID (int childId) {
        if (childId is ACC.CHILDID_SELF) return this;
        Enumeration elements = children.elements ();
        while (elements.hasMoreElements ()) {
            AccessibleObject object = cast(AccessibleObject) elements.nextElement ();
            if (object.id is childId) return object;
        }
        return null;
    }

    AccessibleObject getChildByIndex (int childIndex) {
        Enumeration elements = children.elements ();
        while (elements.hasMoreElements ()) {
            AccessibleObject object = cast(AccessibleObject) elements.nextElement ();
            if (object.index is childIndex) return object;
        }
        return null;
    }

    AccessibleControlListener[] getControlListeners () {
        if (accessible is null) return new AccessibleControlListener [0];
        AccessibleControlListener[] result = accessible.getControlListeners ();
        return result !is null ? result : new AccessibleControlListener [0];
    }

    String getText () {
        char* parentResult;
        String parentText = ""; //$NON-NLS-1$
        if (ATK.g_type_is_a (parentType, ATK_TEXT_TYPE)) {
            auto textIface = cast(AtkTextIface*)ATK.g_type_interface_peek_parent (ATK.ATK_TEXT_GET_IFACE (handle));
            int characterCount = 0;
            if (textIface.get_character_count !is null) {
                characterCount = textIface.get_character_count( handle);
            }
            if (characterCount > 0 && textIface.get_text !is null) {
                parentResult = textIface.get_text( handle, 0, characterCount);
                if (parentResult !is null) {
                    parentText = fromStringz( parentResult )._idup();
                }
            }
        }
        AccessibleControlListener[] controlListeners = getControlListeners ();
        if (controlListeners.length is 0) return parentText;
        AccessibleControlEvent event = new AccessibleControlEvent (this);
        event.childID = id;
        event.result = parentText;
        for (int i = 0; i < controlListeners.length; i++) {
            controlListeners [i].getValue (event);
        }
        return event.result;
    }

    AccessibleTextListener[] getTextListeners () {
        if (accessible is null) return new AccessibleTextListener [0];
        AccessibleTextListener[] result = accessible.getTextListeners ();
        return result !is null ? result : new AccessibleTextListener [0];
    }

    package static extern(C) void gObjectClass_finalize (GObject* atkObject) {
        auto superType = ATK.g_type_class_peek_parent (ATK.G_OBJECT_GET_CLASS (cast(GTypeInstance*)atkObject));
        auto objectClassStruct = cast(GObjectClass*)ATK.G_OBJECT_CLASS (cast(GTypeClass*)superType);
        objectClassStruct.finalize(atkObject);
        AccessibleObject object = getAccessibleObject (cast(AtkObject*)atkObject);
        if (object !is null) {
            AccessibleObjects.remove (cast(AtkObject*)atkObject);
            object.release ();
        }
    }

    static int nextIndexOfChar (String str, String searchChars, int startIndex) {
        auto result = cast(int)/*64bit*/str.length;
        for (int i = 0; i < searchChars.length; i++) {
            char current = searchChars[i];
            auto index = str.indexOf( current, startIndex );
            if (index !is -1 ) result = Math.min (result, index);
        }
        return result;
    }

    static int nextIndexOfNotChar (String str, String searchChars, int startIndex) {
        size_t length = str.length;
        auto index = startIndex;
        while (index < length) {
            char current = str[index];
            if ( searchChars.indexOf( current) is -1) break;
            index++;
        }
        return index;
    }

    static int previousIndexOfChar (String str, String searchChars, int startIndex) {
        int result = -1;
        if (startIndex < 0) return result;
        str = str[0 .. startIndex];
        for (int i = 0; i < searchChars.length ; i++) {
            char current = searchChars[i];
            auto index = str.lastIndexOf( current);
            if (index !is -1 ) result = Math.max (result, index);
        }
        return result;
    }

    static int previousIndexOfNotChar (String str, String searchChars, int startIndex) {
        if (startIndex < 0) return -1;
        int index = startIndex - 1;
        while (index >= 0) {
            char current = str[index];
            if ( searchChars.indexOf( current) is -1 ) break;
            index--;
        }
        return index;
    }

    void release () {
        if (DEBUG) getDwtLogger().info( __FILE__, __LINE__, "AccessibleObject.release: {}", handle);
        accessible = null;
        Enumeration elements = children.elements ();
        while (elements.hasMoreElements ()) {
            AccessibleObject child = cast(AccessibleObject) elements.nextElement ();
            if (child.isLightweight) OS.g_object_unref (child.handle);
        }
        if (parent !is null) parent.removeChild (this, false);
    }

    void removeChild (AccessibleObject child, bool unref) {
        children.remove (new LONG (child.handle));
        if (unref && child.isLightweight) OS.g_object_unref (child.handle);
    }

    void selectionChanged () {
        OS.g_signal_emit_by_name0 (handle, ATK.selection_changed.ptr);
    }

    void setFocus (int childID) {
        updateChildren ();
        AccessibleObject accObject = getChildByID (childID);
        if (accObject !is null) {
            ATK.atk_focus_tracker_notify (accObject.handle);
        }
    }

    void setParent (AccessibleObject parent) {
        this.parent = parent;
    }

    void textCaretMoved(int index) {
        OS.g_signal_emit_by_name1 (handle, ATK.text_caret_moved.ptr, index);
    }

    void textChanged(int type, int startIndex, int length) {
        if (type is ACC.TEXT_DELETE) {
            OS.g_signal_emit_by_name2 (handle, ATK.text_changed_delete.ptr, startIndex, length);
        } else {
            OS.g_signal_emit_by_name2 (handle, ATK.text_changed_insert.ptr, startIndex, length);
        }
    }

    void textSelectionChanged() {
        OS.g_signal_emit_by_name0 (handle, ATK.text_selection_changed.ptr);
    }

    void updateChildren () {
        if (isLightweight) return;
        AccessibleControlListener[] listeners = getControlListeners ();
        if (listeners.length is 0) return;

        AccessibleControlEvent event = new AccessibleControlEvent (this);
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getChildren (event);
        }
        if (event.children !is null && event.children.length > 0) {
            Vector idsToKeep = new Vector (children.size ());
            if ( null !is cast(Integer)event.children [0]) {
                /*  an array of child id's (Integers) was answered */
                int parentType = AccessibleFactory.getDefaultParentType ();
                for (int i = 0; i < event.children.length; i++) {
                    AccessibleObject object = getChildByIndex (i);
                    if (object is null) {
                        int childType = AccessibleFactory.getChildType (accessible, i);
                        object = new AccessibleObject (childType, null, accessible, parentType, true);
                        AccessibleObjects[object.handle] = object;
                        addChild (object);
                        object.index = i;
                    }
                    try {
                        object.id = (cast(Integer)event.children[i]).intValue ();
                    } catch (ClassCastException e) {
                        /* a non-ID value was given so don't set the ID */
                    }
                    idsToKeep.addElement (new LONG (object.handle));
                }
            } else {
                /* an array of Accessible children was answered */
                int childIndex = 0;
                for (int i = 0; i < event.children.length; i++) {
                    AccessibleObject object = null;
                    try {
                        object = (cast(Accessible)event.children [i]).accessibleObject;
                    } catch (ClassCastException e) {
                        /* a non-Accessible value was given so nothing to do here */ 
                    }
                    if (object !is null) {
                        object.index = childIndex++;
                        idsToKeep.addElement (new LONG (object.handle));
                    }
                }
            }
            /* remove old children that were not provided as children anymore */
            Enumeration ids = children.keys ();
            while (ids.hasMoreElements ()) {
                LONG id = cast(LONG)ids.nextElement ();
                if (!idsToKeep.contains (id)) {
                    AccessibleObject object = cast(AccessibleObject) children.get (id);
                    removeChild (object, true);
                }
            }
//            AtkObject*[] idsToKeep = new AtkObject*[]( children.length );
//            idsToKeep.length = 0;
//            if ( null !is (cast(Integer)event.children[0] )) {
//                /*  an array of child id's (Integers) was answered */
//                auto parentType = AccessibleFactory.getDefaultParentType ();
//                for (int i = 0; i < event.children.length; i++) {
//                    AccessibleObject object = getChildByIndex (i);
//                    if (object is null) {
//                        auto childType = AccessibleFactory.getChildType (accessible, i);
//                        object = new AccessibleObject (childType, null, accessible, parentType, true);
//                        AccessibleObjects[object.handle] = object;
//                        addChild (object);
//                        object.index = i;
//                    }
//                    if( auto intChild = cast(Integer)event.children[i] ){
//                        object.id = intChild.intValue ();
//                    }
//                    else {
//                        /* a non-ID value was given so don't set the ID */
//                    }
//                    idsToKeep ~= object.handle;
//                }
//            } else {
//                /* an array of Accessible children was answered */
//                int childIndex = 0;
//                for (int i = 0; i < event.children.length; i++) {
//                    AccessibleObject object = null;
//                    if( auto accChild = cast(Accessible)event.children[i] ){
//                        object = accChild.accessibleObject;
//                    } else {
//                        /* a non-Accessible value was given so nothing to do here */
//                    }
//                    if (object !is null) {
//                        object.index = childIndex++;
//                        idsToKeep ~= object.handle;
//                    }
//                }
//            }
//            /* remove old children that were not provided as children anymore */
//            foreach( id; children.keys ){
//                if ( !tango.core.Array.contains( idsToKeep, id )) {
//                    AccessibleObject object = cast(AccessibleObject) children[id];
//                    removeChild (object, true);
//                }
//            }
        }
    }
}
