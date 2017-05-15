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
module org.eclipse.swt.dnd.Clipboard;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;
import org.eclipse.swt.dnd.ClipboardProxy;

import java.lang.all;

import java.lang.Thread;
version(Tango){
static import tango.stdc.string;
} else { // Phobos
}

/**
 * The <code>Clipboard</code> provides a mechanism for transferring data from one
 * application to another or within an application.
 *
 * <p>IMPORTANT: This class is <em>not</em> intended to be subclassed.</p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#clipboard">Clipboard snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ClipboardExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Clipboard {

    private Display display;

    static void* GTKCLIPBOARD;
    static void* GTKPRIMARYCLIPBOARD;
    private static void* TARGET;
    private static bool static_this_completed = false;
    private static void static_this(){
        if( !static_this_completed ){
            GTKCLIPBOARD = OS.gtk_clipboard_get( cast(void*)OS.GDK_NONE);
            auto primary = OS.gdk_atom_intern("PRIMARY".ptr, false);
            GTKPRIMARYCLIPBOARD = OS.gtk_clipboard_get(primary);
            TARGET = OS.gdk_atom_intern("TARGETS".ptr, false);
            static_this_completed = true;
        }
    }

/**
 * Constructs a new instance of this class.  Creating an instance of a Clipboard
 * may cause system resources to be allocated depending on the platform.  It is therefore
 * mandatory that the Clipboard instance be disposed when no longer required.
 *
 * @param display the display on which to allocate the clipboard
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see Clipboard#dispose
 * @see Clipboard#checkSubclass
 */
public this(Display display) {
    checkSubclass ();
    static_this();
    if (display is null) {
        display = Display.getCurrent();
        if (display is null) {
            display = Display.getDefault();
        }
    }
    if (display.getThread() !is Thread.currentThread()) {
        DND.error(SWT.ERROR_THREAD_INVALID_ACCESS);
    }
    this.display = display;
}

/**
 * Checks that this class can be subclassed.
 * <p>
 * The SWT class library is intended to be subclassed
 * only at specific, controlled points. This method enforces this
 * rule unless it is overridden.
 * </p><p>
 * <em>IMPORTANT:</em> By providing an implementation of this
 * method that allows a subclass of a class which does not
 * normally allow subclassing to be created, the implementer
 * agrees to be fully responsible for the fact that any such
 * subclass will likely fail between SWT releases and will be
 * strongly platform specific. No support is provided for
 * user-written classes which are implemented in this fashion.
 * </p><p>
 * The ability to subclass outside of the allowed SWT classes
 * is intended purely to enable those not on the SWT development
 * team to implement patches in order to get around specific
 * limitations in advance of when those limitations can be
 * addressed by the team. Subclassing should not be attempted
 * without an intimate and detailed understanding of the hierarchy.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
protected void checkSubclass () {
    String name = this.classinfo.name;
    String validName = Clipboard.classinfo.name;
    if ( validName !=/*eq*/ name ) {
        DND.error (SWT.ERROR_INVALID_SUBCLASS);
    }
}
/**
 * Throws an <code>SWTException</code> if the receiver can not
 * be accessed by the caller. This may include both checks on
 * the state of the receiver and more generally on the entire
 * execution context. This method <em>should</em> be called by
 * widget implementors to enforce the standard SWT invariants.
 * <p>
 * Currently, it is an error to invoke any method (other than
 * <code>isDisposed()</code>) on a widget that has had its
 * <code>dispose()</code> method called. It is also an error
 * to call widget methods from any thread that is different
 * from the thread that created the widget.
 * </p><p>
 * In future releases of SWT, there may be more or fewer error
 * checks and exceptions may be thrown for different reasons.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
protected void checkWidget () {
    Display display = this.display;
    if (display is null) DND.error (SWT.ERROR_WIDGET_DISPOSED);
    if (display.getThread() !is Thread.currentThread ()) DND.error (SWT.ERROR_THREAD_INVALID_ACCESS);
    if (display.isDisposed()) DND.error(SWT.ERROR_WIDGET_DISPOSED);
}

/**
 * If this clipboard is currently the owner of the data on the system clipboard,
 * clear the contents.  If this clipboard is not the owner, then nothing is done.
 * Note that there are clipboard assistant applications that take ownership of
 * data or make copies of data when it is placed on the clipboard.  In these
 * cases, it may not be possible to clear the clipboard.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void clearContents() {
    clearContents(DND.CLIPBOARD);
}

/**
 * If this clipboard is currently the owner of the data on the specified
 * clipboard, clear the contents.  If this clipboard is not the owner, then
 * nothing is done.
 *
 * <p>Note that there are clipboard assistant applications that take ownership
 * of data or make copies of data when it is placed on the clipboard.  In these
 * cases, it may not be possible to clear the clipboard.</p>
 *
 * <p>The clipboards value is either one of the clipboard constants defined in
 * class <code>DND</code>, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DND</code> clipboard constants.</p>
 *
 * @param clipboards to be cleared
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DND#CLIPBOARD
 * @see DND#SELECTION_CLIPBOARD
 *
 * @since 3.1
 */
