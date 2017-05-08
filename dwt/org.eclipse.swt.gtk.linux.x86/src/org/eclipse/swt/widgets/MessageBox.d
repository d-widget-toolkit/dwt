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
module org.eclipse.swt.widgets.MessageBox;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Display;


/**
 * Instances of this class are used to inform or warn the user.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>ICON_ERROR, ICON_INFORMATION, ICON_QUESTION, ICON_WARNING, ICON_WORKING</dd>
 * <dd>OK, OK | CANCEL</dd>
 * <dd>YES | NO, YES | NO | CANCEL</dd>
 * <dd>RETRY | CANCEL</dd>
 * <dd>ABORT | RETRY | IGNORE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles ICON_ERROR, ICON_INFORMATION, ICON_QUESTION,
 * ICON_WARNING and ICON_WORKING may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample, Dialog tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class MessageBox : Dialog {

    alias Dialog.checkStyle checkStyle;

    String message = "";
    GtkWidget* handle;
    private bool allowNullParent = false;
/**
 * Constructs a new instance of this class given only its parent.
 *
 * @param parent a shell which will be the parent of the new instance
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this (Shell parent) {
    this (parent, SWT.OK | SWT.ICON_INFORMATION | SWT.APPLICATION_MODAL);
}

/**
 * Constructs a new instance of this class given its parent
 * and a style value describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>SWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>SWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 *
 * @param parent a shell which will be the parent of the new instance
 * @param style the style of dialog to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this (Shell parent, int style) {
    super (parent, checkStyle (parent, checkStyle (style)));
    checkSubclass ();
}

/++
 + SWT extension, a MessageBox with no parent
 +/
public this (int style) {
    allowNullParent = true;
    super (parent, checkStyle (parent, checkStyle (style)));
    checkSubclass ();
}
// PORT
// actually, the parent can be null
override void checkParent (Shell parent){
    if( !allowNullParent ){
        super.checkParent( parent );
    }
}

/**
 * Returns the dialog's message, or an empty string if it does not have one.
 * The message is a description of the purpose for which the dialog was opened.
 * This message will be visible in the dialog while it is open.
 *
 * @return the message
 */
public String getMessage () {
    return message;
}

/**
 * Sets the dialog's message, which is a description of
 * the purpose for which it was opened. This message will be
 * visible on the dialog while it is open.
 *
 * @param string the message
 *
 */
public void setMessage (String string) {
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    message = string;
}

/**
 * Makes the dialog visible and brings it to the front
 * of the display.
 *
 * @return the ID of the button that was selected to dismiss the
 *         message box (e.g. SWT.OK, SWT.CANCEL, etc.)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the dialog has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the dialog</li>
 * </ul>
 */
public int open () {
    GtkWidget* parentHandle = (parent !is null) ? parent.topHandle() : null;
    int dialogFlags = OS.GTK_DIALOG_DESTROY_WITH_PARENT;
    if ((style & (SWT.PRIMARY_MODAL | SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL)) !is 0) {
        dialogFlags |= OS.GTK_DIALOG_MODAL;
    }
    int messageType = OS.GTK_MESSAGE_INFO;
    if ((style & (SWT.ICON_WARNING)) !is 0)  messageType = OS.GTK_MESSAGE_WARNING;
    if ((style & (SWT.ICON_QUESTION)) !is 0) messageType = OS.GTK_MESSAGE_QUESTION;
    if ((style & (SWT.ICON_ERROR)) !is 0)    messageType = OS.GTK_MESSAGE_ERROR;

    char* buffer = toStringz( fixPercent (message));
    handle = cast(GtkWidget*)OS.gtk_message_dialog_new(parentHandle, dialogFlags, messageType, 0, buffer);
    if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    if (parentHandle !is null) {
        auto pixbufs = OS.gtk_window_get_icon_list (parentHandle);
        if (pixbufs !is null) {
            OS.gtk_window_set_icon_list (handle, pixbufs);
            OS.g_list_free (pixbufs);
        }
    }
    createButtons();
    buffer = toStringz(title);
    OS.gtk_window_set_title(handle,buffer);
    Display display = parent !is null ? parent.getDisplay (): Display.getCurrent ();
    display.addIdleProc ();
    Dialog oldModal = null;
    if (OS.gtk_window_get_modal (handle)) {
        oldModal = display.getModalDialog ();
        display.setModalDialog (this);
    }
    int signalId = 0;
    ptrdiff_t hookId = 0;
    CallbackData emissionData;
    emissionData.display = display;
    emissionData.data = handle;
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        signalId = OS.g_signal_lookup (OS.map.ptr, OS.GTK_TYPE_WIDGET());
        hookId = OS.g_signal_add_emission_hook (signalId, 0, &Display.emissionFunc, &emissionData, null);
    }
    int response = OS.gtk_dialog_run (handle);
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        OS.g_signal_remove_emission_hook (signalId, hookId);
    }
    if (OS.gtk_window_get_modal (handle)) {
        display.setModalDialog (oldModal);
    }
    display.removeIdleProc ();
    OS.gtk_widget_destroy (handle);
    return response;
}

