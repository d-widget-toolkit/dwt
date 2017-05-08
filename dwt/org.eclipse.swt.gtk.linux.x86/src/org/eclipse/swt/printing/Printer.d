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
module org.eclipse.swt.printing.Printer;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.DeviceData;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.cairo.Cairo : Cairo;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.printing.PrinterData;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}


/**
 * Instances of this class are used to print to a printer.
 * Applications create a GC on a printer using <code>new GC(printer)</code>
 * and then draw on the printer GC using the usual graphics calls.
 * <p>
 * A <code>Printer</code> object may be constructed by providing
 * a <code>PrinterData</code> object which identifies the printer.
 * A <code>PrintDialog</code> presents a print dialog to the user
 * and returns an initialized instance of <code>PrinterData</code>.
 * Alternatively, calling <code>new Printer()</code> will construct a
 * printer object for the user's default printer.
 * </p><p>
 * Application code must explicitly invoke the <code>Printer.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 *
 * @see PrinterData
 * @see PrintDialog
 * @see <a href="http://www.eclipse.org/swt/snippets/#printing">Printing snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class Printer : Device {
    static PrinterData [] printerList;

    PrinterData data;
    GtkPrinter* printer;
    GtkPrintJob* printJob;
    GtkPrintSettings* settings;
    void* pageSetup;
    org.eclipse.swt.internal.gtk.OS.cairo_surface_t* surface;
    org.eclipse.swt.internal.gtk.OS.cairo_t* cairo;

    /**
     * whether or not a GC was created for this printer
     */
    bool isGCCreated = false;
    Font systemFont;

    static String settingsData;
    static int start, end;

    static const String GTK_LPR_BACKEND = "GtkPrintBackendLpr"; //$NON-NLS-1$

    static const bool disablePrinting = false;// System.getProperty("org.eclipse.swt.internal.gtk.disablePrinting") !is null; //$NON-NLS-1$

/**
 * Returns an array of <code>PrinterData</code> objects
 * representing all available printers.
 *
 * @return the list of available printers
 */
public static PrinterData[] getPrinterList() {
    printerList = new PrinterData [0];
    if (OS.GTK_VERSION < OS.buildVERSION (2, 10, 0) || disablePrinting) {
        return printerList;
    }
    if (!OS.g_thread_supported ()) {
        OS.g_thread_init (null);
    }
    OS.gtk_set_locale();
    int argc = 0;
    if (!OS.gtk_init_check ( &argc, null)) {
        SWT.error (SWT.ERROR_NO_HANDLES, null, " [gtk_init_check() failed]");
    }
    OS.gtk_enumerate_printers(&GtkPrinterFunc_List, null, null, true);
    return printerList;
}

private static extern(C) int GtkPrinterFunc_List (GtkPrinter* printer, void* user_data) {
    size_t length_ = printerList.length;
    PrinterData [] newList = new PrinterData [length_ + 1];
    System.arraycopy (printerList, 0, newList, 0, length_);
    printerList = newList;
    printerList [length_] = printerDataFromGtkPrinter(printer);
    /*
    * Bug in GTK. While performing a gtk_enumerate_printers(), GTK finds all of the
    * available printers from each backend and can hang. If a backend requires more
    * time to gather printer info, GTK will start an event loop waiting for a done
    * signal before continuing. For the Lpr backend, GTK does not send a done signal
    * which means the event loop never ends. The fix is to check to see if the driver
    * is of type Lpr, and stop the enumeration, which exits the event loop.
    */
    if (printerList[length_].driver.equals(GTK_LPR_BACKEND)) return 1;
    return 0;
}

/**
 * Returns a <code>PrinterData</code> object representing
 * the default printer or <code>null</code> if there is no
 * printer available on the System.
 *
 * @return the default printer data or null
 *
 * @since 2.1
 */
public static PrinterData getDefaultPrinterData() {
    printerList = new PrinterData [1];
    if (OS.GTK_VERSION < OS.buildVERSION (2, 10, 0) || disablePrinting) {
        return null;
    }
    if (!OS.g_thread_supported ()) {
        OS.g_thread_init (null);
    }
    OS.gtk_set_locale();
    int argc = 0;
    if (!OS.gtk_init_check (&argc, null)) {
        SWT.error (SWT.ERROR_NO_HANDLES, null, " [gtk_init_check() failed]");
    }
    OS.gtk_enumerate_printers(&GtkPrinterFunc_Default, null, null, true);
    return printerList[0];
}