public void clearContents(int clipboards) {
    checkWidget();
    ClipboardProxy proxy = ClipboardProxy._getInstance(display);
    proxy.clear(this, clipboards);
}

/**
 * Disposes of the operating system resources associated with the clipboard.
 * The data will still be available on the system clipboard after the dispose
 * method is called.
 *
 * <p>NOTE: On some platforms the data will not be available once the application
 * has exited or the display has been disposed.</p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 */
public void dispose () {
    if (isDisposed()) return;
    if (display.getThread() !is Thread.currentThread()) DND.error(SWT.ERROR_THREAD_INVALID_ACCESS);
    display = null;
}

/**
 * Retrieve the data of the specified type currently available on the system
 * clipboard.  Refer to the specific subclass of <code>Transfer</code> to
 * determine the type of object returned.
 *
 * <p>The following snippet shows text and RTF text being retrieved from the
 * clipboard:</p>
 *
 *    <code><pre>
 *    Clipboard clipboard = new Clipboard(display);
 *    TextTransfer textTransfer = TextTransfer.getInstance();
 *    String textData = (String)clipboard.getContents(textTransfer);
 *    if (textData !is null) System.out.println("Text is "+textData);
 *    RTFTransfer rtfTransfer = RTFTransfer.getInstance();
 *    String rtfData = (String)clipboard.getContents(rtfTransfer);
 *    if (rtfData !is null) System.out.println("RTF Text is "+rtfData);
 *    clipboard.dispose();
 *    </code></pre>
 *
 * @param transfer the transfer agent for the type of data being requested
 * @return the data obtained from the clipboard or null if no data of this type is available
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if transfer is null</li>
 * </ul>
 *
 * @see Transfer
 */
public Object getContents(Transfer transfer) {
    return getContents(transfer, DND.CLIPBOARD);
}

/**
 * Retrieve the data of the specified type currently available on the specified
 * clipboard.  Refer to the specific subclass of <code>Transfer</code> to
 * determine the type of object returned.
 *
 * <p>The following snippet shows text and RTF text being retrieved from the
 * clipboard:</p>
 *
 *    <code><pre>
 *    Clipboard clipboard = new Clipboard(display);
 *    TextTransfer textTransfer = TextTransfer.getInstance();
 *    String textData = (String)clipboard.getContents(textTransfer);
 *    if (textData !is null) System.out.println("Text is "+textData);
 *    RTFTransfer rtfTransfer = RTFTransfer.getInstance();
 *    String rtfData = (String)clipboard.getContents(rtfTransfer, DND.CLIPBOARD);
 *    if (rtfData !is null) System.out.println("RTF Text is "+rtfData);
 *    clipboard.dispose();
 *    </code></pre>
 *
 * <p>The clipboards value is either one of the clipboard constants defined in
 * class <code>DND</code>, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DND</code> clipboard constants.</p>
 *
 * @param transfer the transfer agent for the type of data being requested
 * @param clipboards on which to look for data
 *
 * @return the data obtained from the clipboard or null if no data of this type is available
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if transfer is null</li>
 * </ul>
 *
 * @see Transfer
 * @see DND#CLIPBOARD
 * @see DND#SELECTION_CLIPBOARD
 *
 * @since 3.1
 */