private void createButtons() {
    if ((style & SWT.OK) !is 0) OS.gtk_dialog_add_button(handle, "gtk-ok".ptr, SWT.OK);
    if ((style & SWT.CANCEL) !is 0) OS.gtk_dialog_add_button(handle, "gtk-cancel".ptr, SWT.CANCEL);
    if ((style & SWT.YES) !is 0) OS.gtk_dialog_add_button(handle, "gtk-yes".ptr, SWT.YES);
    if ((style & SWT.NO) !is 0) OS.gtk_dialog_add_button(handle, "gtk-no".ptr, SWT.NO);
    if ((style & SWT.ABORT) !is 0) OS.gtk_dialog_add_button(handle, toStringz( SWT.getMessage("SWT_Abort")), SWT.ABORT);
    if ((style & SWT.RETRY) !is 0) OS.gtk_dialog_add_button(handle, toStringz( SWT.getMessage("SWT_Retry")), SWT.RETRY);
    if ((style & SWT.IGNORE) !is 0) OS.gtk_dialog_add_button(handle, toStringz( SWT.getMessage("SWT_Ignore")), SWT.IGNORE);
}

private static int checkStyle (int style) {
    int mask = (SWT.YES | SWT.NO | SWT.OK | SWT.CANCEL | SWT.ABORT | SWT.RETRY | SWT.IGNORE);
    int bits = style & mask;
    if (bits is SWT.OK || bits is SWT.CANCEL || bits is (SWT.OK | SWT.CANCEL)) return style;
    if (bits is SWT.YES || bits is SWT.NO || bits is (SWT.YES | SWT.NO) || bits is (SWT.YES | SWT.NO | SWT.CANCEL)) return style;
    if (bits is (SWT.RETRY | SWT.CANCEL) || bits is (SWT.ABORT | SWT.RETRY | SWT.IGNORE)) return style;
    style = (style & ~mask) | SWT.OK;
    return style;
}

char[] fixPercent (String string) {
    int i = 0, j = 0;
    char [] result = new char[ string.length * 2 ];
    while (i < string.length) {
        switch (string [i]) {
            case '%':
                result [j++] = '%';
                break;
            default:
        }
        result [j++] = string [i++];
    }
    return result[ 0 .. j ];
}


/++
 + SWT extension
 +/
public static int showMessageBox(String str, String title, Shell shell, int style) {
    MessageBox msgBox = (shell is null ) ? new MessageBox( style ) : new MessageBox(shell, style);
    msgBox.setMessage(str);
    if(title !is null){
        msgBox.setText(title);
    }
    return msgBox.open();
}

/// SWT extension
public static int showInfo(String str, String title = null, Shell shell = null) {
    return showMessageBox( str, title, shell, SWT.OK | SWT.ICON_INFORMATION );
}
/// SWT extension
alias showInfo showInformation;

/// SWT extension
public static int showWarning(String str, String title = null, Shell shell = null) {
    return showMessageBox( str, title, shell, SWT.OK | SWT.ICON_WARNING );
}
/// SWT extension
public static int showError(String str, String title = null, Shell shell = null) {
    return showMessageBox( str, title, shell, SWT.OK | SWT.ICON_ERROR );
}

}
