/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
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
module org.eclipse.swt.accessibility.AccessibleFactory;

import java.lang.all;


import org.eclipse.swt.internal.accessibility.gtk.ATK;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.accessibility.Accessible;
import org.eclipse.swt.accessibility.ACC;
import org.eclipse.swt.accessibility.AccessibleObject;
import org.eclipse.swt.accessibility.AccessibleControlEvent;
import org.eclipse.swt.accessibility.AccessibleControlListener;

import org.eclipse.swt.SWT;

class AccessibleFactory {
    AtkObjectFactory * handle;
    ptrdiff_t objectParentType;
    char* widgetTypeName;

    //Callback atkObjectFactoryCB_create_accessible;
    //Callback gTypeInfo_base_init_factory;
    Accessible[GtkWidget*] accessibles;

    static size_t[String] Types;
    static AccessibleFactory[size_t] Factories;

    static ptrdiff_t DefaultParentType; //$NON-NLS-1$
    static const String FACTORY_PARENTTYPENAME = "AtkObjectFactory";
    static const String SWT_TYPE_PREFIX = "SWT";
    static const String CHILD_TYPENAME = "Child";
    static const String FACTORY_TYPENAME = "SWTFactory";
    static const int[] actionRoles = [
        ACC.ROLE_CHECKBUTTON, ACC.ROLE_COMBOBOX, ACC.ROLE_LINK,
        ACC.ROLE_MENUITEM, ACC.ROLE_PUSHBUTTON, ACC.ROLE_RADIOBUTTON,
    ];
    static const int[] hypertextRoles = [ACC.ROLE_LINK];
    static const int[] selectionRoles = [
        ACC.ROLE_LIST, ACC.ROLE_TABFOLDER, ACC.ROLE_TABLE, ACC.ROLE_TREE,
    ];
    static const int[] textRoles = [
        ACC.ROLE_COMBOBOX, ACC.ROLE_LINK, ACC.ROLE_LABEL, ACC.ROLE_TEXT,
    ];

    /* AT callbacks*/
    /* interface definitions */
    private static GTypeInfo* ObjectIfaceDefinition;
    private static GInterfaceInfo* ActionIfaceDefinition;
    private static GInterfaceInfo* ComponentIfaceDefinition;
    private static GInterfaceInfo* HypertextIfaceDefinition;
    private static GInterfaceInfo* SelectionIfaceDefinition;
    private static GInterfaceInfo* TextIfaceDefinition;

    private static void static_this(){
        synchronized {
            AccessibleObject.static_this();
            /* Action interface */
            if( ActionIfaceDefinition is null ){
                DefaultParentType = OS.g_type_from_name ("GtkAccessible"); //$NON-NLS-1$
                ActionIfaceDefinition = cast(GInterfaceInfo*)OS.g_malloc (GInterfaceInfo.sizeof);
                ActionIfaceDefinition.interface_init = &AccessibleFactory.initActionIfaceCB;
            }
            /* Component interface */
            if( ComponentIfaceDefinition is null ){
                ComponentIfaceDefinition = cast(GInterfaceInfo*)OS.g_malloc (GInterfaceInfo.sizeof);
                ComponentIfaceDefinition.interface_init = &AccessibleFactory.initComponentIfaceCB;
            }
            /* Hypertext interface */
            if( HypertextIfaceDefinition is null ){
                HypertextIfaceDefinition = cast(GInterfaceInfo*)OS.g_malloc (GInterfaceInfo.sizeof);
                HypertextIfaceDefinition.interface_init = &AccessibleFactory.initHypertextIfaceCB;
            }
            /* Selection interface */
            if( SelectionIfaceDefinition is null ){
                SelectionIfaceDefinition = cast(GInterfaceInfo*)OS.g_malloc (GInterfaceInfo.sizeof);
                SelectionIfaceDefinition.interface_init = &AccessibleFactory.initSelectionIfaceCB;
            }
            /* Text interface */
            if( TextIfaceDefinition is null ){
                TextIfaceDefinition =cast(GInterfaceInfo*) OS.g_malloc (GInterfaceInfo.sizeof);
                TextIfaceDefinition.interface_init = &AccessibleFactory.initTextIfaceCB;
            }
        }
    }

    private this (int widgetType) {
        widgetTypeName = OS.g_type_name (widgetType);
        String factoryName = (FACTORY_TYPENAME ~ fromStringz( widgetTypeName ) ~ '\0')._idup();
        if (OS.g_type_from_name (factoryName.ptr) is 0) {
            /* register the factory */
            auto registry = ATK.atk_get_default_registry ();
            auto previousFactory = ATK.atk_registry_get_factory (registry, widgetType);
            objectParentType = ATK.atk_object_factory_get_accessible_type (previousFactory);
            if (objectParentType is 0) objectParentType = DefaultParentType;
            auto factoryParentType = OS.g_type_from_name (FACTORY_PARENTTYPENAME.ptr);
            auto typeInfo = cast(GTypeInfo*) OS.g_malloc (GTypeInfo.sizeof);
            typeInfo.base_init = &gTypeInfo_base_init_factory;
            typeInfo.class_size = AtkObjectFactoryClass.sizeof;
            typeInfo.instance_size = AtkObjectFactory.sizeof;
            auto swtFactoryType = OS.g_type_register_static (factoryParentType, factoryName.ptr, typeInfo, 0);
            ATK.atk_registry_set_factory_type (registry, widgetType, swtFactoryType);
            handle = ATK.atk_registry_get_factory (registry, widgetType);
        }
    }