public Object getContents(Transfer transfer, int clipboards) {
    checkWidget();
    if (transfer is null) DND.error(SWT.ERROR_NULL_ARGUMENT);
    GtkSelectionData* selection_data;
    auto typeIds = transfer.getTypeIds();
    for (int i = 0; i < typeIds.length; i++) {
        if ((clipboards & DND.CLIPBOARD) !is 0) {
            selection_data = gtk_clipboard_wait_for_contents(GTKCLIPBOARD, cast(void*)typeIds[i]);
        }
        if (selection_data !is null) break;
        if ((clipboards & DND.SELECTION_CLIPBOARD) !is 0) {
            selection_data = gtk_clipboard_wait_for_contents(GTKPRIMARYCLIPBOARD, cast(void*)typeIds[i]);
        }
    }
    if (selection_data is null) return null;
    GtkSelectionData* gtkSelectionData = selection_data;
    TransferData tdata = new TransferData();
    tdata.type = gtkSelectionData.type;
    tdata.pValue = gtkSelectionData.data;
    tdata.length = gtkSelectionData.length;
    tdata.format = gtkSelectionData.format;
    Object result = transfer.nativeToJava(tdata);
    OS.gtk_selection_data_free(selection_data);
    return result;
}

/**
 * Returns <code>true</code> if the clipboard has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the clipboard.
 * When a clipboard has been disposed, it is an error to
 * invoke any other method using the clipboard.
 * </p>
 *
 * @return <code>true</code> when the widget is disposed and <code>false</code> otherwise
 *
 * @since 3.0
 */
public bool isDisposed () {
    return (display is null);
}

/**
 * Place data of the specified type on the system clipboard.  More than one type
 * of data can be placed on the system clipboard at the same time.  Setting the
 * data clears any previous data from the system clipboard, regardless of type.
 *
 * <p>NOTE: On some platforms, the data is immediately copied to the system
 * clipboard but on other platforms it is provided upon request.  As a result,
 * if the application modifies the data object it has set on the clipboard, that
 * modification may or may not be available when the data is subsequently
 * requested.</p>
 *
 * <p>The following snippet shows text and RTF text being set on the copy/paste
 * clipboard:
 * </p>
 *
 * <code><pre>
 *  Clipboard clipboard = new Clipboard(display);
 *  String textData = "Hello World";
 *  String rtfData = "{\\rtf1\\b\\i Hello World}";
 *  TextTransfer textTransfer = TextTransfer.getInstance();
 *  RTFTransfer rtfTransfer = RTFTransfer.getInstance();
 *  Transfer[] transfers = new Transfer[]{textTransfer, rtfTransfer};
 *  Object[] data = new Object[]{textData, rtfData};
 *  clipboard.setContents(data, transfers);
 *  clipboard.dispose();
 * </code></pre>
 *
 * @param data the data to be set in the clipboard
 * @param dataTypes the transfer agents that will convert the data to its
 * platform specific format; each entry in the data array must have a
 * corresponding dataType
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if data is null or datatypes is null
 *          or the length of data is not the same as the length of dataTypes</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *  @exception SWTError <ul>
 *    <li>ERROR_CANNOT_SET_CLIPBOARD - if the clipboard is locked or otherwise unavailable</li>
 * </ul>
 *
 * <p>NOTE: ERROR_CANNOT_SET_CLIPBOARD should be an SWTException, since it is a
 * recoverable error, but can not be changed due to backward compatibility.</p>
 */
public void setContents(Object[] data, Transfer[] dataTypes) {
    setContents(data, dataTypes, DND.CLIPBOARD);
}

