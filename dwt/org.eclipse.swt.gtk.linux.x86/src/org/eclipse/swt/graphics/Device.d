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
module org.eclipse.swt.graphics.Device;

import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Drawable;
import org.eclipse.swt.graphics.DeviceData;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.internal.gtk.OS;
import java.lang.all;


/**
 * This class is the abstract superclass of all device objects,
 * such as the Display device and the Printer device. Devices
 * can have a graphics context (GC) created for them, and they
 * can be drawn on by sending messages to the associated GC.
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public abstract class Device : Drawable {
    /**
     * the handle to the X Display
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked protected only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    protected void* xDisplay;
    GtkWidget* shellHandle;

    /* Debugging */
    public static bool DEBUG = true;
    bool debugging;
    bool tracking;
    Exception [] errors;
    Object [] objects;
    Object trackingLock;

    /* Colormap and reference count */
    GdkColor *[] gdkColors;
    int [] colorRefCount;

    /* Disposed flag */
    bool disposed;

    /* Warning and Error Handlers */
    //ptrdiff_t logProcFld;
    //GLogFunc logCallback;
    //NOT DONE - get list of valid names
    String [] log_domains = ["GLib-GObject"[], "GLib", "GObject", "Pango", "ATK", "GdkPixbuf", "Gdk", "Gtk", "GnomeVFS"];
    int [] handler_ids;// = new int [log_domains.length];
    int warningLevel;

    /* X Warning and Error Handlers */
    static extern(C) int function(void *) mXIOErrorHandler;
    static extern(C) int function(void *, XErrorEvent *) mXErrorHandler;
    //static int mXErrorCallback, mXIOErrorCallback;

    static ptrdiff_t XErrorProc, XIOErrorProc, XNullErrorProc, XNullIOErrorProc;
    static Device[] Devices;

    /*
    * The following colors are listed in the Windows
    * Programmer's Reference as the colors in the default
    * palette.
    */
    Color COLOR_BLACK, COLOR_DARK_RED, COLOR_DARK_GREEN, COLOR_DARK_YELLOW, COLOR_DARK_BLUE;
    Color COLOR_DARK_MAGENTA, COLOR_DARK_CYAN, COLOR_GRAY, COLOR_DARK_GRAY, COLOR_RED;
    Color COLOR_GREEN, COLOR_YELLOW, COLOR_BLUE, COLOR_MAGENTA, COLOR_CYAN, COLOR_WHITE;

    /* System Font */
    Font systemFont;

    PangoTabArray* emptyTab;

    bool useXRender;

    static bool CAIRO_LOADED;

    /*
    * TEMPORARY CODE. When a graphics object is
    * created and the device parameter is null,
    * the current Display is used. This presents
    * a problem because SWT graphics does not
    * reference classes in SWT widgets. The correct
    * fix is to remove this feature. Unfortunately,
    * too many application programs rely on this
    * feature.
    *
    * This code will be removed in the future.
    */
    protected static Device CurrentDevice;
    protected static Runnable DeviceFinder;

//synchronized static void static_this(){
//    CREATE_LOCK = new Object();
//    Devices = new Device[4];
//}
/*
* TEMPORARY CODE.
*/
static Device getDevice () {
    synchronized {
        if (DeviceFinder !is null) DeviceFinder.run();
        Device device = CurrentDevice;
        CurrentDevice = null;
        return device;
    }
}

/**
 * Constructs a new instance of this class.
 * <p>
 * You must dispose the device when it is no longer required.
 * </p>
 *
 * @see #create
 * @see #init
 *
 * @since 3.1
 */
public this() {
    this(null);
}

/**
 * Constructs a new instance of this class.
 * <p>
 * You must dispose the device when it is no longer required.
 * </p>
 *
 * @param data the DeviceData which describes the receiver
 *
 * @see #create
 * @see #init
 * @see DeviceData
 */
public this(DeviceData data) {
    handler_ids = new int [log_domains.length];
    debugging = DEBUG;
    tracking = DEBUG;

    synchronized ( this.classinfo ) {
        if (data !is null) {
            debugging = data.debugging;
            tracking = data.tracking;
        }
        if (tracking) {
            errors = new Exception [128];
            objects = new Object [128];
            trackingLock = new Object ();
        }
        create (data);
        init_ ();
        register (this);
    }
}