private static extern(C) int GtkPrinterFunc_Default (GtkPrinter* printer, void* user_data) {
    if (OS.gtk_printer_is_default(printer)) {
        printerList[0] = printerDataFromGtkPrinter(printer);
        return 1;
    } else if (OS.GTK_VERSION < OS.buildVERSION(2, 10, 12) && printerDataFromGtkPrinter(printer).driver.equals (GTK_LPR_BACKEND)) {
        return 1;
    }
    return 0;
}

GtkPrinter* gtkPrinterFromPrinterData() {
    printer = null;
    OS.gtk_enumerate_printers(&GtkPrinterFunc_FindNamedPrinterFunc, cast(void*)this, null, true);
    return printer;
}

private static extern(C) int GtkPrinterFunc_FindNamedPrinterFunc (GtkPrinter* printer, void* user_data) {
    return (cast(Printer)user_data).GtkPrinterFunc_FindNamedPrinter( printer, null );
}
int GtkPrinterFunc_FindNamedPrinter (GtkPrinter* printer, void* user_data) {
    PrinterData pd = printerDataFromGtkPrinter(printer);
    if (pd.driver.equals(data.driver) && pd.name.equals(data.name)) {
        this.printer = printer;
        OS.g_object_ref(printer);
        return 1;
    } else if (OS.GTK_VERSION < OS.buildVERSION (2, 10, 12) && pd.driver.equals(GTK_LPR_BACKEND)) {
        return 1;
    }
    return 0;
}

static PrinterData printerDataFromGtkPrinter(GtkPrinter*  printer) {
    auto backend = OS.gtk_printer_get_backend(printer);
    auto address = OS.G_OBJECT_TYPE_NAME(backend);
    String backendType = fromStringz( address )._idup();

    address = OS.gtk_printer_get_name (printer);
    String name = fromStringz( address )._idup();

    return new PrinterData (backendType, name);
}

/*
* Restore printer settings and page_setup data from data.
*/
static void restore(char[] data, GtkPrintSettings* settings, GtkPageSetup* page_setup) {
    settingsData = data._idup();
    start = end = 0;
    while (end < settingsData.length && settingsData[end] !is 0) {
        start = end;
        while (end < settingsData.length && settingsData[end] !is 0) end++;
        end++;
        char [] keyBuffer = new char [end - start];
        System.arraycopy (settingsData, start, keyBuffer, 0, keyBuffer.length);
        start = end;
        while (end < settingsData.length && settingsData[end] !is 0) end++;
        end++;
        char [] valueBuffer = new char [end - start];
        System.arraycopy (settingsData, start, valueBuffer, 0, valueBuffer.length);
        OS.gtk_print_settings_set(settings, keyBuffer.ptr, valueBuffer.ptr);
        if (DEBUG) getDwtLogger().info( __FILE__, __LINE__, "{}: {}", keyBuffer, valueBuffer );
    }
    end++; // skip extra null terminator

    /* Retrieve stored page_setup data.
     * Note that page_setup properties must be stored (in PrintDialog) and restored (here) in the same order.
     */
    OS.gtk_page_setup_set_orientation(page_setup, restoreInt("orientation")); //$NON-NLS-1$
    OS.gtk_page_setup_set_top_margin(page_setup, restoreDouble("top_margin"), OS.GTK_UNIT_MM); //$NON-NLS-1$
    OS.gtk_page_setup_set_bottom_margin(page_setup, restoreDouble("bottom_margin"), OS.GTK_UNIT_MM); //$NON-NLS-1$
    OS.gtk_page_setup_set_left_margin(page_setup, restoreDouble("left_margin"), OS.GTK_UNIT_MM); //$NON-NLS-1$
    OS.gtk_page_setup_set_right_margin(page_setup, restoreDouble("right_margin"), OS.GTK_UNIT_MM); //$NON-NLS-1$
    String name = restoreBytes("paper_size_name", true); //$NON-NLS-1$
    String display_name = restoreBytes("paper_size_display_name", true); //$NON-NLS-1$
    String ppd_name = restoreBytes("paper_size_ppd_name", true); //$NON-NLS-1$
    double width = restoreDouble("paper_size_width"); //$NON-NLS-1$
    double height = restoreDouble("paper_size_height"); //$NON-NLS-1$
    bool custom = restoreBoolean("paper_size_is_custom"); //$NON-NLS-1$
    GtkPaperSize* paper_size = null;
    if (custom) {
        if (ppd_name.length > 0) {
            paper_size = OS.gtk_paper_size_new_from_ppd(ppd_name.ptr, display_name.ptr, width, height);
        } else {
            paper_size = OS.gtk_paper_size_new_custom(name.ptr, display_name.ptr, width, height, OS.GTK_UNIT_MM);
        }
    } else {
        paper_size = OS.gtk_paper_size_new(name.ptr);
    }
    OS.gtk_page_setup_set_paper_size(page_setup, paper_size);
    OS.gtk_paper_size_free(paper_size);
}

