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
module org.eclipse.swt.printing.PrintDialog;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.LONG;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.printing.Printer;
import org.eclipse.swt.printing.PrinterData;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

/**
 * Instances of this class allow the user to select
 * a printer and various print-related parameters
 * prior to starting a print job.
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#printing">Printing snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample, Dialog tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class PrintDialog : Dialog {
    PrinterData printerData;
    int scope_ = PrinterData.ALL_PAGES;
    int startPage = 1, endPage = 1;
    bool printToFile = false;

    GtkPrintUnixDialog* handle;
    int index;
    char [] settingsData;

    static const String GET_MODAL_DIALOG = "org.eclipse.swt.internal.gtk.getModalDialog";
    static const String SET_MODAL_DIALOG = "org.eclipse.swt.internal.gtk.setModalDialog";
    static const String ADD_IDLE_PROC_KEY = "org.eclipse.swt.internal.gtk.addIdleProc";
    static const String REMOVE_IDLE_PROC_KEY = "org.eclipse.swt.internal.gtk.removeIdleProc";
    static const String GET_EMISSION_PROC_KEY = "org.eclipse.swt.internal.gtk.getEmissionProc";
/**
 * Constructs a new instance of this class given only its parent.
 *
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Shell parent) {
    this (parent, SWT.PRIMARY_MODAL);
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
 * </p>
 *
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Shell parent, int style) {
    super (parent, parent is null? style : checkStyleBit (parent, style));
    checkSubclass ();
}

/**
 * Sets the printer data that will be used when the dialog
 * is opened.
 *
 * @param data the data that will be used when the dialog is opened
 *
 * @since 3.4
 */
public void setPrinterData(PrinterData data) {
    this.printerData = data;
}

/**
 * Returns the printer data that will be used when the dialog
 * is opened.
 *
 * @return the data that will be used when the dialog is opened
 *
 * @since 3.4
 */
public PrinterData getPrinterData() {
    return printerData;
}

static int checkBits (int style, int int0, int int1, int int2, int int3, int int4, int int5) {
    int mask = int0 | int1 | int2 | int3 | int4 | int5;
    if ((style & mask) is 0) style |= int0;
    if ((style & int0) !is 0) style = (style & ~mask) | int0;
    if ((style & int1) !is 0) style = (style & ~mask) | int1;
    if ((style & int2) !is 0) style = (style & ~mask) | int2;
    if ((style & int3) !is 0) style = (style & ~mask) | int3;
    if ((style & int4) !is 0) style = (style & ~mask) | int4;
    if ((style & int5) !is 0) style = (style & ~mask) | int5;
    return style;
}

static int checkStyleBit (Shell parent, int style) {
    style &= ~SWT.MIRRORED;
    if ((style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT)) is 0) {
        if (parent !is null) {
            if ((parent.getStyle () & SWT.LEFT_TO_RIGHT) !is 0) style |= SWT.LEFT_TO_RIGHT;
            if ((parent.getStyle () & SWT.RIGHT_TO_LEFT) !is 0) style |= SWT.RIGHT_TO_LEFT;
        }
    }
    return checkBits (style, SWT.LEFT_TO_RIGHT, SWT.RIGHT_TO_LEFT, 0, 0, 0, 0);
}

/**
 * Returns the print job scope that the user selected
 * before pressing OK in the dialog. This will be one
 * of the following values:
 * <dl>
 * <dt><code>PrinterData.ALL_PAGES</code></dt>
 * <dd>Print all pages in the current document</dd>
 * <dt><code>PrinterData.PAGE_RANGE</code></dt>
 * <dd>Print the range of pages specified by startPage and endPage</dd>
 * <dt><code>PrinterData.SELECTION</code></dt>
 * <dd>Print the current selection</dd>
 * </dl>
 *
 * @return the scope setting that the user selected
 */
public int getScope() {
    return scope_;
}

/**
 * Sets the scope of the print job. The user will see this
 * setting when the dialog is opened. This can have one of
 * the following values:
 * <dl>
 * <dt><code>PrinterData.ALL_PAGES</code></dt>
 * <dd>Print all pages in the current document</dd>
 * <dt><code>PrinterData.PAGE_RANGE</code></dt>
 * <dd>Print the range of pages specified by startPage and endPage</dd>
 * <dt><code>PrinterData.SELECTION</code></dt>
 * <dd>Print the current selection</dd>
 * </dl>
 *
 * @param scope the scope setting when the dialog is opened
 */
