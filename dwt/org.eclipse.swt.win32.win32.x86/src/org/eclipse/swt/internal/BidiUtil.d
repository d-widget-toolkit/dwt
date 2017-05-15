/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.swt.internal.BidiUtil;


import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Control;
import java.lang.all;
import java.lang.Runnable;

/*
 * Wraps Win32 API used to bidi enable the StyledText widget.
 */
public class BidiUtil {

    // Keyboard language ids
    public static const int KEYBOARD_NON_BIDI = 0;
    public static const int KEYBOARD_BIDI = 1;

    // bidi flag
    static int isBidiPlatform_ = -1;

    // getRenderInfo flag values
    public static const int CLASSIN = 1;
    public static const int LINKBEFORE = 2;
    public static const int LINKAFTER = 4;

    // variables used for providing a listener mechanism for keyboard language
    // switching
    static Runnable[HWND] languageMap;
    static Runnable[HWND] keyMap;
    static WNDPROC[HWND] oldProcMap;
    /*
     * This code is intentionally commented.  In order
     * to support CLDC, .class cannot be used because
     * it does not compile on some Java compilers when
     * they are targeted for CLDC.
     */
    //  static Callback callback = new Callback (BidiUtil.class, "windowProc", 4);
    static const String CLASS_NAME = "org.eclipse.swt.internal.BidiUtil"; //$NON-NLS-1$
//     static this() {
//         try {
//             callback = new Callback (Class.forName (CLASS_NAME), "windowProc", 4); //$NON-NLS-1$
//             if (callback.getAddress () is 0) SWT.error (SWT.ERROR_NO_MORE_CALLBACKS);
//         } catch (ClassNotFoundException e) {}
//     }

    // GetCharacterPlacement constants
    static const int GCP_REORDER = 0x0002;
    static const int GCP_GLYPHSHAPE = 0x0010;
    static const int GCP_LIGATE = 0x0020;
    static const int GCP_CLASSIN = 0x00080000;
    static const byte GCPCLASS_ARABIC = 2;
    static const byte GCPCLASS_HEBREW = 2;
    static const byte GCPCLASS_LOCALNUMBER = 4;
    static const byte GCPCLASS_LATINNUMBER = 5;
    static const int GCPGLYPH_LINKBEFORE = 0x8000;
    static const int GCPGLYPH_LINKAFTER = 0x4000;
    // ExtTextOut constants
    static const int ETO_CLIPPED = 0x4;
    static const int ETO_GLYPH_INDEX = 0x0010;
    // Windows primary language identifiers
    static const int LANG_ARABIC = 0x01;
    static const int LANG_HEBREW = 0x0d;
    // code page identifiers
    static const String CD_PG_HEBREW = "1255"; //$NON-NLS-1$
    static const String CD_PG_ARABIC = "1256"; //$NON-NLS-1$
    // ActivateKeyboard constants
    static const int HKL_NEXT = 1;
    static const int HKL_PREV = 0;