static void setScope(GtkPrintSettings* settings, int scope_, int startPage, int endPage) {
    switch (scope_) {
    case PrinterData.ALL_PAGES:
        OS.gtk_print_settings_set_print_pages(settings, OS.GTK_PRINT_PAGES_ALL);
        break;
    case PrinterData.PAGE_RANGE:
        OS.gtk_print_settings_set_print_pages(settings, OS.GTK_PRINT_PAGES_RANGES);
        GtkPageRange pageRange;
        pageRange.start = startPage - 1;
        pageRange.end = endPage - 1;
        OS.gtk_print_settings_set_page_ranges(settings, &pageRange, 1);
        break;
    case PrinterData.SELECTION:
        //TODO: Not correctly implemented. May need new API. For now, set to ALL. (see gtk bug 344519)
        OS.gtk_print_settings_set_print_pages(settings, OS.GTK_PRINT_PAGES_ALL);
        break;
    default:
    }
}

static DeviceData checkNull (PrinterData data) {
    if (data is null) data = new PrinterData();
    if (data.driver is null || data.name is null) {
        PrinterData defaultPrinter = getDefaultPrinterData();
        if (defaultPrinter is null) SWT.error(SWT.ERROR_NO_HANDLES);
        data.driver = defaultPrinter.driver;
        data.name = defaultPrinter.name;
    }
    return data;
}

/**
 * Constructs a new printer representing the default printer.
 * <p>
 * You must dispose the printer when it is no longer required.
 * </p>
 *
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES - if there are no valid printers
 * </ul>
 *
 * @see Device#dispose
 */
public this() {
    this(null);
}

/**
 * Constructs a new printer given a <code>PrinterData</code>
 * object representing the desired printer.
 * <p>
 * You must dispose the printer when it is no longer required.
 * </p>
 *
 * @param data the printer data for the specified printer
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the specified printer data does not represent a valid printer
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES - if there are no valid printers
 * </ul>
 *
 * @see Device#dispose
 */
public this(PrinterData data) {
    super(checkNull(data));
}

static int restoreInt(String key) {
    String value = restoreBytes(key, false);
    return Integer.parseInt( value );
}

static double restoreDouble(String key) {
    String value = restoreBytes(key, false);
    return Double.parseDouble( value );
}

static bool restoreBoolean(String key) {
    String value = restoreBytes(key, false);
    return Boolean.getBoolean( value );
}

static String restoreBytes(String key, bool nullTerminate) {
    //get key
    start = end;
    while (end < settingsData.length && settingsData[end] !is 0) end++;
    end++;
    char [] keyBuffer = new char [end - start];
    System.arraycopy (settingsData, start, keyBuffer, 0, keyBuffer.length);

    //get value
    start = end;
    while (end < settingsData.length && settingsData[end] !is 0) end++;
    int length_ = end - start;
    end++;
    if (nullTerminate) length_++;
    char [] valueBuffer = new char [length_];
    System.arraycopy (settingsData, start, valueBuffer, 0, length_);

    if (DEBUG) getDwtLogger().info( __FILE__, __LINE__,  "{}: {}", keyBuffer, valueBuffer );

    return cast(String)valueBuffer;
}

