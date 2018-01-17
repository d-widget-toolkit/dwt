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

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.gdip.Gdip;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Path;
import org.eclipse.swt.graphics.Pattern;
import org.eclipse.swt.graphics.Region;
import org.eclipse.swt.graphics.TextLayout;
import org.eclipse.swt.graphics.Transform;
import org.eclipse.swt.graphics.Drawable;
import org.eclipse.swt.graphics.DeviceData;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Color;

import java.lang.Runnable;
import java.lang.System;

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

    private struct CallbackData {
        Device device;
        bool scalable;
    }

    /* Debugging */
    public static bool DEBUG = true;
    bool debug_;
    bool tracking;
    Exception [] errors;
    Object [] objects;
    Object trackingLock;

    /**
     * Palette
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public HPALETTE hPalette;
    int [] colorRefCount;

    /* System Font */
    Font systemFont;

    /* Font Enumeration */
    int nFonts = 256;
    LOGFONT* [] logFonts;
    TEXTMETRIC metrics;
    int[] pixels;

    /* Scripts */
    SCRIPT_PROPERTIES*[] scripts;

    /* Advanced Graphics */
    ULONG_PTR gdipToken;

    bool disposed;

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
    mixin(gshared!(`protected static Device CurrentDevice;`));
    mixin(gshared!(`protected static Runnable DeviceFinder;`));


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
    synchronized (Device.classinfo) {
        debug_ = DEBUG;
        tracking = DEBUG;
        if (data !is null) {
            debug_ = data.debug_;
            tracking = data.tracking;
        }
        if (tracking) {
            errors = new Exception [128];
            objects = new Object [128];
            trackingLock = new Object ();
        }
        create (data);
        init_ ();
        gdipToken = 0;
    }
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