/**
 * Place data of the specified type on the specified clipboard.  More than one
 * type of data can be placed on the specified clipboard at the same time.
 * Setting the data clears any previous data from the specified
 * clipboard, regardless of type.
 *
 * <p>NOTE: On some platforms, the data is immediately copied to the specified
 * clipboard but on other platforms it is provided upon request.  As a result,
 * if the application modifies the data object it has set on the clipboard, that
 * modification may or may not be available when the data is subsequently
 * requested.</p>
 *
 * <p>The clipboards value is either one of the clipboard constants defined in
 * class <code>DND</code>, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DND</code> clipboard constants.</p>
 *
 * <p>The following snippet shows text and RTF text being set on the copy/paste
 * clipboard:
 * </p>
 *
 * <code><pre>
 *  Clipboard clipboard = new Clipboard(display);
 *  String textData = "Hello World";
 *  String rtfData = "{\\rtf1\\b\\i Hello World}";
 *  TextTransfer textTransfer = TextTransfer.getInstance();
 *  RTFTransfer rtfTransfer = RTFTransfer.getInstance();
 *  Transfer[] transfers = new Transfer[]{textTransfer, rtfTransfer};
 *  Object[] data = new Object[]{textData, rtfData};
 *  clipboard.setContents(data, transfers, DND.CLIPBOARD);
 *  clipboard.dispose();
 * </code></pre>
 *
 * @param data the data to be set in the clipboard
 * @param dataTypes the transfer agents that will convert the data to its
 * platform specific format; each entry in the data array must have a
 * corresponding dataType
 * @param clipboards on which to set the data
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if data is null or datatypes is null
 *          or the length of data is not the same as the length of dataTypes</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *  @exception SWTError <ul>
 *    <li>ERROR_CANNOT_SET_CLIPBOARD - if the clipboard is locked or otherwise unavailable</li>
 * </ul>
 *
 * <p>NOTE: ERROR_CANNOT_SET_CLIPBOARD should be an SWTException, since it is a
 * recoverable error, but can not be changed due to backward compatibility.</p>
 *
 * @see DND#CLIPBOARD
 * @see DND#SELECTION_CLIPBOARD
 *
 * @since 3.1
 */