    void addAccessible (Accessible accessible) {
        auto controlHandle = accessible.getControlHandle ();
        accessibles[controlHandle] = accessible;
        ATK.atk_object_factory_create_accessible (handle, cast(GObject*)controlHandle);
    }

    private static extern(C) AtkObject* atkObjectFactory_create_accessible (GObject* widget) {
        auto widgetType = OS.G_OBJECT_TYPE ( cast(GTypeInstance*)widget);
        if( auto factory = widgetType in Factories ){
            with( *factory ){
                Accessible accessible = accessibles[ cast(GtkWidget*) widget ];
                if (accessible is null) {
                    /*
                    * we don't care about this control, so create it with the parent's
                    * type so that its accessibility callbacks will not pass though here
                    */
                    auto result = cast(AtkObject*) OS.g_object_new (objectParentType, null);
                    ATK.atk_object_initialize (result, cast(void*)widget);
                    return result;
                }
                /* if an atk object has already been created for this widget then just return it */
                if (accessible.accessibleObject !is null) {
                    return accessible.accessibleObject.handle;
                }
                String buffer = fromStringz( widgetTypeName )._idup();
                int type = getType (buffer, accessible, cast(uint)/*64bit*/objectParentType, ACC.CHILDID_SELF);
                AccessibleObject object = new AccessibleObject (type, cast(GtkWidget*)widget, accessible, cast(uint)/*64bit*/objectParentType, false);
                accessible.accessibleObject = object;
                return object.handle;
            }
        }
        else{
            getDwtLogger().info( __FILE__, __LINE__,  "AccessibleFactory.atkObjectFactoryCB_create_accessible cannot find factory instance" );
            return null;
        }
    }

    static int getChildType (Accessible accessible, int childIndex) {
        return getType (CHILD_TYPENAME, accessible, cast(int)/*64bit*/DefaultParentType, childIndex);
    }

    static int getDefaultParentType () {
        return cast(int)/*64bit*/DefaultParentType;
    }

    static int getType (String widgetTypeName, Accessible accessible, int parentType, int childId) {
        AccessibleControlEvent event = new AccessibleControlEvent (accessible);
        event.childID = childId;
        AccessibleControlListener[] listeners = accessible.getControlListeners ();
        for (int i = 0; i < listeners.length; i++) {
            listeners [i].getRole (event);
        }
        bool action = false, hypertext = false, selection = false, text = false;
        if (event.detail !is 0) {    /* a role was specified */
            for (int i = 0; i < actionRoles.length; i++) {
                if (event.detail is actionRoles [i]) {
                    action = true;
                    break;
                }
            }
            for (int i = 0; i < hypertextRoles.length; i++) {
                if (event.detail is hypertextRoles [i]) {
                    hypertext = true;
                    break;
                }
            }
            for (int i = 0; i < selectionRoles.length; i++) {
                if (event.detail is selectionRoles [i]) {
                    selection = true;
                    break;
                }
            }
            for (int i = 0; i < textRoles.length; i++) {
                if (event.detail is textRoles [i]) {
                    text = true;
                    break;
                }
            }
        } else {
            action = hypertext = selection = text = true;
        }
        String swtTypeName = SWT_TYPE_PREFIX._idup();
        swtTypeName ~= widgetTypeName;
        if (action) swtTypeName ~= "Action"; //$NON-NLS-1$
        if (hypertext) swtTypeName ~= "Hypertext"; //$NON-NLS-1$
        if (selection) swtTypeName ~= "Selection"; //$NON-NLS-1$
        if (text) swtTypeName ~= "Text"; //$NON-NLS-1$

        size_t type = 0;
        if (swtTypeName in Types ) {
            type = Types[swtTypeName];
        } else {
            /* define the type */
            GTypeQuery* query = new GTypeQuery ();
            OS.g_type_query (parentType, query);

            GTypeInfo* typeInfo = new GTypeInfo ();
            typeInfo.base_init = &gTypeInfo_base_init_type;
            typeInfo.class_size = cast(ushort) query.class_size;
            typeInfo.instance_size = cast(ushort) query.instance_size;
            ObjectIfaceDefinition = typeInfo;

            type = OS.g_type_register_static (parentType, toStringz( swtTypeName ), ObjectIfaceDefinition, 0);
            OS.g_type_add_interface_static (type, AccessibleObject.ATK_COMPONENT_TYPE, ComponentIfaceDefinition);
            if (action) OS.g_type_add_interface_static (type, AccessibleObject.ATK_ACTION_TYPE, ActionIfaceDefinition);
            if (hypertext) OS.g_type_add_interface_static (type, AccessibleObject.ATK_HYPERTEXT_TYPE, HypertextIfaceDefinition);
            if (selection) OS.g_type_add_interface_static (type, AccessibleObject.ATK_SELECTION_TYPE, SelectionIfaceDefinition);
            if (text) OS.g_type_add_interface_static (type, AccessibleObject.ATK_TEXT_TYPE, TextIfaceDefinition);
            Types[swtTypeName] = type;
        }
        return cast(int)/*64bit*/type;
    }