public void setScope(int scope_) {
    this.scope_ = scope_;
}

/**
 * Returns the start page setting that the user selected
 * before pressing OK in the dialog.
 * <p>
 * This value can be from 1 to the maximum number of pages for the platform.
 * Note that it is only valid if the scope is <code>PrinterData.PAGE_RANGE</code>.
 * </p>
 *
 * @return the start page setting that the user selected
 */
public int getStartPage() {
    return startPage;
}

/**
 * Sets the start page that the user will see when the dialog
 * is opened.
 * <p>
 * This value can be from 1 to the maximum number of pages for the platform.
 * Note that it is only valid if the scope is <code>PrinterData.PAGE_RANGE</code>.
 * </p>
 *
 * @param startPage the startPage setting when the dialog is opened
 */
public void setStartPage(int startPage) {
    this.startPage = startPage;
}

/**
 * Returns the end page setting that the user selected
 * before pressing OK in the dialog.
 * <p>
 * This value can be from 1 to the maximum number of pages for the platform.
 * Note that it is only valid if the scope is <code>PrinterData.PAGE_RANGE</code>.
 * </p>
 *
 * @return the end page setting that the user selected
 */
public int getEndPage() {
    return endPage;
}

/**
 * Sets the end page that the user will see when the dialog
 * is opened.
 * <p>
 * This value can be from 1 to the maximum number of pages for the platform.
 * Note that it is only valid if the scope is <code>PrinterData.PAGE_RANGE</code>.
 * </p>
 *
 * @param endPage the end page setting when the dialog is opened
 */
public void setEndPage(int endPage) {
    this.endPage = endPage;
}

/**
 * Returns the 'Print to file' setting that the user selected
 * before pressing OK in the dialog.
 *
 * @return the 'Print to file' setting that the user selected
 */
public bool getPrintToFile() {
    return printToFile;
}

/**
 * Sets the 'Print to file' setting that the user will see
 * when the dialog is opened.
 *
 * @param printToFile the 'Print to file' setting when the dialog is opened
 */
public void setPrintToFile(bool printToFile) {
    this.printToFile = printToFile;
}