    /*
     * Public character class constants are the same as Windows
     * platform constants.
     * Saves conversion of class array in getRenderInfo to arbitrary
     * constants for now.
     */
    public static const int CLASS_HEBREW = GCPCLASS_ARABIC;
    public static const int CLASS_ARABIC = GCPCLASS_HEBREW;
    public static const int CLASS_LOCALNUMBER = GCPCLASS_LOCALNUMBER;
    public static const int CLASS_LATINNUMBER = GCPCLASS_LATINNUMBER;
    public static const int REORDER = GCP_REORDER;
    public static const int LIGATE = GCP_LIGATE;
    public static const int GLYPHSHAPE = GCP_GLYPHSHAPE;

/**
 * Adds a language listener. The listener will get notified when the language of
 * the keyboard changes (via Alt-Shift on Win platforms).  Do this by creating a
 * window proc for the Control so that the window messages for the Control can be
 * monitored.
 * <p>
 *
 * @param hwnd the handle of the Control that is listening for keyboard language
 *  changes
 * @param runnable the code that should be executed when a keyboard language change
 *  occurs
 */
public static void addLanguageListener (HWND hwnd, Runnable runnable) {
    languageMap[hwnd] = runnable;
    subclass(hwnd);
}
public static void addLanguageListener (Control control, Runnable runnable) {
    addLanguageListener(control.handle, runnable);
}
/**
 * Proc used for OS.EnumSystemLanguageGroups call during isBidiPlatform test.
 */
static extern(Windows) int EnumSystemLanguageGroupsProc(uint lpLangGrpId, wchar* lpLangGrpIdString, wchar* lpLangGrpName, uint options, LONG_PTR lParam) {
    if (lpLangGrpId is OS.LGRPID_HEBREW) {
        isBidiPlatform_ = 1;
        return 0;
    }
    if (lpLangGrpId is OS.LGRPID_ARABIC) {
        isBidiPlatform_ = 1;
        return 0;
    }
    return 1;
}
/**
 * Wraps the ExtTextOut function.
 * <p>
 *
 * @param gc the gc to use for rendering
 * @param renderBuffer the glyphs to render as an array of characters
 * @param renderDx the width of each glyph in renderBuffer
 * @param x x position to start rendering
 * @param y y position to start rendering
 */
public static void drawGlyphs(GC gc, wchar[] renderBuffer, int[] renderDx, int x, int y) {
    int length_ = cast(int)/*64bit*/renderDx.length;

    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
        if (OS.GetLayout (gc.handle) !is 0) {
            reverse(renderDx);
            renderDx[length_-1]--;               //fixes bug 40006
            reverse(renderBuffer);
        }
    }
    // render transparently to avoid overlapping segments. fixes bug 40006
    int oldBkMode = OS.SetBkMode(gc.handle, OS.TRANSPARENT);
    OS.ExtTextOutW(gc.handle, x, y, ETO_GLYPH_INDEX , null, renderBuffer.ptr, cast(int)/*64bit*/renderBuffer.length, renderDx.ptr);
    OS.SetBkMode(gc.handle, oldBkMode);
}
/**
 * Return ordering and rendering information for the given text.  Wraps the GetFontLanguageInfo
 * and GetCharacterPlacement functions.
 * <p>
 *
 * @param gc the GC to use for measuring of this line, input parameter
 * @param text text that bidi data should be calculated for, input parameter
 * @param order an array of integers representing the visual position of each character in
 *  the text array, output parameter
 * @param classBuffer an array of integers representing the type (e.g., ARABIC, HEBREW,
 *  LOCALNUMBER) of each character in the text array, input/output parameter
 * @param dx an array of integers representing the pixel width of each glyph in the returned
 *  glyph buffer, output parameter
 * @param flags an integer representing rendering flag information, input parameter
 * @param offsets text segments that should be measured and reordered separately, input
 *  parameter. See org.eclipse.swt.custom.BidiSegmentEvent for details.
 * @return buffer with the glyphs that should be rendered for the given text
 */