void checkCairo() {
}

/**
 * Throws an <code>SWTException</code> if the receiver can not
 * be accessed by the caller. This may include both checks on
 * the state of the receiver and more generally on the entire
 * execution context. This method <em>should</em> be called by
 * device implementors to enforce the standard SWT invariants.
 * <p>
 * Currently, it is an error to invoke any method (other than
 * <code>isDisposed()</code> and <code>dispose()</code>) on a
 * device that has had its <code>dispose()</code> method called.
 * </p><p>
 * In future releases of SWT, there may be more or fewer error
 * checks and exceptions may be thrown for different reasons.
 * <p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
protected void checkDevice () {
    if (disposed) SWT.error(SWT.ERROR_DEVICE_DISPOSED);
}

/**
 * Creates the device in the operating system.  If the device
 * does not have a handle, this method may do nothing depending
 * on the device.
 * <p>
 * This method is called before <code>init</code>.
 * </p><p>
 * Subclasses are supposed to reimplement this method and not
 * call the <code>super</code> implementation.
 * </p>
 *
 * @param data the DeviceData which describes the receiver
 *
 * @see #init
 */
protected void create (DeviceData data) {
}

/**
 * Disposes of the operating system resources associated with
 * the receiver. After this method has been invoked, the receiver
 * will answer <code>true</code> when sent the message
 * <code>isDisposed()</code>.
 *
 * @see #release
 * @see #destroy
 * @see #checkDevice
 */
public void dispose () {
    synchronized (Device.classinfo) {
        if (isDisposed()) return;
        checkDevice ();
        release ();
        destroy ();
        deregister (this);
        xDisplay = null;
        disposed = true;
        if (tracking) {
            synchronized (trackingLock) {
                objects = null;
                errors = null;
                trackingLock = null;
            }
        }
    }
}

void dispose_Object (Object object) {
    synchronized (trackingLock) {
        for (int i=0; i<objects.length; i++) {
            if (objects [i] is object) {
                objects [i] = null;
                errors [i] = null;
                return;
            }
        }
    }
}

static Device findDevice (void* xDisplay) {
    synchronized {
        for (int i=0; i<Devices.length; i++) {
            Device device = Devices [i];
            if (device !is null && device.xDisplay is xDisplay) {
                return device;
            }
        }
        return null;
    }
}

static void deregister (Device device) {
    synchronized {   
        for (int i=0; i<Devices.length; i++) {
            if (device is Devices [i]) Devices [i] = null;
        }
    }
}

/**
 * Destroys the device in the operating system and releases
 * the device's handle.  If the device does not have a handle,
 * this method may do nothing depending on the device.
 * <p>
 * This method is called after <code>release</code>.
 * </p><p>
 * Subclasses are supposed to reimplement this method and not
 * call the <code>super</code> implementation.
 * </p>
 *
 * @see #dispose
 * @see #release
 */
protected void destroy () {
}

/**
 * Returns a rectangle describing the receiver's size and location.
 *
 * @return the bounding rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Rectangle getBounds () {
    checkDevice ();
    return new Rectangle(0, 0, 0, 0);
}

/**
 * Returns a <code>DeviceData</code> based on the receiver.
 * Modifications made to this <code>DeviceData</code> will not
 * affect the receiver.
 *
 * @return a <code>DeviceData</code> containing the device's data and attributes
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see DeviceData
 */
public DeviceData getDeviceData () {
    checkDevice();
    DeviceData data = new DeviceData ();
    data.debugging = debugging;
    data.tracking = tracking;
    if (tracking) {
        synchronized (trackingLock) {
            auto count = 0, length = objects.length;
            for (ptrdiff_t i=0; i<length; i++) {
                if (objects [i] !is null) count++;
            }
            int index = 0;
            data.objects = new Object [count];
            data.errors = new Exception [count];
            for (int i=0; i<length; i++) {
                if (objects [i] !is null) {
                    data.objects [index] = objects [i];
                    data.errors [index] = errors [i];
                    index++;
                }
            }
        }
    } else {
        data.objects = null;
        data.errors = null;
    }
    return data;
}