/**
 * Makes the receiver visible and brings it to the front
 * of the display.
 *
 * @return a printer data object describing the desired print job parameters
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public PrinterData open() {
    if (OS.GTK_VERSION < OS.buildVERSION (2, 10, 0)) {
        return Printer.getDefaultPrinterData();
    } else {
        char* titleBytes = toStringz( getText() );
        auto topHandle = getParent().handle;
        while (topHandle !is null && !OS.GTK_IS_WINDOW(topHandle)) {
            topHandle = OS.gtk_widget_get_parent(topHandle);
        }
        handle = cast(GtkPrintUnixDialog*)OS.gtk_print_unix_dialog_new(titleBytes, cast(GtkWindow*)topHandle);

        //TODO: Not currently implemented. May need new API. For now, disable 'Current' in the dialog. (see gtk bug 344519)
        OS.gtk_print_unix_dialog_set_current_page(handle, -1);

        OS.gtk_print_unix_dialog_set_manual_capabilities(handle,
            OS.GTK_PRINT_CAPABILITY_COLLATE | OS.GTK_PRINT_CAPABILITY_COPIES | OS.GTK_PRINT_CAPABILITY_PAGE_SET);

        /* Set state into print dialog settings. */
        auto settings = OS.gtk_print_settings_new();
        auto page_setup = OS.gtk_page_setup_new();

        if (printerData !is null) {
            if (printerData.otherData !is null) {
                Printer.restore(printerData.otherData, settings, page_setup);
            }
            /* Set values of settings from PrinterData. */
            Printer.setScope(settings, printerData.scope_, printerData.startPage, printerData.endPage);
            //TODO: Should we look at printToFile, or driver/name for "Print to File", or both? (see gtk bug 345590)
            if (printerData.printToFile) {
                char* buffer = toStringz(printerData.fileName);
                OS.gtk_print_settings_set(settings, OS.GTK_PRINT_SETTINGS_OUTPUT_URI.ptr, buffer);
            }
            if (printerData.driver.equals("GtkPrintBackendFile") && printerData.name.equals("Print to File")) { //$NON-NLS-1$ //$NON-NLS-2$
                char* buffer = toStringz(printerData.fileName);
                OS.gtk_print_settings_set(settings, OS.GTK_PRINT_SETTINGS_OUTPUT_URI.ptr, buffer);
            }
            OS.gtk_print_settings_set_n_copies(settings, printerData.copyCount);
            OS.gtk_print_settings_set_collate(settings, printerData.collate);
        }

        Printer.setScope(settings, scope_, startPage, endPage);

        if (printToFile) {
            char* buffer = toStringz( "Print to File" ); //$NON-NLS-1$
            OS.gtk_print_settings_set_printer(settings, buffer);
        }
        OS.gtk_print_unix_dialog_set_settings(handle, settings);
        OS.gtk_print_unix_dialog_set_page_setup(handle, page_setup);
        OS.g_object_unref(settings);
        OS.g_object_unref(page_setup);

        PrinterData data = null;
        //TODO: Handle 'Print Preview' (GTK_RESPONSE_APPLY).
        Display display = getParent() !is null ? getParent().getDisplay (): Display.getCurrent ();

        int signalId = 0;
        ptrdiff_t hookId = 0;
        if ((getStyle () & SWT.RIGHT_TO_LEFT) !is 0) {
            signalId = OS.g_signal_lookup (OS.map.ptr, OS.GTK_TYPE_WIDGET());
            hookId = OS.g_signal_add_emission_hook (signalId, 0, cast(GSignalEmissionHook)cast(void*)(cast(LONG) display.getData (GET_EMISSION_PROC_KEY)).intValue, handle, null);
        }
        display.setData (ADD_IDLE_PROC_KEY, null);
        Object oldModal = null;
        if (OS.gtk_window_get_modal (handle)) {
            oldModal = display.getData (GET_MODAL_DIALOG);
            display.setData (SET_MODAL_DIALOG, this);
        }
        ptrdiff_t response = OS.gtk_dialog_run (handle);
        if (OS.gtk_window_get_modal (handle)) {
            display.setData (SET_MODAL_DIALOG, oldModal);
        }
        if ((getStyle () & SWT.RIGHT_TO_LEFT) !is 0) {
            OS.g_signal_remove_emission_hook (signalId, hookId);
        }
        if (response is OS.GTK_RESPONSE_OK) {
            auto printer = OS.gtk_print_unix_dialog_get_selected_printer(handle);
            if (printer !is null) {

                /* Get state from print dialog. */
                settings = OS.gtk_print_unix_dialog_get_settings(handle); // must unref
                page_setup = OS.gtk_print_unix_dialog_get_page_setup(handle); // do not unref
                data = Printer.printerDataFromGtkPrinter(printer);
                ptrdiff_t print_pages = OS.gtk_print_settings_get_print_pages(settings);
                switch (print_pages) {
                    case OS.GTK_PRINT_PAGES_ALL:
                        scope_ = PrinterData.ALL_PAGES;
                        break;
                    case OS.GTK_PRINT_PAGES_RANGES:
                        scope_ = PrinterData.PAGE_RANGE;
                        int num_ranges;
                        auto page_ranges = OS.gtk_print_settings_get_page_ranges(settings, &num_ranges);
                        ptrdiff_t length = num_ranges;
                        int min = int.max, max = 0;
                        for (int i = 0; i < length; i++) {
                            min = Math.min(min, page_ranges[i].start + 1);
                            max = Math.max(max, page_ranges[i].end + 1);
                        }
                        OS.g_free(page_ranges);
                        startPage = min is int.max ? 1 : min;
                        endPage = max is 0 ? 1 : max;
                        break;
                    case OS.GTK_PRINT_PAGES_CURRENT:
                        //TODO: Disabled in dialog (see above). This code will not run. (see gtk bug 344519)
                        scope_ = PrinterData.SELECTION;
                        startPage = endPage = OS.gtk_print_unix_dialog_get_current_page(handle);
                        break;
                    default:
                }

                printToFile = ( data.name.equals("Print to File")); //$NON-NLS-1$
                if (printToFile) {
                    auto address = OS.gtk_print_settings_get(settings, OS.GTK_PRINT_SETTINGS_OUTPUT_URI.ptr);
                    data.fileName = fromStringz( address)._idup();
                }

                data.scope_ = scope_;
                data.startPage = startPage;
                data.endPage = endPage;
                data.printToFile = printToFile;
                data.copyCount = OS.gtk_print_settings_get_n_copies(settings);
                data.collate = cast(bool)OS.gtk_print_settings_get_collate(settings);

                /* Save other print_settings data as key/value pairs in otherData. */
                index = 0;
                settingsData = new char[1024];
                settingsData[] = '\0';
                OS.gtk_print_settings_foreach (settings, &GtkPrintSettingsFunc, cast(void*)this );
                index++; // extra null terminator after print_settings and before page_setup

                /* Save page_setup data as key/value pairs in otherData.
                 * Note that page_setup properties must be stored and restored in the same order.
                 */
                store("orientation", OS.gtk_page_setup_get_orientation(page_setup)); //$NON-NLS-1$
                store("top_margin", OS.gtk_page_setup_get_top_margin(page_setup, OS.GTK_UNIT_MM)); //$NON-NLS-1$
                store("bottom_margin", OS.gtk_page_setup_get_bottom_margin(page_setup, OS.GTK_UNIT_MM)); //$NON-NLS-1$
                store("left_margin", OS.gtk_page_setup_get_left_margin(page_setup, OS.GTK_UNIT_MM)); //$NON-NLS-1$
                store("right_margin", OS.gtk_page_setup_get_right_margin(page_setup, OS.GTK_UNIT_MM)); //$NON-NLS-1$
                auto paper_size = OS.gtk_page_setup_get_paper_size(page_setup); //$NON-NLS-1$
                storeBytes("paper_size_name", OS.gtk_paper_size_get_name(paper_size)); //$NON-NLS-1$
                storeBytes("paper_size_display_name", OS.gtk_paper_size_get_display_name(paper_size)); //$NON-NLS-1$
                storeBytes("paper_size_ppd_name", OS.gtk_paper_size_get_ppd_name(paper_size)); //$NON-NLS-1$
                store("paper_size_width", OS.gtk_paper_size_get_width(paper_size, OS.GTK_UNIT_MM)); //$NON-NLS-1$
                store("paper_size_height", OS.gtk_paper_size_get_height(paper_size, OS.GTK_UNIT_MM)); //$NON-NLS-1$
                store("paper_size_is_custom", OS.gtk_paper_size_is_custom(paper_size)); //$NON-NLS-1$
                data.otherData = settingsData;
                OS.g_object_unref(settings);
            }
        }
        display.setData (REMOVE_IDLE_PROC_KEY, null);
        OS.gtk_widget_destroy (handle);
        return data;
    }
}

private static extern(C) void GtkPrintSettingsFunc (char* key, char* value, void* data) {
    (cast(PrintDialog)data).GtkPrintSettingsMeth(key, value );
}

void GtkPrintSettingsMeth (char* key, char* value) {
    store( fromStringz(key)._idup(), fromStringz(value)._idup() );
}

void store(String key, int value) {
    store(key, to!(String)(value));
}

void store(String key, double value) {
    store(key, to!(String)(value));
}

void store(String key, bool value) {
    store(key, to!(String)(value));
}

void storeBytes(String key, char* value) {
    store(key, fromStringz(value)._idup() );
}

void store(String key, String value) {
    ptrdiff_t length = key.length + 1 + value.length + 1;
    if (index + length + 1 > settingsData.length) {
        char [] newData = new char[settingsData.length + Math.max(length + 1, 1024)];
        newData[] = '\0';
        System.arraycopy (settingsData, 0, newData, 0, settingsData.length);
        settingsData = newData;
    }
    System.arraycopy (key, 0, settingsData, index, key.length);
    index += key.length + 1; // null terminated
    System.arraycopy (value, 0, settingsData, index, value.length);
    index += value.length + 1; // null terminated
}
}