public static String getRenderInfo(GC gc, String text, int[] order, byte[] classBuffer, int[] dx, int flags, int [] offsets) {
    auto fontLanguageInfo = OS.GetFontLanguageInfo(gc.handle);
    auto hHeap = OS.GetProcessHeap();
    int[8] lpCs;
    int cs = OS.GetTextCharset(gc.handle);
    bool isRightOriented = false;
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
        isRightOriented = OS.GetLayout(gc.handle) !is 0;
    }
    OS.TranslateCharsetInfo( cast(uint*)cs, cast(CHARSETINFO*)lpCs.ptr, OS.TCI_SRCCHARSET);
    StringT textBuffer = StrToTCHARs(lpCs[1], text, false);
    int byteCount = cast(int)/*64bit*/textBuffer.length;
    bool linkBefore = (flags & LINKBEFORE) is LINKBEFORE;
    bool linkAfter = (flags & LINKAFTER) is LINKAFTER;

    GCP_RESULTS result;
    result.lStructSize = GCP_RESULTS.sizeof;
    result.nGlyphs = byteCount;
    auto lpOrder = result.lpOrder = cast(uint*)OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, byteCount * 4);
    auto lpDx = result.lpDx = cast(int*)OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, byteCount * 4);
    auto lpClass = result.lpClass = cast(CHAR*)OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
    auto lpGlyphs = result.lpGlyphs = cast(wchar*)OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, byteCount * 2);

    // set required dwFlags
    int dwFlags = 0;
    int glyphFlags = 0;
    // Always reorder.  We assume that if we are calling this function we're
    // on a platform that supports bidi.  Fixes 20690.
    dwFlags |= GCP_REORDER;
    if ((fontLanguageInfo & GCP_LIGATE) is GCP_LIGATE) {
        dwFlags |= GCP_LIGATE;
        glyphFlags |= 0;
    }
    if ((fontLanguageInfo & GCP_GLYPHSHAPE) is GCP_GLYPHSHAPE) {
        dwFlags |= GCP_GLYPHSHAPE;
        if (linkBefore) {
            glyphFlags |= GCPGLYPH_LINKBEFORE;
        }
        if (linkAfter) {
            glyphFlags |= GCPGLYPH_LINKAFTER;
        }
    }
    byte[] lpGlyphs2;
    if (linkBefore || linkAfter) {
        lpGlyphs2 = new byte[2];
        lpGlyphs2[0]=cast(byte)glyphFlags;
        lpGlyphs2[1]=cast(byte)(glyphFlags >> 8);
    }
    else {
        lpGlyphs2 = [cast(byte) glyphFlags];
    }
    OS.MoveMemory(result.lpGlyphs, lpGlyphs2.ptr, lpGlyphs2.length);

    if ((flags & CLASSIN) is CLASSIN) {
        // set classification values for the substring
        dwFlags |= GCP_CLASSIN;
        OS.MoveMemory(result.lpClass, classBuffer.ptr, classBuffer.length);
    }

    wchar[] glyphBuffer = new wchar[result.nGlyphs];
    int glyphCount = 0;
    for (int i=0; i<offsets.length-1; i++) {
        int offset = offsets [i];
        int length_ = offsets [i+1] - offsets [i];

        // The number of glyphs expected is <= length (segment length);
        // the actual number returned may be less in case of Arabic ligatures.
        result.nGlyphs = length_;
        StringT textBuffer2 = StrToTCHARs(lpCs[1], text.substring(offset, offset + length_), false);
        OS.GetCharacterPlacement(gc.handle, textBuffer2.ptr, cast(int)/*64bit*/textBuffer2.length, 0, &result, dwFlags);

        if (dx !is null) {
            int [] dx2 = new int [result.nGlyphs];
            OS.MoveMemory(dx2.ptr, result.lpDx, dx2.length * 4);
            if (isRightOriented) {
                reverse(dx2);
            }
            System.arraycopy (dx2, 0, dx, glyphCount, dx2.length);
        }
        if (order !is null) {
            int [] order2 = new int [length_];
            OS.MoveMemory(order2.ptr, result.lpOrder, order2.length * 4);
            translateOrder(order2, glyphCount, isRightOriented);
            System.arraycopy (order2, 0, order, offset, length_);
        }
        if (classBuffer !is null) {
            byte [] classBuffer2 = new byte [length_];
            OS.MoveMemory(classBuffer2.ptr, result.lpClass, classBuffer2.length);
            System.arraycopy (classBuffer2, 0, classBuffer, offset, length_);
        }
        wchar[] glyphBuffer2 = new wchar[result.nGlyphs];
        OS.MoveMemory(glyphBuffer2.ptr, result.lpGlyphs, glyphBuffer2.length * 2);
        if (isRightOriented) {
            reverse(glyphBuffer2);
        }
        System.arraycopy (glyphBuffer2, 0, glyphBuffer, glyphCount, glyphBuffer2.length);
        glyphCount += glyphBuffer2.length;

        // We concatenate successive results of calls to GCP.
        // For Arabic, it is the only good method since the number of output
        // glyphs might be less than the number of input characters.
        // This assumes that the whole line is built by successive adjacent
        // segments without overlapping.
        result.lpOrder += length_ * 4;
        result.lpDx += length_ * 4;
        result.lpClass += length_;
        result.lpGlyphs += glyphBuffer2.length * 2;
    }

    /* Free the memory that was allocated. */
    OS.HeapFree(hHeap, 0, lpGlyphs);
    OS.HeapFree(hHeap, 0, lpClass);
    OS.HeapFree(hHeap, 0, lpDx);
    OS.HeapFree(hHeap, 0, lpOrder);
    return WCHARsToStr(glyphBuffer);
}
/**
 * Return bidi ordering information for the given text.  Does not return rendering
 * information (e.g., glyphs, glyph distances).  Use this method when you only need
 * ordering information.  Doing so will improve performance.  Wraps the
 * GetFontLanguageInfo and GetCharacterPlacement functions.
 * <p>
 *
 * @param gc the GC to use for measuring of this line, input parameter
 * @param text text that bidi data should be calculated for, input parameter
 * @param order an array of integers representing the visual position of each character in
 *  the text array, output parameter
 * @param classBuffer an array of integers representing the type (e.g., ARABIC, HEBREW,
 *  LOCALNUMBER) of each character in the text array, input/output parameter
 * @param flags an integer representing rendering flag information, input parameter
 * @param offsets text segments that should be measured and reordered separately, input
 *  parameter. See org.eclipse.swt.custom.BidiSegmentEvent for details.
 */