public void setContents(Object[] data, Transfer[] dataTypes, int clipboards) {
    checkWidget();
    if (data is null || dataTypes is null || data.length !is dataTypes.length || data.length is 0) {
        DND.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    for (int i = 0; i < data.length; i++) {
        if (data[i] is null || dataTypes[i] is null || !dataTypes[i].validate(data[i])) {
            DND.error(SWT.ERROR_INVALID_ARGUMENT);
        }
    }
    ClipboardProxy proxy = ClipboardProxy._getInstance(display);
    if (!proxy.setData(this, data, dataTypes, clipboards)) {
        DND.error(DND.ERROR_CANNOT_SET_CLIPBOARD);
    }
}

/**
 * Returns an array of the data types currently available on the system
 * clipboard. Use with Transfer.isSupportedType.
 *
 * @return array of data types currently available on the system clipboard
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Transfer#isSupportedType
 *
 * @since 3.0
 */
public TransferData[] getAvailableTypes() {
    return getAvailableTypes(DND.CLIPBOARD);
}

/**
 * Returns an array of the data types currently available on the specified
 * clipboard. Use with Transfer.isSupportedType.
 *
 * <p>The clipboards value is either one of the clipboard constants defined in
 * class <code>DND</code>, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DND</code> clipboard constants.</p>
 *
 * @param clipboards from which to get the data types
 * @return array of data types currently available on the specified clipboard
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Transfer#isSupportedType
 * @see DND#CLIPBOARD
 * @see DND#SELECTION_CLIPBOARD
 *
 * @since 3.1
 */
public TransferData[] getAvailableTypes(int clipboards) {
    checkWidget();
    TransferData[] result = null;
    if ((clipboards & DND.CLIPBOARD) !is 0) {
        auto types = getAvailableClipboardTypes();
        result = new TransferData[types.length];
        for (int i = 0; i < types.length; i++) {
            result[i] = new TransferData();
            result[i].type = types[i];
        }
    }
    if ((clipboards & DND.SELECTION_CLIPBOARD) !is 0) {
        auto types = getAvailablePrimaryTypes();
        size_t offset = 0;
        if (result !is null) {
            TransferData[] newResult = new TransferData[result.length + types.length];
            System.arraycopy(result,0, newResult, 0, result.length);
            offset = result.length;
            result = newResult;
        } else {
            result = new TransferData[types.length];
        }
        for (size_t i = 0; i < types.length; i++) {
            result[offset+i] = new TransferData();
            result[offset+i].type = types[i];
        }
    }
    return result is null ? new TransferData[0] : result;
}

/**
 * Returns a platform specific list of the data types currently available on the
 * system clipboard.
 *
 * <p>Note: <code>getAvailableTypeNames</code> is a utility for writing a Transfer
 * sub-class.  It should NOT be used within an application because it provides
 * platform specific information.</p>
 *
 * @return a platform specific list of the data types currently available on the
 * system clipboard
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String[] getAvailableTypeNames() {
    checkWidget();
    auto types1 = getAvailableClipboardTypes();
    auto types2 = getAvailablePrimaryTypes();
    String[] result = new String[types1.length + types2.length];
    int count = 0;
    for (int i = 0; i < types1.length; i++) {
        auto pName = OS.gdk_atom_name(types1[i]);
        if (pName is null) {
            continue;
        }
        String buffer = fromStringz( pName )._idup();
        OS.g_free (pName);
        result[count++] = "GTKCLIPBOARD "~buffer;
    }
    for (int i = 0; i < types2.length; i++) {
        auto pName = OS.gdk_atom_name(types2[i]);
        if (pName is null) {
            continue;
        }
        String buffer = fromStringz( pName )._idup();
        OS.g_free (pName);
        result[count++] = "GTKPRIMARYCLIPBOARD "~buffer;
    }
    if (count < result.length){
        String[] temp = new String[count];
        System.arraycopy(result, 0, temp, 0, count);
        result = temp;
    }
    return result;
}

private  void*[] getAvailablePrimaryTypes() {
    void*[] types;
    auto selection_data = gtk_clipboard_wait_for_contents(GTKPRIMARYCLIPBOARD, TARGET);
    if (selection_data !is null) {
        try {
            GtkSelectionData* gtkSelectionData = selection_data;
            if (gtkSelectionData.length !is 0) {
                types = cast(void*[])new int[gtkSelectionData.length * 8 / gtkSelectionData.format];
                OS.memmove( cast(void*)types.ptr, gtkSelectionData.data, gtkSelectionData.length );
            }
        } finally {
            OS.gtk_selection_data_free(selection_data);
        }
    }
    return types;
}
private void*[] getAvailableClipboardTypes () {
    void*[] types;
    auto selection_data  = gtk_clipboard_wait_for_contents(GTKCLIPBOARD, TARGET);
    if (selection_data !is null) {
        try {
            GtkSelectionData* gtkSelectionData = selection_data;
            if (gtkSelectionData.length !is 0) {
                types = cast(void*[])new int[gtkSelectionData.length * 8 / gtkSelectionData.format];
                OS.memmove( cast(void*)types, gtkSelectionData.data, gtkSelectionData.length);
            }
        } finally {
            OS.gtk_selection_data_free(selection_data);
        }
    }
    return types;
}

GtkSelectionData* gtk_clipboard_wait_for_contents(void* clipboard, void* target) {
    String key = "org.eclipse.swt.internal.gtk.dispatchEvent";
    Display display = this.display;
    ArrayWrapperInt arr = new ArrayWrapperInt( [ OS.GDK_PROPERTY_NOTIFY, OS.GDK_SELECTION_CLEAR, OS.GDK_SELECTION_REQUEST, OS.GDK_SELECTION_NOTIFY ] );
    display.setData(key, arr );
    GtkSelectionData* selection_data = OS.gtk_clipboard_wait_for_contents(clipboard, target);
    display.setData(key, null);
    return selection_data;
}
}