/**
 * Returns a reasonable font for applications to use.
 * On some platforms, this will match the "default font"
 * or "system font" if such can be found.  This font
 * should not be free'd because it was allocated by the
 * system, not the application.
 * <p>
 * Typically, applications which want the default look
 * should simply not set the font on the widgets they
 * create. Widgets are always created with the correct
 * default font for the class of user-interface component
 * they represent.
 * </p>
 *
 * @return a font
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public override Font getSystemFont () {
    checkDevice ();
    if (systemFont !is null) return systemFont;
    auto style = OS.gtk_widget_get_default_style();
    auto defaultFont = OS.pango_font_description_copy (OS.gtk_style_get_font_desc (style));
    return systemFont = Font.gtk_new (this, defaultFont);
}

/**
 * Invokes platform specific functionality to allocate a new GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Printer</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param data the platform specific GC data
 * @return the platform specific GC handle
 */
public override GdkGC* internal_new_GC(GCData data) {
    auto drawable = OS.gdk_pixmap_new(OS.GDK_ROOT_PARENT(), 1, 1, 1);
    auto gdkGC = OS.gdk_gc_new (drawable);
    if (gdkGC is null) SWT.error (SWT.ERROR_NO_HANDLES);
    if (data !is null) {
        if (isGCCreated) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        int mask = SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT;
        if ((data.style & mask) is 0) {
            data.style |= SWT.LEFT_TO_RIGHT;
        }
        data.device = this;
        data.drawable = drawable;
        data.background = getSystemColor (SWT.COLOR_WHITE).handle;
        data.foreground = getSystemColor (SWT.COLOR_BLACK).handle;
        data.font = getSystemFont ();
        //TODO: We are supposed to return this in pixels, but GTK_UNIT_PIXELS is currently not implemented (gtk bug 346245)
        data.width = cast(int)OS.gtk_page_setup_get_paper_width (pageSetup, OS.GTK_UNIT_POINTS);
        data.height = cast(int)OS.gtk_page_setup_get_paper_height (pageSetup, OS.GTK_UNIT_POINTS);
        if (cairo is null) SWT.error(SWT.ERROR_NO_HANDLES);
        data.cairo = cairo;
        isGCCreated = true;
    }
    return gdkGC;
}

/**
 * Invokes platform specific functionality to dispose a GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Printer</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param hDC the platform specific GC handle
 * @param data the platform specific GC data
 */
public override void internal_dispose_GC(GdkGC* gdkGC, GCData data) {
    if (data !is null) isGCCreated = false;
    OS.g_object_unref (gdkGC);
    if (data !is null) {
        if (data.drawable !is null) OS.g_object_unref (data.drawable);
        data.drawable = null;
        data.cairo = null;
    }
}

/**
 * Releases any internal state prior to destroying this printer.
 * This method is called internally by the dispose
 * mechanism of the <code>Device</code> class.
 */
protected override void release () {
    super.release();

    /* Dispose the default font */
    if (systemFont !is null) systemFont.dispose ();
    systemFont = null;
}

/**
 * Starts a print job and returns true if the job started successfully
 * and false otherwise.
 * <p>
 * This must be the first method called to initiate a print job,
 * followed by any number of startPage/endPage calls, followed by
 * endJob. Calling startPage, endPage, or endJob before startJob
 * will result in undefined behavior.
 * </p>
 *
 * @param jobName the name of the print job to start
 * @return true if the job started successfully and false otherwise.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #startPage
 * @see #endPage
 * @see #endJob
 */
public bool startJob(String jobName) {
    checkDevice();
    char* buffer = toStringz(jobName);
    printJob = OS.gtk_print_job_new (buffer, printer, settings, pageSetup);
    if (printJob is null) return false;
    surface = OS.gtk_print_job_get_surface(printJob, null);
    if (surface is null) {
        OS.g_object_unref(printJob);
        printJob = null;
        return false;
    }
    cairo = Cairo.cairo_create(surface);
    if (cairo is null)  {
        OS.g_object_unref(printJob);
        printJob = null;
        return false;
    }
    return true;
}

/**
 * Destroys the printer handle.
 * This method is called internally by the dispose
 * mechanism of the <code>Device</code> class.
 */
protected override void destroy () {
    if (printer !is null) OS.g_object_unref (printer);
    if (settings !is null) OS.g_object_unref (settings);
    if (pageSetup !is null) OS.g_object_unref (pageSetup);
    if (cairo !is null) Cairo.cairo_destroy (cairo);
    if (printJob !is null) OS.g_object_unref (printJob);
    printer = null;
    settings = null;
    pageSetup = null;
    cairo = null;
    printJob = null;
}

/**
 * Ends the current print job.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #startJob
 * @see #startPage
 * @see #endPage
 */