void checkGDIP() {
    if (gdipToken) return;
    int oldErrorMode = 0;
    static if (!OS.IsWinCE) oldErrorMode = OS.SetErrorMode (OS.SEM_FAILCRITICALERRORS);
    try {
        ULONG_PTR token;
        GdiplusStartupInput input;
        input.GdiplusVersion = 1;
        if (Gdip.GdiplusStartup ( &token, &input, null ) is 0) {
            gdipToken = token;
        }
    } catch (Exception t) {
        SWT.error (SWT.ERROR_NO_GRAPHICS_LIBRARY, t, " [GDI+ is required]"); //$NON-NLS-1$
    } finally {
        if (!OS.IsWinCE) OS.SetErrorMode (oldErrorMode);
    }
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

int computePixels(float height) {
    auto hDC = internal_new_GC (null);
    int pixels = -cast(int)(0.5f + (height * OS.GetDeviceCaps(hDC, OS.LOGPIXELSY) / 72f));
    internal_dispose_GC (hDC, null);
    return pixels;
}

float computePoints(LOGFONT* logFont, HFONT hFont) {
    auto hDC = internal_new_GC (null);
    int logPixelsY = OS.GetDeviceCaps(hDC, OS.LOGPIXELSY);
    int pixels = 0;
    if (logFont.lfHeight > 0) {
        /*
         * Feature in Windows. If the lfHeight of the LOGFONT structure
         * is positive, the lfHeight measures the height of the entire
         * cell, including internal leading, in logical units. Since the
         * height of a font in points does not include the internal leading,
         * we must subtract the internal leading, which requires a TEXTMETRIC.
         */
        auto oldFont = OS.SelectObject(hDC, hFont);
        TEXTMETRIC* lptm = new TEXTMETRIC();
        OS.GetTextMetrics(hDC, lptm);
        OS.SelectObject(hDC, oldFont);
        pixels = logFont.lfHeight - lptm.tmInternalLeading;
    } else {
        pixels = -logFont.lfHeight;
    }
    internal_dispose_GC (hDC, null);
    return pixels * 72f / logPixelsY;
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
        disposed = true;
        if (tracking) {
            synchronized (trackingLock) {
                printErrors ();
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

static extern(Windows) int EnumFontFamFunc (ENUMLOGFONT* lpelfe, NEWTEXTMETRIC* lpntme, int FontType, LPARAM lParam) {
    auto cbdata = cast(CallbackData*)lParam;
    return cbdata.device.EnumFontFamProc( lpelfe, lpntme, FontType, cbdata.scalable );
}

int EnumFontFamProc (ENUMLOGFONT* lpelfe, NEWTEXTMETRIC* lpntme, DWORD FontType, bool scalable) {
    bool isScalable = (FontType & OS.RASTER_FONTTYPE) is 0;
    if (isScalable is scalable) {
        /* Add the log font to the list of log fonts */
        if (nFonts is logFonts.length) {
            LOGFONT* [] newLogFonts = new LOGFONT* [logFonts.length + 128];
            SimpleType!(LOGFONT*).arraycopy (logFonts, 0, newLogFonts, 0, nFonts);
            logFonts = newLogFonts;
            int[] newPixels = new int[newLogFonts.length];
            System.arraycopy (pixels, 0, newPixels, 0, nFonts);
            pixels = newPixels;
        }
        LOGFONT* logFont = logFonts [nFonts];
        if (logFont is null) logFont = new LOGFONT ();
        *logFont = *cast(LOGFONT*)lpelfe;
        logFonts [nFonts] = logFont;
        if (logFont.lfHeight > 0) {
            /*
             * Feature in Windows. If the lfHeight of the LOGFONT structure
             * is positive, the lfHeight measures the height of the entire
             * cell, including internal leading, in logical units. Since the
             * height of a font in points does not include the internal leading,
             * we must subtract the internal leading, which requires a TEXTMETRIC,
             * which in turn requires font creation.
             */
            metrics = *cast(TEXTMETRIC*)lpntme;
            pixels[nFonts] = logFont.lfHeight - metrics.tmInternalLeading;
        } else {
            pixels[nFonts] = -logFont.lfHeight;
        }
        nFonts++;
    }
    return 1;
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
    auto hDC = internal_new_GC (null);
    int width = OS.GetDeviceCaps (hDC, OS.HORZRES);
    int height = OS.GetDeviceCaps (hDC, OS.VERTRES);
    internal_dispose_GC (hDC, null);
    return new Rectangle (0, 0, width, height);
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
    data.debug_ = debug_;
    data.tracking = tracking;
    if (tracking) {
        synchronized (trackingLock) {
            int count = 0, length = cast(int)/*64bit*/objects.length;
            for (int i=0; i<length; i++) {
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
        data.objects = new Object [0];
        data.errors = new Exception [0];
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
    auto hDC = internal_new_GC (null);
    int bits = OS.GetDeviceCaps (hDC, OS.BITSPIXEL);
    int planes = OS.GetDeviceCaps (hDC, OS.PLANES);
    internal_dispose_GC (hDC, null);
    return bits * planes;
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
    auto hDC = internal_new_GC (null);
    int dpiX = OS.GetDeviceCaps (hDC, OS.LOGPIXELSX);
    int dpiY = OS.GetDeviceCaps (hDC, OS.LOGPIXELSY);
    internal_dispose_GC (hDC, null);
    return new Point (dpiX, dpiY);
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
public FontData [] getFontList (String faceName, bool scalable) {
    checkDevice ();

    /* Create the callback */
    CallbackData cbdata;
    cbdata.device = this;

    /* Initialize the instance variables */
    metrics = TEXTMETRIC.init;
    pixels = new int[nFonts];
    logFonts = new LOGFONT* [nFonts];
    for (int i=0; i<logFonts.length; i++) {
        logFonts [i] = new LOGFONT();
    }
    nFonts = 0;

    /* Enumerate */
    int offset = 0;
    auto hDC = internal_new_GC (null);
    if (faceName is null) {
        /* The user did not specify a face name, so they want all versions of all available face names */
        cbdata.scalable = scalable;
        OS.EnumFontFamilies (hDC, null, &EnumFontFamFunc, cast(LPARAM)&cbdata );

        /**
         * For bitmapped fonts, EnumFontFamilies only enumerates once for each font, regardless
         * of how many styles are available. If the user wants bitmapped fonts, enumerate on
         * each face name now.
         */
        offset = nFonts;
        for (int i=0; i<offset; i++) {
            LOGFONT* lf = logFonts [i];
            /**
             * Bug in Windows 98. When EnumFontFamiliesEx is called with a specified face name, it
             * should enumerate for each available style of that font. Instead, it only enumerates
             * once. The fix is to call EnumFontFamilies, which works as expected.
             */
            cbdata.scalable = scalable;
            static if (OS.IsUnicode) {
                OS.EnumFontFamiliesW (hDC, (cast(LOGFONTW*)lf).lfFaceName.ptr, &EnumFontFamFunc, cast(LPARAM)&cbdata);
            } else {
                OS.EnumFontFamiliesA (hDC, (cast(LOGFONTA*)lf).lfFaceName.ptr, &EnumFontFamFunc, cast(LPARAM)&cbdata);
            }
        }
    } else {
        /* Use the character encoding for the default locale */
        /**
         * Bug in Windows 98. When EnumFontFamiliesEx is called with a specified face name, it
         * should enumerate for each available style of that font. Instead, it only enumerates
         * once. The fix is to call EnumFontFamilies, which works as expected.
         */
        cbdata.scalable = scalable;
        OS.EnumFontFamilies (hDC, .StrToTCHARz(faceName), &EnumFontFamFunc, cast(LPARAM)&cbdata);
    }
    int logPixelsY = OS.GetDeviceCaps(hDC, OS.LOGPIXELSY);
    internal_dispose_GC (hDC, null);

    /* Create the fontData from the logfonts */
    int count = 0;
    FontData [] result = new FontData [nFonts - offset];
    for (int i=offset; i<nFonts; i++) {
        FontData fd = FontData.win32_new (logFonts [i], pixels [i] * 72f / logPixelsY);
        int j;
        for (j = 0; j < count; j++) {
            if (fd == result [j]) break;
        }
        if (j is count) result [count++] = fd;
    }
    if (count !is result.length) {
        FontData [] newResult = new FontData [count];
        System.arraycopy (result, 0, newResult, 0, count);
        result = newResult;
    }

    /* Clean up */
    logFonts = null;
    pixels = null;
    metrics = TEXTMETRIC.init;
    return result;
}

String getLastError () {
    int error = OS.GetLastError();
    if (error is 0) return ""; //$NON-NLS-1$
    return " [GetLastError=0x" ~ .toHex(error) ~ "]"; //$NON-NLS-1$ //$NON-NLS-2$
}

String getLastErrorText () {
    int error = OS.GetLastError();
    if (error is 0) return ""; //$NON-NLS-1$
    TCHAR* buffer = null;
    int dwFlags = OS.FORMAT_MESSAGE_ALLOCATE_BUFFER | OS.FORMAT_MESSAGE_FROM_SYSTEM | OS.FORMAT_MESSAGE_IGNORE_INSERTS;
    int length = OS.FormatMessage(dwFlags, null, error, OS.LANG_USER_DEFAULT, cast(TCHAR*)&buffer, 0, null);
    String errorNum = ("[GetLastError=") ~ .toHex(error) ~ "] ";
    if (length == 0) return errorNum;
    String buffer1 = .TCHARzToStr(buffer, length);
    if ( *buffer != 0)
        OS.LocalFree(cast(HLOCAL)buffer);
    return errorNum ~ buffer1;
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
    int pixel = 0x00000000;
    switch (id) {
        case SWT.COLOR_WHITE:               pixel = 0x00FFFFFF;  break;
        case SWT.COLOR_BLACK:               pixel = 0x00000000;  break;
        case SWT.COLOR_RED:                 pixel = 0x000000FF;  break;
        case SWT.COLOR_DARK_RED:            pixel = 0x00000080;  break;
        case SWT.COLOR_GREEN:               pixel = 0x0000FF00;  break;
        case SWT.COLOR_DARK_GREEN:          pixel = 0x00008000;  break;
        case SWT.COLOR_YELLOW:              pixel = 0x0000FFFF;  break;
        case SWT.COLOR_DARK_YELLOW:         pixel = 0x00008080;  break;
        case SWT.COLOR_BLUE:                pixel = 0x00FF0000;  break;
        case SWT.COLOR_DARK_BLUE:           pixel = 0x00800000;  break;
        case SWT.COLOR_MAGENTA:             pixel = 0x00FF00FF;  break;
        case SWT.COLOR_DARK_MAGENTA:        pixel = 0x00800080;  break;
        case SWT.COLOR_CYAN:                pixel = 0x00FFFF00;  break;
        case SWT.COLOR_DARK_CYAN:           pixel = 0x00808000;  break;
        case SWT.COLOR_GRAY:                pixel = 0x00C0C0C0;  break;
        case SWT.COLOR_DARK_GRAY:           pixel = 0x00808080;  break;
        default:
    }
    return Color.win32_new (this, pixel);
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
    auto hFont = OS.GetStockObject (OS.SYSTEM_FONT);
    return Font.win32_new (this, hFont);
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
    return false;
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
    if (debug_) {
        static if (!OS.IsWinCE) OS.GdiSetBatchLimit(1);
    }

    /* Initialize the system font slot */
    systemFont = getSystemFont();

    /* Initialize scripts list */
    static if (!OS.IsWinCE) {
        SCRIPT_PROPERTIES** ppSp;
        int piNumScripts;
        OS.ScriptGetProperties (&ppSp, &piNumScripts);
        scripts = ppSp[ 0 .. piNumScripts ].dup;
    }

    /*
     * If we're not on a device which supports palettes,
     * don't create one.
     */
    auto hDC = internal_new_GC (null);
    int rc = OS.GetDeviceCaps (hDC, OS.RASTERCAPS);
    int bits = OS.GetDeviceCaps (hDC, OS.BITSPIXEL);
    int planes = OS.GetDeviceCaps (hDC, OS.PLANES);

    bits *= planes;
    if ((rc & OS.RC_PALETTE) is 0 || bits !is 8) {
        internal_dispose_GC (hDC, null);
        return;
    }

    int numReserved = OS.GetDeviceCaps (hDC, OS.NUMRESERVED);
    int numEntries = OS.GetDeviceCaps (hDC, OS.SIZEPALETTE);

    static if (OS.IsWinCE) {
        /*
        * Feature on WinCE.  For some reason, certain 8 bit WinCE
        * devices return 0 for the number of reserved entries in
        * the system palette.  Their system palette correctly contains
        * the usual 20 system colors.  The workaround is to assume
        * there are 20 reserved system colors instead of 0.
        */
        if (numReserved is 0 && numEntries >= 20) numReserved = 20;
    }

    /* Create the palette and reference counter */
    colorRefCount = new int [numEntries];

    /* 4 bytes header + 4 bytes per entry * numEntries entries */
    byte [] logPalette = new byte [4 + 4 * numEntries];

    /* 2 bytes = special header */
    logPalette [0] = 0x00;
    logPalette [1] = 0x03;

    /* 2 bytes = number of colors, LSB first */
    logPalette [2] = 0;
    logPalette [3] = 1;

    /*
    * Create a palette which contains the system entries
    * as they are located in the system palette.  The
    * MSDN article 'Memory Device Contexts' describes
    * where system entries are located.  On an 8 bit
    * display with 20 reserved colors, the system colors
    * will be the first 10 entries and the last 10 ones.
    */
    byte[] lppe = new byte [4 * numEntries];
    OS.GetSystemPaletteEntries (hDC, 0, numEntries, cast(PALETTEENTRY*)lppe.ptr);
    /* Copy all entries from the system palette */
    System.arraycopy (lppe, 0, logPalette, 4, 4 * numEntries);
    /* Lock the indices corresponding to the system entries */
    for (int i = 0; i < numReserved / 2; i++) {
        colorRefCount [i] = 1;
        colorRefCount [numEntries - 1 - i] = 1;
    }
    internal_dispose_GC (hDC, null);
    hPalette = OS.CreatePalette (cast(LOGPALETTE*)logPalette.ptr);
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
public abstract HDC internal_new_GC (GCData data);

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
public abstract void internal_dispose_GC (HDC hDC, GCData data);

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
    if (OS.IsWinNT && OS.WIN32_VERSION >= OS.VERSION (4, 10)) {
        //TCHAR lpszFilename = new TCHAR (0, path, true);
        return OS.AddFontResourceEx ( .StrToTCHARz(path), OS.FR_PRIVATE, null) !is 0;
    }
    return false;
}

void new_Object (Object object) {
    synchronized (trackingLock) {
        for (int i=0; i<objects.length; i++) {
            if (objects [i] is null) {
                objects [i] = object;
                errors [i] = new Exception ( "" );
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

void printErrors () {
    if (!DEBUG) return;
    if (tracking) {
        synchronized (trackingLock) {
            if (objects is null || errors is null) return;
            int objectCount = 0;
            int colors = 0, cursors = 0, fonts = 0, gcs = 0, images = 0;
            int paths = 0, patterns = 0, regions = 0, textLayouts = 0, transforms = 0;
            for (int i=0; i<objects.length; i++) {
                Object object = objects [i];
                if (object !is null) {
                    objectCount++;
                    if (null !is cast(Color)object ) colors++;
                    if (null !is cast(Cursor)object ) cursors++;
                    if (null !is cast(Font)object ) fonts++;
                    if (null !is cast(GC)object ) gcs++;
                    if (null !is cast(Image)object ) images++;
                    if (null !is cast(Path)object ) paths++;
                    if (null !is cast(Pattern)object ) patterns++;
                    if (null !is cast(Region)object ) regions++;
                    if (null !is cast(TextLayout)object ) textLayouts++;
                    if (null !is cast(Transform)object ) transforms++;
                }
            }
            if (objectCount !is 0) {
                String string = "Summary: ";
                if (colors !is 0) string ~= String_valueOf(colors) ~ " Color(s), ";
                if (cursors !is 0) string ~= String_valueOf(cursors) ~ " Cursor(s), ";
                if (fonts !is 0) string ~= String_valueOf(fonts) ~ " Font(s), ";
                if (gcs !is 0) string ~= String_valueOf(gcs) ~ " GC(s), ";
                if (images !is 0) string ~= String_valueOf(images) ~ " Image(s), ";
                if (paths !is 0) string ~= String_valueOf(paths) ~ " Path(s), ";
                if (patterns !is 0) string ~= String_valueOf(patterns) ~ " Pattern(s), ";
                if (regions !is 0) string ~= String_valueOf(regions) ~ " Region(s), ";
                if (textLayouts !is 0) string ~= String_valueOf(textLayouts) ~ " TextLayout(s), ";
                if (transforms !is 0) string ~= String_valueOf(transforms) ~ " Transforms(s), ";
                if (string.length !is 0) {
                    string = string.substring (0, cast(int)/*64bit*/string.length - 2);
                    getDwtLogger().error (  __FILE__, __LINE__, "{}", string);
                }
                for (int i=0; i<errors.length; i++) {
                    if (errors [i] !is null) ExceptionPrintStackTrace( errors [i]);
                }
            }
        }
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
    if (gdipToken) {
        Gdip.GdiplusShutdown ( gdipToken );
    }
    gdipToken = 0; // TODO: assignment of 0 might not be valid for token
    scripts = null;
    if (hPalette !is null) OS.DeleteObject (hPalette);
    hPalette = null;
    colorRefCount = null;
    logFonts = null;
    nFonts = 0;
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
}

}