    private static extern(C) void gTypeInfo_base_init_factory (void* klass) {
        auto atkObjectFactoryClass = ATK.ATK_OBJECT_FACTORY_CLASS (klass);
        atkObjectFactoryClass.create_accessible = &atkObjectFactory_create_accessible;
    }

    private static extern(C) void gTypeInfo_base_init_type (void* klass) {
        auto objectClass = cast(AtkObjectClass*)klass;
        objectClass.get_name = &AccessibleObject.atkObject_get_name;
        objectClass.get_description = &AccessibleObject.atkObject_get_description;
        objectClass.get_n_children = &AccessibleObject.atkObject_get_n_children;
        objectClass.get_role = &AccessibleObject.atkObject_get_role;
        objectClass.get_parent = &AccessibleObject.atkObject_get_parent;
        objectClass.ref_state_set = &AccessibleObject.atkObject_ref_state_set;
        objectClass.get_index_in_parent = &AccessibleObject.atkObject_get_index_in_parent;
        objectClass.ref_child = &AccessibleObject.atkObject_ref_child;

        GObjectClass* gObjectClass = OS.G_OBJECT_CLASS ( cast(GTypeClass*)klass);
        gObjectClass.finalize = &AccessibleObject.gObjectClass_finalize;
    }

    private static extern(C) void initActionIfaceCB ( void* g_iface, void* iface_data ) {
        auto iface = cast(AtkActionIface*)g_iface;
        iface.get_keybinding =  &AccessibleObject.atkAction_get_keybinding;
        iface.get_name =  &AccessibleObject.atkAction_get_name;
    }

    private static extern(C) void initComponentIfaceCB ( void* g_iface, void* iface_data ) {
        auto iface = cast(AtkComponentIface*)g_iface;
        iface.get_extents = &AccessibleObject.atkComponent_get_extents;
        iface.get_position = &AccessibleObject.atkComponent_get_position;
        iface.get_size = &AccessibleObject.atkComponent_get_size;
        iface.ref_accessible_at_point = &AccessibleObject.atkComponent_ref_accessible_at_point;
    }

    private static extern(C) void initHypertextIfaceCB ( void* g_iface, void* iface_data ) {
        auto iface = cast(AtkHypertextIface*)g_iface;
        iface.get_link = &AccessibleObject.atkHypertext_get_link;
        iface.get_link_index = &AccessibleObject.atkHypertext_get_link_index;
        iface.get_n_links = &AccessibleObject.atkHypertext_get_n_links;
    }

    private static extern(C) void initSelectionIfaceCB ( void* g_iface, void* iface_data ) {
        auto iface = cast(AtkSelectionIface*)g_iface;
        iface.is_child_selected = &AccessibleObject.atkSelection_is_child_selected;
        iface.ref_selection = &AccessibleObject.atkSelection_ref_selection;
    }

    private static extern(C) void initTextIfaceCB ( void* g_iface, void* iface_data ) {
        auto iface = cast(AtkTextIface*)g_iface;
        iface.get_caret_offset = &AccessibleObject.atkText_get_caret_offset;
        iface.get_character_at_offset = &AccessibleObject.atkText_get_character_at_offset;
        iface.get_character_count = &AccessibleObject.atkText_get_character_count;
        iface.get_n_selections = &AccessibleObject.atkText_get_n_selections;
        iface.get_selection = &AccessibleObject.atkText_get_selection;
        iface.get_text = &AccessibleObject.atkText_get_text;
        iface.get_text_after_offset = &AccessibleObject.atkText_get_text_after_offset;
        iface.get_text_at_offset = &AccessibleObject.atkText_get_text_at_offset;
        iface.get_text_before_offset = &AccessibleObject.atkText_get_text_before_offset;
    }

    static void registerAccessible (Accessible accessible) {
        static_this();
        /* If DefaultParentType is 0 then OS accessibility is not active */
        if (DefaultParentType is 0) return;
        auto controlHandle = accessible.getControlHandle ();
        auto widgetType = OS.G_OBJECT_TYPE ( cast(GTypeInstance*)controlHandle);
        AccessibleFactory factory = Factories[widgetType];
        if (factory is null) {
            factory = new AccessibleFactory (cast(int)/*64bit*/widgetType);
            Factories[widgetType] = factory;
        }
        factory.addAccessible (accessible);
    }

    void removeAccessible (Accessible accessible) {
        accessibles.remove (accessible.getControlHandle ());
    }

    static void unregisterAccessible (Accessible accessible) {
        auto controlHandle = accessible.getControlHandle ();
        auto widgetType = OS.G_OBJECT_TYPE (cast(GTypeInstance*)controlHandle);
        if ( auto factory = widgetType in Factories ) {
            factory.removeAccessible (accessible);
        }
    }
}
