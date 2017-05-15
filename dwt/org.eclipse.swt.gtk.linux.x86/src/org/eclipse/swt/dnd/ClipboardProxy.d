/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module org.eclipse.swt.dnd.ClipboardProxy;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.Clipboard;
import org.eclipse.swt.dnd.DND;
import org.eclipse.swt.dnd.TransferData;

version(Tango){
static import tango.stdc.string;
} else { // Phobos
}


class ClipboardProxy {
    /* Data is not flushed to the clipboard immediately.
     * This class will remember the data and provide it when requested.
     */
    Object[] clipboardData;
    Transfer[] clipboardDataTypes;
    Object[] primaryClipboardData;
    Transfer[] primaryClipboardDataTypes;

    Display display;
    Clipboard activeClipboard = null;
    Clipboard activePrimaryClipboard = null;

    static String ID = "CLIPBOARD PROXY OBJECT"; //$NON-NLS-1$

static ClipboardProxy _getInstance(Display display) {
    ClipboardProxy proxy = cast(ClipboardProxy) display.getData(ID);
    if (proxy !is null) return proxy;
    proxy = new ClipboardProxy(display);
    display.setData(ID, proxy);
    display.addListener(SWT.Dispose, new class( display ) Listener {
        Display disp;
        this( Display disp ){ this.disp = disp; }
        public void handleEvent(Event event) {
            ClipboardProxy clipbordProxy = cast(ClipboardProxy)disp.getData(ID);
            if (clipbordProxy is null) return;
            disp.setData(ID, null);
            clipbordProxy.dispose();
        }
    });
    return proxy;
}

this(Display display) {
    this.display = display;
}

void clear (Clipboard owner, int clipboards) {
    if ((clipboards & DND.CLIPBOARD) !is 0 && activeClipboard is owner) {
        OS.gtk_clipboard_clear(Clipboard.GTKCLIPBOARD);
    }
    if ((clipboards & DND.SELECTION_CLIPBOARD) !is 0 && activePrimaryClipboard is owner) {
        OS.gtk_clipboard_clear(Clipboard.GTKPRIMARYCLIPBOARD);
    }
}

private static extern(C) void clearFuncFunc(GtkClipboard *clipboard, void* user_data_or_owner){
    auto obj = cast(ClipboardProxy)user_data_or_owner;
    obj.clearFunc( clipboard );
}
void clearFunc(GtkClipboard *clipboard ){
    if (clipboard is Clipboard.GTKCLIPBOARD) {
        activeClipboard = null;
        clipboardData = null;
        clipboardDataTypes = null;
    }
    if (clipboard is Clipboard.GTKPRIMARYCLIPBOARD) {
        activePrimaryClipboard = null;
        primaryClipboardData = null;
        primaryClipboardDataTypes = null;
    }
}

void dispose () {
    if (display is null) return;
    if (activeClipboard !is null) OS.gtk_clipboard_clear(Clipboard.GTKCLIPBOARD);
    if (activePrimaryClipboard !is null) OS.gtk_clipboard_clear(Clipboard.GTKPRIMARYCLIPBOARD);
    display = null;
    clipboardData = null;
    clipboardDataTypes = null;
    primaryClipboardData = null;
    primaryClipboardDataTypes = null;
}

private static extern(C) void getFuncFunc(
    GtkClipboard *clipboard,
    GtkSelectionData *selection_data,
    uint info,
    void* user_data_or_owner)
{
    auto obj = cast(ClipboardProxy)user_data_or_owner;
    obj.getFunc( clipboard, selection_data, info );
}
/**
 * This function provides the data to the clipboard on request.
 * When this clipboard is disposed, the data will no longer be available.
 */
int getFunc(
    GtkClipboard *clipboard,
    GtkSelectionData *selectionData,
    uint info)
{
    if (selectionData is null) return 0;
    TransferData tdata = new TransferData();
    tdata.type = selectionData.target;
    Transfer[] types = (clipboard is Clipboard.GTKCLIPBOARD) ? clipboardDataTypes : primaryClipboardDataTypes;
    ptrdiff_t index = -1;
    for (int i = 0; i < types.length; i++) {
        if (types[i].isSupportedType(tdata)) {
            index = i;
            break;
        }
    }
    if (index is -1) return 0;
    Object[] data = (clipboard is Clipboard.GTKCLIPBOARD) ? clipboardData : primaryClipboardData;
    types[index].javaToNative(data[index], tdata);
    if (tdata.format < 8 || tdata.format % 8 !is 0) {
        return 0;
    }
    OS.gtk_selection_data_set(selectionData, tdata.type, tdata.format, tdata.pValue, tdata.length);
    OS.g_free(tdata.pValue);
    return 1;
}

bool setData(Clipboard owner, Object[] data, Transfer[] dataTypes, int clipboards) { 
    GtkTargetEntry*[] entries;
    GtkTargetEntry* pTargetsList;
    try {
        for (int i = 0; i < dataTypes.length; i++) {
            Transfer transfer = dataTypes[i];
            int[] typeIds = transfer.getTypeIds();
            String[] typeNames = transfer.getTypeNames();
            for (int j = 0; j < typeIds.length; j++) {
                GtkTargetEntry*  entry = new GtkTargetEntry();
                entry.info = typeIds[j];
                char* pName = cast(char*)
                    OS.g_malloc(typeNames[j].length+1);
                pName[ 0 .. typeNames[j].length ] = typeNames[j];
                pName[ typeNames[j].length ] = '\0';
                entry.target = pName;
                GtkTargetEntry*[] tmp = new GtkTargetEntry*[entries.length + 1];
                SimpleType!(GtkTargetEntry*)
                    .arraycopy(entries, 0, tmp, 0, entries.length);
                tmp[entries.length] = entry;
                entries = tmp;
            }
        }

        pTargetsList = cast(GtkTargetEntry*)
            OS.g_malloc(GtkTargetEntry.sizeof * entries.length);
        int offset = 0;
        for (int i = 0; i < entries.length; i++) {
            OS.memmove(pTargetsList + i, entries[i], GtkTargetEntry.sizeof);
            offset += GtkTargetEntry.sizeof;
        }
        if ((clipboards & DND.CLIPBOARD) !is 0) {
            if (activeClipboard !is null) OS.gtk_clipboard_clear(Clipboard.GTKCLIPBOARD);
            clipboardData = data;
            clipboardDataTypes = dataTypes;
            if (!OS.gtk_clipboard_set_with_data(Clipboard.GTKCLIPBOARD,
                        pTargetsList, cast(int)/*64bit*/entries.length, &getFuncFunc,
                        &clearFuncFunc, cast(void*)this )) {
                return false;
            }
            activeClipboard = owner;
        }
        if ((clipboards & DND.SELECTION_CLIPBOARD) !is 0) {
            if (activePrimaryClipboard !is null) OS.gtk_clipboard_clear(Clipboard.GTKPRIMARYCLIPBOARD);
            primaryClipboardData = data;
            primaryClipboardDataTypes = dataTypes;
            if (!OS.gtk_clipboard_set_with_data(Clipboard.GTKPRIMARYCLIPBOARD,
                        pTargetsList, cast(int)/*64bit*/entries.length, &getFuncFunc,
                        &clearFuncFunc, cast(void*)this )) {
                return false;
            }
            activePrimaryClipboard = owner;
        }
    } finally {
        for (int i = 0; i < entries.length; i++) {
            GtkTargetEntry* entry = entries[i];
            if( entry.target !is null) OS.g_free(entry.target);
        }
        if (pTargetsList !is null) OS.g_free(pTargetsList);
    }

    return true;
}
}