public void endJob() {
    checkDevice();
    if (printJob is null) return;
    Cairo.cairo_surface_finish(surface);
    OS.gtk_print_job_send(printJob, null, null, null );
}

/**
 * Cancels a print job in progress.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void cancelJob() {
    checkDevice();
    if (printJob is null) return;
    //TODO: Need to implement (waiting on gtk bug 339323)
    //OS.g_object_unref(printJob);
    //printJob = 0;
}

/**
 * Starts a page and returns true if the page started successfully
 * and false otherwise.
 * <p>
 * After calling startJob, this method may be called any number of times
 * along with a matching endPage.
 * </p>
 *
 * @return true if the page started successfully and false otherwise.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #endPage
 * @see #startJob
 * @see #endJob
 */
public bool startPage() {
    checkDevice();
    if (printJob is null) return false;
    double width = OS.gtk_page_setup_get_paper_width (pageSetup, OS.GTK_UNIT_POINTS);
    double height = OS.gtk_page_setup_get_paper_height (pageSetup, OS.GTK_UNIT_POINTS);
    ptrdiff_t type = Cairo.cairo_surface_get_type (surface);
    switch (type) {
        case Cairo.CAIRO_SURFACE_TYPE_PS:
            Cairo.cairo_ps_surface_set_size (surface, width, height);
            break;
        case Cairo.CAIRO_SURFACE_TYPE_PDF:
            Cairo.cairo_pdf_surface_set_size (surface, width, height);
            break;
        default:
    }
    return true;
}

/**
 * Ends the current page.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #startPage
 * @see #startJob
 * @see #endJob
 */
public void endPage() {
    checkDevice();
    if (cairo !is null) Cairo.cairo_show_page(cairo);
}

/**
 * Returns a point whose x coordinate is the horizontal
 * dots per inch of the printer, and whose y coordinate
 * is the vertical dots per inch of the printer.
 *
 * @return the horizontal and vertical DPI
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public override Point getDPI() {
    checkDevice();
    int resolution = OS.gtk_print_settings_get_resolution(settings);
    if (DEBUG) getDwtLogger().info( __FILE__, __LINE__, "print_settings.resolution={}", resolution);
    //TODO: Return 72 (1/72 inch = 1 point) until gtk bug 346245 is fixed
    //TODO: Fix this: gtk_print_settings_get_resolution returns 0? (see gtk bug 346252)
    if (true || resolution is 0) return new Point(72, 72);
    return new Point(resolution, resolution);
}

/**
 * Returns a rectangle describing the receiver's size and location.
 * <p>
 * For a printer, this is the size of the physical page, in pixels.
 * </p>
 *
 * @return the bounding rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getClientArea
 * @see #computeTrim
 */
public override Rectangle getBounds() {
    checkDevice();
    //TODO: We are supposed to return this in pixels, but GTK_UNIT_PIXELS is currently not implemented (gtk bug 346245)
    double width = OS.gtk_page_setup_get_paper_width (pageSetup, OS.GTK_UNIT_POINTS);
    double height = OS.gtk_page_setup_get_paper_height (pageSetup, OS.GTK_UNIT_POINTS);
    return new Rectangle(0, 0, cast(int) width, cast(int) height);
}

/**
 * Returns a rectangle which describes the area of the
 * receiver which is capable of displaying data.
 * <p>
 * For a printer, this is the size of the printable area
 * of the page, in pixels.
 * </p>
 *
 * @return the client area
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getBounds
 * @see #computeTrim
 */
public override Rectangle getClientArea() {
    checkDevice();
    //TODO: We are supposed to return this in pixels, but GTK_UNIT_PIXELS is currently not implemented (gtk bug 346245)
    double width = OS.gtk_page_setup_get_page_width(pageSetup, OS.GTK_UNIT_POINTS);
    double height = OS.gtk_page_setup_get_page_height(pageSetup, OS.GTK_UNIT_POINTS);
    return new Rectangle(0, 0, cast(int) width, cast(int) height);
}