/**
 * Returns a rectangle which describes the area of the
 * receiver which is capable of displaying data.
 *
 * @return the client area
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getBounds
 */
public Rectangle getClientArea () {
    checkDevice ();
    return getBounds ();
}

/**
 * Returns the bit depth of the screen, which is the number of
 * bits it takes to represent the number of unique colors that
 * the screen is currently capable of displaying. This number
 * will typically be one of 1, 8, 15, 16, 24 or 32.
 *
 * @return the depth of the screen
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getDepth () {
    checkDevice ();
    return 0;
}

/**
 * Returns a point whose x coordinate is the horizontal
 * dots per inch of the display, and whose y coordinate
 * is the vertical dots per inch of the display.
 *
 * @return the horizontal and vertical DPI
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point getDPI () {
    checkDevice ();
    return new Point (72, 72);
}

/**
 * Returns <code>FontData</code> objects which describe
 * the fonts that match the given arguments. If the
 * <code>faceName</code> is null, all fonts will be returned.
 *
 * @param faceName the name of the font to look for, or null
 * @param scalable if true only scalable fonts are returned, otherwise only non-scalable fonts are returned.
 * @return the matching font data
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public FontData[] getFontList (String faceName, bool scalable) {
    checkDevice ();
    if (!scalable) return new FontData[0];
    PangoFontFamily* family;
    PangoFontFace * face;
    PangoFontFamily** families;
    int n_families;
    PangoFontFace ** faces;
    int n_faces;
    auto context = OS.gdk_pango_context_get();
    OS.pango_context_list_families(context, &families, &n_families);
    int nFds = 0;
    FontData[] fds = new FontData[faceName !is null ? 4 : n_families];
    for (int i=0; i<n_families; i++) {
        family = families[i];
        bool match = true;
        if (faceName !is null) {
            auto familyName = OS.pango_font_family_get_name(family);
            match = Compatibility.equalsIgnoreCase(faceName, fromStringz( familyName ));
        }
        if (match) {
            OS.pango_font_family_list_faces(family, &faces, &n_faces);
            for (int j=0; j<n_faces; j++) {
                face = faces[j];
                auto fontDesc = OS.pango_font_face_describe(face);
                Font font = Font.gtk_new(this, fontDesc);
                FontData data = font.getFontData()[0];
                if (nFds is fds.length) {
                    FontData[] newFds = new FontData[fds.length + n_families];
                    System.arraycopy(fds, 0, newFds, 0, nFds);
                    fds = newFds;
                }
                fds[nFds++] = data;
                OS.pango_font_description_free(fontDesc);
            }
            OS.g_free(faces);
            if (faceName !is null) break;
        }
    }
    OS.g_free(families);
    OS.g_object_unref(context);
    if (nFds is fds.length) return fds;
    FontData[] result = new FontData[nFds];
    System.arraycopy(fds, 0, result, 0, nFds);
    return result;
}

/**
 * Returns the matching standard color for the given
 * constant, which should be one of the color constants
 * specified in class <code>SWT</code>. Any value other
 * than one of the SWT color constants which is passed
 * in will result in the color black. This color should
 * not be freed because it was allocated by the system,
 * not the application.
 *
 * @param id the color constant
 * @return the matching color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see SWT
 */
