/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module org.eclipse.swt.accessibility.ACC;


/**
 * Class ACC contains all the constants used in defining an
 * Accessible object.
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * 
 * @since 2.0
 */
public class ACC {
    public static const int STATE_NORMAL = 0x00000000;
    public static const int STATE_SELECTED = 0x00000002;
    public static const int STATE_SELECTABLE = 0x00200000;
    public static const int STATE_MULTISELECTABLE = 0x1000000;
    public static const int STATE_FOCUSED = 0x00000004;
    public static const int STATE_FOCUSABLE = 0x00100000;
    public static const int STATE_PRESSED = 0x8;
    public static const int STATE_CHECKED = 0x10;
    public static const int STATE_EXPANDED = 0x200;
    public static const int STATE_COLLAPSED = 0x400;
    public static const int STATE_HOTTRACKED = 0x80;
    public static const int STATE_BUSY = 0x800;
    public static const int STATE_READONLY = 0x40;
    public static const int STATE_INVISIBLE = 0x8000;
    public static const int STATE_OFFSCREEN = 0x10000;
    public static const int STATE_SIZEABLE = 0x20000;
    public static const int STATE_LINKED = 0x400000;

    public static const int ROLE_CLIENT_AREA = 0xa;
    public static const int ROLE_WINDOW = 0x9;
    public static const int ROLE_MENUBAR = 0x2;
    public static const int ROLE_MENU = 0xb;
    public static const int ROLE_MENUITEM = 0xc;
    public static const int ROLE_SEPARATOR = 0x15;
    public static const int ROLE_TOOLTIP = 0xd;
    public static const int ROLE_SCROLLBAR = 0x3;
    public static const int ROLE_DIALOG = 0x12;
    public static const int ROLE_LABEL = 0x29;
    public static const int ROLE_PUSHBUTTON = 0x2b;
    public static const int ROLE_CHECKBUTTON = 0x2c;
    public static const int ROLE_RADIOBUTTON = 0x2d;
    public static const int ROLE_COMBOBOX = 0x2e;
    public static const int ROLE_TEXT = 0x2a;
    public static const int ROLE_TOOLBAR = 0x16;
    public static const int ROLE_LIST = 0x21;
    public static const int ROLE_LISTITEM = 0x22;
    public static const int ROLE_TABLE = 0x18;
    public static const int ROLE_TABLECELL = 0x1d;
    public static const int ROLE_TABLECOLUMNHEADER = 0x19;
    /** @deprecated use ROLE_TABLECOLUMNHEADER */
    public static const int ROLE_TABLECOLUMN = ROLE_TABLECOLUMNHEADER;
    public static const int ROLE_TABLEROWHEADER = 0x1a;
    public static const int ROLE_TREE = 0x23;
    public static const int ROLE_TREEITEM = 0x24;
    public static const int ROLE_TABFOLDER = 0x3c;
    public static const int ROLE_TABITEM = 0x25;
    public static const int ROLE_PROGRESSBAR = 0x30;
    public static const int ROLE_SLIDER = 0x33;
    public static const int ROLE_LINK = 0x1e;

    public static const int CHILDID_SELF = -1;
    public static const int CHILDID_NONE = -2;
    public static const int CHILDID_MULTIPLE = -3;

    public static const int TEXT_INSERT = 0;
    public static const int TEXT_DELETE = 1;
}