public static void getOrderInfo(GC gc, String text, int[] order, byte[] classBuffer, int flags, int [] offsets) {
    int fontLanguageInfo = OS.GetFontLanguageInfo(gc.handle);
    auto hHeap = OS.GetProcessHeap();
    int[8] lpCs;
    int cs = OS.GetTextCharset(gc.handle);
    OS.TranslateCharsetInfo( cast(uint*) cs, cast(CHARSETINFO*)lpCs.ptr, OS.TCI_SRCCHARSET);
    StringT textBuffer = StrToTCHARs(lpCs[1], text, false);
    int byteCount = cast(int)/*64bit*/textBuffer.length;
    bool isRightOriented = false;
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
        isRightOriented = OS.GetLayout(gc.handle) !is 0;
    }

    GCP_RESULTS result;
    result.lStructSize = GCP_RESULTS.sizeof;
    result.nGlyphs = byteCount;
    auto lpOrder = result.lpOrder = cast(uint*) OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, byteCount * 4);
    auto lpClass = result.lpClass = cast(CHAR*) OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, byteCount);

    // set required dwFlags, these values will affect how the text gets rendered and
    // ordered
    int dwFlags = 0;
    // Always reorder.  We assume that if we are calling this function we're
    // on a platform that supports bidi.  Fixes 20690.
    dwFlags |= GCP_REORDER;
    if ((fontLanguageInfo & GCP_LIGATE) is GCP_LIGATE) {
        dwFlags |= GCP_LIGATE;
    }
    if ((fontLanguageInfo & GCP_GLYPHSHAPE) is GCP_GLYPHSHAPE) {
        dwFlags |= GCP_GLYPHSHAPE;
    }
    if ((flags & CLASSIN) is CLASSIN) {
        // set classification values for the substring, classification values
        // can be specified on input
        dwFlags |= GCP_CLASSIN;
        OS.MoveMemory(result.lpClass, classBuffer.ptr, classBuffer.length);
    }

    int glyphCount = 0;
    for (int i=0; i<offsets.length-1; i++) {
        int offset = offsets [i];
        int length_ = offsets [i+1] - offsets [i];
        // The number of glyphs expected is <= length (segment length);
        // the actual number returned may be less in case of Arabic ligatures.
        result.nGlyphs = length_;
        StringT textBuffer2 = StrToTCHARs(lpCs[1], text.substring(offset, offset + length_), false);
        OS.GetCharacterPlacement(gc.handle, textBuffer2.ptr, cast(int)/*64bit*/textBuffer2.length, 0, &result, dwFlags);

        if (order !is null) {
            int [] order2 = new int [length_];
            OS.MoveMemory(order2.ptr, result.lpOrder, order2.length * 4);
            translateOrder(order2, glyphCount, isRightOriented);
            System.arraycopy (order2, 0, order, offset, length_);
        }
        if (classBuffer !is null) {
            byte [] classBuffer2 = new byte [length_];
            OS.MoveMemory(classBuffer2.ptr, result.lpClass, classBuffer2.length);
            System.arraycopy (classBuffer2, 0, classBuffer, offset, length_);
        }
        glyphCount += result.nGlyphs;

        // We concatenate successive results of calls to GCP.
        // For Arabic, it is the only good method since the number of output
        // glyphs might be less than the number of input characters.
        // This assumes that the whole line is built by successive adjacent
        // segments without overlapping.
        result.lpOrder += length_ * 4;
        result.lpClass += length_;
    }

    /* Free the memory that was allocated. */
    OS.HeapFree(hHeap, 0, lpClass);
    OS.HeapFree(hHeap, 0, lpOrder);
}
/**
 * Return bidi attribute information for the font in the specified gc.
 * <p>
 *
 * @param gc the gc to query
 * @return bitwise OR of the REORDER, LIGATE and GLYPHSHAPE flags
 *  defined by this class.
 */