/**
 * Given a <em>client area</em> (as described by the arguments),
 * returns a rectangle, relative to the client area's coordinates,
 * that is the client area expanded by the printer's trim (or minimum margins).
 * <p>
 * Most printers have a minimum margin on each edge of the paper where the
 * printer device is unable to print.  This margin is known as the "trim."
 * This method can be used to calculate the printer's minimum margins
 * by passing in a client area of 0, 0, 0, 0 and then using the resulting
 * x and y coordinates (which will be <= 0) to determine the minimum margins
 * for the top and left edges of the paper, and the resulting width and height
 * (offset by the resulting x and y) to determine the minimum margins for the
 * bottom and right edges of the paper, as follows:
 * <ul>
 *      <li>The left trim width is -x pixels</li>
 *      <li>The top trim height is -y pixels</li>
 *      <li>The right trim width is (x + width) pixels</li>
 *      <li>The bottom trim height is (y + height) pixels</li>
 * </ul>
 * </p>
 *
 * @param x the x coordinate of the client area
 * @param y the y coordinate of the client area
 * @param width the width of the client area
 * @param height the height of the client area
 * @return a rectangle, relative to the client area's coordinates, that is
 *      the client area expanded by the printer's trim (or minimum margins)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getBounds
 * @see #getClientArea
 */
public Rectangle computeTrim(int x, int y, int width, int height) {
    checkDevice();
    //TODO: We are supposed to return this in pixels, but GTK_UNIT_PIXELS is currently not implemented (gtk bug 346245)
    double printWidth = OS.gtk_page_setup_get_page_width(pageSetup, OS.GTK_UNIT_POINTS);
    double printHeight = OS.gtk_page_setup_get_page_height(pageSetup, OS.GTK_UNIT_POINTS);
    double paperWidth = OS.gtk_page_setup_get_paper_width (pageSetup, OS.GTK_UNIT_POINTS);
    double paperHeight = OS.gtk_page_setup_get_paper_height (pageSetup, OS.GTK_UNIT_POINTS);
    double printX = -OS.gtk_page_setup_get_left_margin(pageSetup, OS.GTK_UNIT_POINTS);
    double printY = -OS.gtk_page_setup_get_top_margin(pageSetup, OS.GTK_UNIT_POINTS);
    double hTrim = paperWidth - printWidth;
    double vTrim = paperHeight - printHeight;
    return new Rectangle(x + cast(int)printX, y + cast(int)printY, width + cast(int)hTrim, height + cast(int)vTrim);
}

/**
 * Creates the printer handle.
 * This method is called internally by the instance creation
 * mechanism of the <code>Device</code> class.
 * @param deviceData the device data
 */
protected override void create(DeviceData deviceData) {
    this.data = cast(PrinterData)deviceData;
    if (OS.GTK_VERSION < OS.buildVERSION (2, 10, 0) || disablePrinting) SWT.error(SWT.ERROR_NO_HANDLES);
    printer = gtkPrinterFromPrinterData();
    if (printer is null) SWT.error(SWT.ERROR_NO_HANDLES);
}

/**
 * Initializes any internal resources needed by the
 * device.
 * <p>
 * This method is called after <code>create</code>.
 * </p><p>
 * If subclasses reimplement this method, they must
 * call the <code>super</code> implementation.
 * </p>
 *
 * @see #create
 */
protected override void init_() {
    super.init_ ();
    settings = OS.gtk_print_settings_new();
    pageSetup = OS.gtk_page_setup_new();
    if (data.otherData !is null) {
        restore(data.otherData, settings, pageSetup);
    }

    /* Set values of settings from PrinterData. */
    setScope(settings, data.scope_, data.startPage, data.endPage);
    //TODO: Should we look at printToFile, or driver/name for "Print to File", or both? (see gtk bug 345590)
    if (data.printToFile) {
        char* buffer = toStringz( data.fileName );
        OS.gtk_print_settings_set(settings, OS.GTK_PRINT_SETTINGS_OUTPUT_URI.ptr, buffer);
    }
    if (data.driver.equals("GtkPrintBackendFile") && data.name.equals("Print to File")) { //$NON-NLS-1$ //$NON-NLS-2$
        char* buffer = toStringz( data.fileName );
        OS.gtk_print_settings_set(settings, OS.GTK_PRINT_SETTINGS_OUTPUT_URI.ptr, buffer);
    }
    OS.gtk_print_settings_set_n_copies(settings, data.copyCount);
    OS.gtk_print_settings_set_collate(settings, data.collate);
}

/**
 * Returns a <code>PrinterData</code> object representing the
 * target printer for this print job.
 *
 * @return a PrinterData object describing the receiver
 */
public PrinterData getPrinterData() {
    checkDevice();
    return data;
}

}