public Color getSystemColor (int id) {
    checkDevice ();
    switch (id) {
        case SWT.COLOR_BLACK:               return COLOR_BLACK;
        case SWT.COLOR_DARK_RED:            return COLOR_DARK_RED;
        case SWT.COLOR_DARK_GREEN:          return COLOR_DARK_GREEN;
        case SWT.COLOR_DARK_YELLOW:         return COLOR_DARK_YELLOW;
        case SWT.COLOR_DARK_BLUE:           return COLOR_DARK_BLUE;
        case SWT.COLOR_DARK_MAGENTA:        return COLOR_DARK_MAGENTA;
        case SWT.COLOR_DARK_CYAN:           return COLOR_DARK_CYAN;
        case SWT.COLOR_GRAY:                return COLOR_GRAY;
        case SWT.COLOR_DARK_GRAY:           return COLOR_DARK_GRAY;
        case SWT.COLOR_RED:                 return COLOR_RED;
        case SWT.COLOR_GREEN:               return COLOR_GREEN;
        case SWT.COLOR_YELLOW:              return COLOR_YELLOW;
        case SWT.COLOR_BLUE:                return COLOR_BLUE;
        case SWT.COLOR_MAGENTA:             return COLOR_MAGENTA;
        case SWT.COLOR_CYAN:                return COLOR_CYAN;
        case SWT.COLOR_WHITE:               return COLOR_WHITE;
        default:
    }
    return COLOR_BLACK;
}

/**
 * Returns a reasonable font for applications to use.
 * On some platforms, this will match the "default font"
 * or "system font" if such can be found.  This font
 * should not be freed because it was allocated by the
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
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Font getSystemFont () {
    checkDevice ();
    return systemFont;
}

/**
 * Returns <code>true</code> if the underlying window system prints out
 * warning messages on the console, and <code>setWarnings</code>
 * had previously been called with <code>true</code>.
 *
 * @return <code>true</code>if warnings are being handled, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool getWarnings () {
    checkDevice ();
    return warningLevel is 0;
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
protected void init_ () {
    if (xDisplay !is null) {
        int event_basep, error_basep;
        if (OS.XRenderQueryExtension (xDisplay, &event_basep, &error_basep)) {
            int major_version, minor_version;
            OS.XRenderQueryVersion (xDisplay, &major_version, &minor_version);
            useXRender = major_version > 0 || (major_version is 0 && minor_version >= 8);
        }
    }

    if (debugging) {
        if (xDisplay !is null) {
            /* Create the warning and error callbacks */
            synchronized (this.classinfo) {
                int index = 0;
                while (index < Devices.length) {
                    if (Devices [index] !is null) break;
                    index++;
                }
                if (index is Devices.length) {
                    OS.XSetErrorHandler ( & XErrorProcFunc );
                    OS.XSetIOErrorHandler ( & XIOErrorProcFunc );
                }
            }
            OS.XSynchronize (xDisplay, true);
        }
    }

    /* Create GTK warnings and error callbacks */
    if (xDisplay !is null) {
        /* Set GTK warning and error handlers */
        if (debugging) {
            int flags = OS.G_LOG_LEVEL_MASK | OS.G_LOG_FLAG_FATAL | OS.G_LOG_FLAG_RECURSION;
            for (int i=0; i<log_domains.length; i++) {
                handler_ids [i] = OS.g_log_set_handler (log_domains [i].toStringzValidPtr(), flags, & logFunction, cast(void*)this);
            }
        }
    }

    /* Create the standard colors */
    COLOR_BLACK = new Color (this, 0,0,0);
    COLOR_DARK_RED = new Color (this, 0x80,0,0);
    COLOR_DARK_GREEN = new Color (this, 0,0x80,0);
    COLOR_DARK_YELLOW = new Color (this, 0x80,0x80,0);
    COLOR_DARK_BLUE = new Color (this, 0,0,0x80);
    COLOR_DARK_MAGENTA = new Color (this, 0x80,0,0x80);
    COLOR_DARK_CYAN = new Color (this, 0,0x80,0x80);
    COLOR_GRAY = new Color (this, 0xC0,0xC0,0xC0);
    COLOR_DARK_GRAY = new Color (this, 0x80,0x80,0x80);
    COLOR_RED = new Color (this, 0xFF,0,0);
    COLOR_GREEN = new Color (this, 0,0xFF,0);
    COLOR_YELLOW = new Color (this, 0xFF,0xFF,0);
    COLOR_BLUE = new Color (this, 0,0,0xFF);
    COLOR_MAGENTA = new Color (this, 0xFF,0,0xFF);
    COLOR_CYAN = new Color (this, 0,0xFF,0xFF);
    COLOR_WHITE = new Color (this, 0xFF,0xFF,0xFF);

    emptyTab = OS.pango_tab_array_new(1, false);
    if (emptyTab is null) SWT.error(SWT.ERROR_NO_HANDLES);
    OS.pango_tab_array_set_tab(emptyTab, 0, OS.PANGO_TAB_LEFT, 1);

    shellHandle = OS.gtk_window_new(OS.GTK_WINDOW_TOPLEVEL);
    if (shellHandle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    OS.gtk_widget_realize(shellHandle);

    /* Initialize the system font slot */
    systemFont = getSystemFont ();
}