public static int getFontBidiAttributes(GC gc) {
    int fontStyle = 0;
    int fontLanguageInfo = OS.GetFontLanguageInfo(gc.handle);
    if (((fontLanguageInfo & GCP_REORDER) !is 0)) {
        fontStyle |= REORDER;
    }
    if (((fontLanguageInfo & GCP_LIGATE) !is 0)) {
        fontStyle |= LIGATE;
    }
    if (((fontLanguageInfo & GCP_GLYPHSHAPE) !is 0)) {
        fontStyle |= GLYPHSHAPE;
    }
    return fontStyle;
}
/**
 * Return the active keyboard language type.
 * <p>
 *
 * @return an integer representing the active keyboard language (KEYBOARD_BIDI,
 *  KEYBOARD_NON_BIDI)
 */
public static int getKeyboardLanguage() {
    auto layout = OS.GetKeyboardLayout(0);
    int langID = OS.PRIMARYLANGID(OS.LOWORD(cast(size_t)layout));
    if (langID is LANG_HEBREW) return KEYBOARD_BIDI;
    if (langID is LANG_ARABIC) return KEYBOARD_BIDI;
    // return non-bidi for all other languages
    return KEYBOARD_NON_BIDI;
}
/**
 * Return the languages that are installed for the keyboard.
 * <p>
 *
 * @return integer array with an entry for each installed language
 */
static void*[] getKeyboardLanguageList() {
    int maxSize = 10;
    void*[] tempList = new void*[maxSize];
    int size = OS.GetKeyboardLayoutList(maxSize, tempList.ptr);
    void*[] list = new void*[size];
    System.arraycopy(tempList, 0, list, 0, size);
    return list;
}
/**
 * Return whether or not the platform supports a bidi language.  Determine this
 * by looking at the languages that are installed.
 * <p>
 *
 * @return true if bidi is supported, false otherwise. Always
 *  false on Windows CE.
 */
