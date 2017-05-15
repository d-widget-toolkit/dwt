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
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Widget;

import org.eclipse.swt.printing.Printer;
import org.eclipse.swt.printing.PrinterData;

import java.lang.all;

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
    super (parent, style);
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

override
protected void checkSubclass() {
    String name = this.classinfo.name;
    String validName = PrintDialog.classinfo.name;
    if (validName!=/*eq*/name) {
        SWT.error(SWT.ERROR_INVALID_SUBCLASS);
    }
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
    PRINTDLG pd;
    pd.lStructSize = PRINTDLG.sizeof;
    Control parent = getParent();
    if (parent !is null) pd.hwndOwner = parent.handle;
    void* lpInitData;
    auto hHeap = OS.GetProcessHeap();
    if (printerData !is null) {
        byte[] buffer = printerData.otherData;
        if (buffer !is null && buffer.length !is 0) {
            /* If user setup info from a previous print dialog was specified, restore the DEVMODE struct. */
            lpInitData = OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, buffer.length);
            OS.MoveMemory(lpInitData, buffer.ptr, buffer.length);
            pd.hDevMode = lpInitData;
        }
    }
    pd.Flags = OS.PD_USEDEVMODECOPIESANDCOLLATE;
    if (printToFile) pd.Flags |= OS.PD_PRINTTOFILE;
    switch (scope_) {
        case PrinterData.PAGE_RANGE: pd.Flags |= OS.PD_PAGENUMS; break;
        case PrinterData.SELECTION: pd.Flags |= OS.PD_SELECTION; break;
        default: pd.Flags |= OS.PD_ALLPAGES;
    }
    pd.nMinPage = 1;
    pd.nMaxPage = cast(ushort)-1;
    pd.nFromPage = cast(short) Math.min (0xFFFF, Math.max (1, startPage));
    pd.nToPage = cast(short) Math.min (0xFFFF, Math.max (1, endPage));

    Display display = parent.getDisplay();
    Shell [] shells = display.getShells();
    if ((getStyle() & (SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL)) !is 0) {
        for (int i=0; i<shells.length; i++) {
            if (shells[i].isEnabled() && shells[i] !is parent) {
                shells[i].setEnabled(false);
            } else {
                shells[i] = null;
            }
        }
    }
    PrinterData data = null;
    String key = "org.eclipse.swt.internal.win32.runMessagesInIdle"; //$NON-NLS-1$
    Object oldValue = display.getData(key);
    display.setData(key, new Boolean(true));
    bool success = cast(bool)OS.PrintDlg(&pd);
    display.setData(key, oldValue);
    if ((getStyle() & (SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL)) !is 0) {
        for (int i=0; i<shells.length; i++) {
            if (shells[i] !is null && !shells[i].isDisposed ()) {
                shells[i].setEnabled(true);
            }
        }
    }

    if (success) {
        /* Get driver and device from the DEVNAMES struct */
        auto hMem = pd.hDevNames;
        /* Ensure size is a multiple of 2 bytes on UNICODE platforms */
        auto size = OS.GlobalSize(hMem) / TCHAR.sizeof * TCHAR.sizeof;
        auto ptr = OS.GlobalLock(hMem);
        short[4] offsets;
        OS.MoveMemory(offsets.ptr, ptr, 2 * offsets.length);
        TCHAR[] buffer = NewTCHARs(0, size);
        OS.MoveMemory(buffer.ptr, ptr, size);
        OS.GlobalUnlock(hMem);

        int driverOffset = offsets[0];
        int i = 0;
        while (driverOffset + i < size) {
            if (buffer[driverOffset + i] is 0) break;
            i++;
        }
        String driver = TCHARsToStr( buffer[driverOffset .. driverOffset+i] );

        int deviceOffset = offsets[1];
        i = 0;
        while (deviceOffset + i < size) {
            if (buffer[deviceOffset + i] is 0) break;
            i++;
        }
        String device = TCHARsToStr( buffer[deviceOffset .. deviceOffset+i] );

        int outputOffset = offsets[2];
        i = 0;
        while (outputOffset + i < size) {
            if (buffer[outputOffset + i] is 0) break;
            i++;
        }
        String output = TCHARsToStr( buffer[outputOffset .. outputOffset+i] );

        /* Create PrinterData object and set fields from PRINTDLG */
        data = new PrinterData(driver, device);
        if ((pd.Flags & OS.PD_PAGENUMS) !is 0) {
            data.scope_ = PrinterData.PAGE_RANGE;
            data.startPage = pd.nFromPage & 0xFFFF;
            data.endPage = pd.nToPage & 0xFFFF;
        } else if ((pd.Flags & OS.PD_SELECTION) !is 0) {
            data.scope_ = PrinterData.SELECTION;
        }
        data.printToFile = (pd.Flags & OS.PD_PRINTTOFILE) !is 0;
        if (data.printToFile) data.fileName = output;
        data.copyCount = pd.nCopies;
        data.collate = (pd.Flags & OS.PD_COLLATE) !is 0;

        /* Bulk-save the printer-specific settings in the DEVMODE struct */
        hMem = pd.hDevMode;
        size = OS.GlobalSize(hMem);
        ptr = OS.GlobalLock(hMem);
        data.otherData = new byte[size];
        OS.MoveMemory(data.otherData.ptr, ptr, size);
        OS.GlobalUnlock(hMem);
        if (lpInitData !is null) OS.HeapFree(hHeap, 0, lpInitData);

        endPage = data.endPage;
        printToFile = data.printToFile;
        scope_ = data.scope_;
        startPage = data.startPage;
    }
    return data;
}
}