/**
 * Invokes platform specific functionality to allocate a new GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Device</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param data the platform specific GC data
 * @return the platform specific GC handle
 */
public abstract GdkGC* internal_new_GC (GCData data);

/**
 * Invokes platform specific functionality to dispose a GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Device</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param hDC the platform specific GC handle
 * @param data the platform specific GC data
 */
public abstract void internal_dispose_GC (GdkGC* handle, GCData data);

/**
 * Returns <code>true</code> if the device has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the device.
 * When a device has been disposed, it is an error to
 * invoke any other method using the device.
 *
 * @return <code>true</code> when the device is disposed and <code>false</code> otherwise
 */
public bool isDisposed () {
    synchronized (Device.classinfo) {
        return disposed;
    }
}

/**
 * Loads the font specified by a file.  The font will be
 * present in the list of fonts available to the application.
 *
 * @param path the font file path
 * @return whether the font was successfully loaded
 *
 * @exception SWTException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if path is null</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Font
 *
 * @since 3.3
 */
public bool loadFont (String path) {
    checkDevice();
    if (path is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return cast(bool) OS.FcConfigAppFontAddFile (null, path.toStringzValidPtr());
}

private static extern(C) void logFunction (char* log_domain, int log_level, char* message, void* user_data) {
    Device dev = cast(Device)user_data;
    if (dev.warningLevel is 0) {
        if (DEBUG || dev.debugging) {
            ExceptionPrintStackTrace(new Exception (""));
        }
        OS.g_log_default_handler (log_domain, log_level, message, user_data);
    }
    return;
}

void new_Object (Object object) {
    synchronized (trackingLock) {
        for (int i=0; i<objects.length; i++) {
            if (objects [i] is null) {
                objects [i] = object;
                errors [i] = new Exception ("");
                return;
            }
        }
        Object [] newObjects = new Object [objects.length + 128];
        System.arraycopy (objects, 0, newObjects, 0, objects.length);
        newObjects [objects.length] = object;
        objects = newObjects;
        Exception [] newErrors = new Exception [errors.length + 128];
        System.arraycopy (errors, 0, newErrors, 0, errors.length);
        newErrors [errors.length] = new Exception ("");
        errors = newErrors;
    }
}

static void register (Device device) {
    synchronized {
        for (int i=0; i<Devices.length; i++) {
            if (Devices [i] is null) {
                Devices [i] = device;
                return;
            }
        }
        Device [] newDevices = new Device [Devices.length + 4];
        System.arraycopy (Devices, 0, newDevices, 0, Devices.length);
        newDevices [Devices.length] = device;
        Devices = newDevices;
    }
}

/**
 * Releases any internal resources back to the operating
 * system and clears all fields except the device handle.
 * <p>
 * When a device is destroyed, resources that were acquired
 * on behalf of the programmer need to be returned to the
 * operating system.  For example, if the device allocated a
 * font to be used as the system font, this font would be
 * freed in <code>release</code>.  Also,to assist the garbage
 * collector and minimize the amount of memory that is not
 * reclaimed when the programmer keeps a reference to a
 * disposed device, all fields except the handle are zero'd.
 * The handle is needed by <code>destroy</code>.
 * </p>
 * This method is called before <code>destroy</code>.
 * </p><p>
 * If subclasses reimplement this method, they must
 * call the <code>super</code> implementation.
 * </p>
 *
 * @see #dispose
 * @see #destroy
 */
protected void release () {
    if (shellHandle !is null) OS.gtk_widget_destroy(shellHandle);
    shellHandle = null;

    if (gdkColors !is null) {
        auto colormap = OS.gdk_colormap_get_system();
        for (int i = 0; i < gdkColors.length; i++) {
            GdkColor* color = gdkColors [i];
            if (color !is null) {
                while (colorRefCount [i] > 0) {
                    OS.gdk_colormap_free_colors(colormap, color, 1);
                    --colorRefCount [i];
                }
            }
        }
    }
    gdkColors = null;
    colorRefCount = null;
    COLOR_BLACK = COLOR_DARK_RED = COLOR_DARK_GREEN = COLOR_DARK_YELLOW = COLOR_DARK_BLUE =
    COLOR_DARK_MAGENTA = COLOR_DARK_CYAN = COLOR_GRAY = COLOR_DARK_GRAY = COLOR_RED =
    COLOR_GREEN = COLOR_YELLOW = COLOR_BLUE = COLOR_MAGENTA = COLOR_CYAN = COLOR_WHITE = null;

    if (emptyTab !is null ) OS.pango_tab_array_free(emptyTab);
    emptyTab = null;

    /* Free the GTK error and warning handler */
    if (xDisplay !is null) {
        for (int i=0; i<handler_ids.length; i++) {
            if (handler_ids [i] !is 0 ) {
                OS.g_log_remove_handler (log_domains [i].toStringzValidPtr(), handler_ids [i]);
                handler_ids [i] = 0;
            }
        }
        //logCallback.dispose ();  logCallback = null;
        handler_ids = null;  log_domains = null;
        //logProcFld = 0;
    }
}

/**
 * If the underlying window system supports printing warning messages
 * to the console, setting warnings to <code>false</code> prevents these
 * messages from being printed. If the argument is <code>true</code> then
 * message printing is not blocked.
 *
 * @param warnings <code>true</code>if warnings should be printed, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setWarnings (bool warnings) {
    checkDevice ();
    if (warnings) {
        if (--warningLevel is 0) {
            if (debugging) return;
            for (int i=0; i<handler_ids.length; i++) {
                if (handler_ids [i] !is 0) {
                    OS.g_log_remove_handler (log_domains [i].toStringzValidPtr(), handler_ids [i]);
                    handler_ids [i] = 0;
                }
            }
        }
    } else {
        if (warningLevel++ is 0) {
            if (debugging) return;
            int flags = OS.G_LOG_LEVEL_MASK | OS.G_LOG_FLAG_FATAL | OS.G_LOG_FLAG_RECURSION;
            for (int i=0; i<log_domains.length; i++) {
                handler_ids [i] = OS.g_log_set_handler (log_domains [i].toStringzValidPtr(), flags, & logFunction, cast(void*)this );
            }
        }
    }
}

private static extern(C) int XErrorProcFunc (void* xDisplay, org.eclipse.swt.internal.gtk.OS.XErrorEvent* xErrorEvent) {
    Device device = findDevice (xDisplay);
    if (device !is null) {
        if (device.warningLevel is 0) {
            if (DEBUG || device.debugging) {
                foreach( msg; (new Exception ("")).info ){
                    getDwtLogger().error( __FILE__, __LINE__,  "{}", msg );
                }
            }
            //PORTING_FIXME ??
            //OS.Call (XErrorProc, xDisplay, xErrorEvent);
        }
    } else {
        if (DEBUG) (new SWTError ()).printStackTrace ();
        //PORTING_FIXME ??
        //OS.Call (XErrorProc, xDisplay, xErrorEvent);
    }
    return 0;
}

private static extern(C)  int XIOErrorProcFunc (void* xDisplay) {
    Device device = findDevice (xDisplay);
    if (device !is null) {
        if (DEBUG || device.debugging) {
            foreach( msg; (new Exception ("")).info ){
                getDwtLogger().error( __FILE__, __LINE__,  "trc {}", msg );
            }
        }
    } else {
        if (DEBUG) {
            foreach( msg; (new Exception ("")).info ){
                getDwtLogger().error( __FILE__, __LINE__,  "{}", msg );
            }
        }
    }
    //PORTING_FIXME ??
    //OS.Call (XIOErrorProc, xDisplay, 0);
    return 0;
}

}