public static bool isBidiPlatform() {
    if (OS.IsWinCE) return false;
    if (isBidiPlatform_ !is -1) return isBidiPlatform_ is 1; // already set

    isBidiPlatform_ = 0;

    // The following test is a workaround for bug report 27629. On WinXP,
    // both bidi and complex script (e.g., Thai) languages must be installed
    // at the same time.  Since the bidi platform calls do not support
    // double byte characters, there is no way to run Eclipse using the
    // complex script languages on XP, so constrain this test to answer true
    // only if a bidi input language is defined.  Doing so will allow complex
    // script languages to work (e.g., one can install bidi and complex script
    // languages, but only install the Thai keyboard).
    if (!isKeyboardBidi()) return false;

    //Callback callback = null;
    //try {
        //callback = new Callback (Class.forName (CLASS_NAME), "EnumSystemLanguageGroupsProc", 5); //$NON-NLS-1$
        //int lpEnumSystemLanguageGroupsProc = callback.getAddress ();
        //if (lpEnumSystemLanguageGroupsProc is 0) SWT.error(SWT.ERROR_NO_MORE_CALLBACKS);
        OS.EnumSystemLanguageGroups(&EnumSystemLanguageGroupsProc, OS.LGRPID_INSTALLED, 0);
        //callback.dispose ();
    //} catch (ClassNotFoundException e) {
        //if (callback !is null) callback.dispose();
    //}
    if (isBidiPlatform_ is 1) return true;
    // need to look at system code page for NT & 98 platforms since EnumSystemLanguageGroups is
    // not supported for these platforms
    String codePage = String_valueOf(OS.GetACP());
    if (CD_PG_ARABIC==/*eq*/codePage || CD_PG_HEBREW==/*eq*/codePage) {
        isBidiPlatform_ = 1;
    }
    return isBidiPlatform_ is 1;
}
/**
 * Return whether or not the keyboard supports input of a bidi language.  Determine this
 * by looking at the languages that are installed for the keyboard.
 * <p>
 *
 * @return true if bidi is supported, false otherwise.
 */
public static bool isKeyboardBidi() {
    void*[] list = getKeyboardLanguageList();
    for (int i=0; i<list.length; i++) {
        int id = OS.PRIMARYLANGID(OS.LOWORD(cast(size_t)list[i]));
        if ((id is LANG_ARABIC) || (id is LANG_HEBREW)) {
            return true;
        }
    }
    return false;
}
/**
 * Removes the specified language listener.
 * <p>
 *
 * @param hwnd the handle of the Control that is listening for keyboard language changes
 */
public static void removeLanguageListener (HWND hwnd) {
    languageMap.remove(hwnd);
    unsubclass(hwnd);
}
public static void removeLanguageListener (Control control) {
    removeLanguageListener(control.handle);
}
/**
 * Switch the keyboard language to the specified language type.  We do
 * not distinguish between multiple bidi or multiple non-bidi languages, so
 * set the keyboard to the first language of the given type.
 * <p>
 *
 * @param language integer representing language. One of
 *  KEYBOARD_BIDI, KEYBOARD_NON_BIDI.
 */
public static void setKeyboardLanguage(int language) {
    // don't switch the keyboard if it doesn't need to be
    if (language is getKeyboardLanguage()) return;

    if (language is KEYBOARD_BIDI) {
        // get the list of active languages
        void*[] list = getKeyboardLanguageList();
        // set to first bidi language
        for (int i=0; i<list.length; i++) {
            int id = OS.PRIMARYLANGID(OS.LOWORD(cast(size_t)list[i]));
            if ((id is LANG_ARABIC) || (id is LANG_HEBREW)) {
                OS.ActivateKeyboardLayout(list[i], 0);
                return;
            }
        }
    } else {
        // get the list of active languages
        void*[] list = getKeyboardLanguageList();
        // set to the first non-bidi language (anything not
        // Hebrew or Arabic)
        for (int i=0; i<list.length; i++) {
            int id = OS.PRIMARYLANGID(OS.LOWORD(cast(size_t)list[i]));
            if ((id !is LANG_HEBREW) && (id !is LANG_ARABIC)) {
                OS.ActivateKeyboardLayout(list[i], 0);
                return;
            }
        }
    }
}
/**
 * Sets the orientation (writing order) of the specified control. Text will
 * be right aligned for right to left writing order.
 * <p>
 *
 * @param hwnd the handle of the Control to change the orientation of
 * @param orientation one of SWT.RIGHT_TO_LEFT or SWT.LEFT_TO_RIGHT
 * @return true if the orientation was changed, false if the orientation
 *  could not be changed
 */
public static bool setOrientation (HWND hwnd, int orientation) {
    if (OS.IsWinCE) return false;
    if (OS.WIN32_VERSION < OS.VERSION(4, 10)) return false;
    int bits = OS.GetWindowLong (hwnd, OS.GWL_EXSTYLE);
    if ((orientation & SWT.RIGHT_TO_LEFT) !is 0) {
        bits |= OS.WS_EX_LAYOUTRTL;
    } else {
        bits &= ~OS.WS_EX_LAYOUTRTL;
    }
    OS.SetWindowLong (hwnd, OS.GWL_EXSTYLE, bits);
    return true;
}
public static bool setOrientation (Control control, int orientation) {
    return setOrientation(control.handle, orientation);
}
/**
 * Override the window proc.
 *
 * @param hwnd control to override the window proc of
 */
static void subclass(HWND hwnd) {
    HWND key = hwnd;
    if ( ( key in oldProcMap ) is null) {
        auto oldProc = OS.GetWindowLongPtr(hwnd, OS.GWLP_WNDPROC);
        oldProcMap[key] = cast(WNDPROC)oldProc;
        WNDPROC t = &windowProc; // test signature
        OS.SetWindowLongPtr(hwnd, OS.GWLP_WNDPROC, cast(LONG_PTR)&windowProc);
    }
}
/**
 *  Reverse the character array.  Used for right orientation.
 *
 * @param charArray character array to reverse
 */
static void reverse(wchar[] charArray) {
    int length_ = cast(int)/*64bit*/charArray.length;
    for (int i = 0; i <= (length_  - 1) / 2; i++) {
        wchar tmp = charArray[i];
        charArray[i] = charArray[length_ - 1 - i];
        charArray[length_ - 1 - i] = tmp;
    }
}
/**
 *  Reverse the integer array.  Used for right orientation.
 *
 * @param intArray integer array to reverse
 */
static void reverse(int[] intArray) {
    int length_ = cast(int)/*64bit*/intArray.length;
    for (int i = 0; i <= (length_  - 1) / 2; i++) {
        int tmp = intArray[i];
        intArray[i] = intArray[length_ - 1 - i];
        intArray[length_ - 1 - i] = tmp;
    }
}
/**
 * Adjust the order array so that it is relative to the start of the line.  Also reverse the order array if the orientation
 * is to the right.
 *
 * @param orderArray  integer array of order values to translate
 * @param glyphCount  number of glyphs that have been processed for the current line
 * @param isRightOriented  flag indicating whether or not current orientation is to the right
*/
static void translateOrder(int[] orderArray, int glyphCount, bool isRightOriented) {
    int maxOrder = 0;
    int length_ = cast(int)/*64bit*/orderArray.length;
    if (isRightOriented) {
        for (int i=0; i<length_; i++) {
            maxOrder = Math.max(maxOrder, orderArray[i]);
        }
    }
    for (int i=0; i<length_; i++) {
        if (isRightOriented) orderArray[i] = maxOrder - orderArray[i];
        orderArray [i] += glyphCount;
    }
}
/**
 * Remove the overridden the window proc.
 *
 * @param hwnd control to remove the window proc override for
 */
static void unsubclass(HWND hwnd) {
    HWND key = hwnd;
    if (( key in languageMap ) is null && ( key in keyMap ) is null) {
        WNDPROC proc;
        if( auto p = key in oldProcMap ){
            proc = *p;
            oldProcMap.remove( key );
        }
        if (proc is null) return;
        OS.SetWindowLongPtr(hwnd, OS.GWLP_WNDPROC, cast(LONG_PTR) proc );
    }
}
/**
 * Window proc to intercept keyboard language switch event (WS_INPUTLANGCHANGE)
 * and widget orientation changes.
 * Run the Control's registered runnable when the keyboard language is switched.
 *
 * @param hwnd handle of the control that is listening for the keyboard language
 *  change event
 * @param msg window message
 */
static extern(Windows) LRESULT windowProc (HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam) {
    HWND key = hwnd;
    switch (msg) {
        case 0x51 /*OS.WM_INPUTLANGCHANGE*/:
            Runnable runnable = languageMap[key];
            if (runnable !is null) runnable.run ();
            break;
        default:
        }
    auto oldProc = oldProcMap[key];
    return oldProc( hwnd, msg, wParam, lParam);
}

}
