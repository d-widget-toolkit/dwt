/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.swt.widgets.IME;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.TextStyle;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.internal.win32.WINTYPES;

import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Display;

import java.lang.all;
import java.nonstandard.UnsafeUtf;

/**
 * Instances of this class represent input method editors.
 * These are typically in-line pre-edit text areas that allow
 * the user to compose characters from Far Eastern languages
 * such as Japanese, Chinese or Korean.
 *
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>ImeComposition</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * 
 * @since 3.4
 */
public class IME : Widget {
    Canvas parent;
    int caretOffset;
    int startOffset;
    int commitCount;
    String text;
    int [] ranges;
    TextStyle [] styles;

    mixin(gshared!(`static const int WM_MSIME_MOUSE;`));

    mixin(gshared!(`static byte [16] IID_ITfInputProcessorProfiles;`));
    mixin(gshared!(`static byte [16] IID_ITfDisplayAttributeProvider;`));
    mixin(gshared!(`static byte [16] CLSID_TF_InputProcessorProfiles;`));
    mixin(gshared!(`static byte [16] GUID_TFCAT_TIP_KEYBOARD;`));
    mixin(sharedStaticThis!(`{
        WM_MSIME_MOUSE = OS.RegisterWindowMessage (StrToTCHARz ("MSIMEMouseOperation"));

        OS.IIDFromString ("{1F02B6C5-7842-4EE6-8A0B-9A24183A95CA}\0"w.ptr, IID_ITfInputProcessorProfiles.ptr);
        OS.IIDFromString ("{fee47777-163c-4769-996a-6e9c50ad8f54}\0"w.ptr, IID_ITfDisplayAttributeProvider.ptr);
        OS.IIDFromString ("{33C53A50-F456-4884-B049-85FD643ECFED}\0"w.ptr, CLSID_TF_InputProcessorProfiles.ptr);
        OS.IIDFromString ("{34745C63-B2F0-4784-8B67-5E12C8701A31}\0"w.ptr, GUID_TFCAT_TIP_KEYBOARD.ptr);
    }`));

    /* TextLayout has a copy of these constants */
    static const int UNDERLINE_IME_DOT = 1 << 16;
    static const int UNDERLINE_IME_DASH = 2 << 16;
    static const int UNDERLINE_IME_THICK = 3 << 16;

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this () {
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
 * @param parent a canvas control which will be the parent of the new instance (cannot be null)
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
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Canvas parent, int style) {
    super (parent, style);
    this.parent = parent;
    createWidget ();
}

void createWidget () {
    text = ""; //$NON-NLS-1$
    startOffset = -1;
    if (parent.getIME () is null) {
        parent.setIME (this);
    }
}

/**
 * Returns the offset of the caret from the start of the document.
 * The caret is within the current composition.
 *
 * @return the caret offset
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCaretOffset () {
    checkWidget ();
    return startOffset + caretOffset;
}

/**
 * Returns the commit count of the composition.  This is the
 * number of characters that have been composed.  When the
 * commit count is equal to the length of the composition
 * text, then the in-line edit operation is complete.
 * 
 * @return the commit count
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see IME#getText
 */
public int getCommitCount () {
    checkWidget ();
    return commitCount;
}

/**
 * Returns the offset of the composition from the start of the document.
 * This is the start offset of the composition within the document and
 * in not changed by the input method editor itself during the in-line edit
 * session.
 *
 * @return the offset of the composition
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCompositionOffset () {
    checkWidget ();
    return startOffset;
}

TF_DISPLAYATTRIBUTE* getDisplayAttribute (short langid, int attInfo) {
    void* pProfiles;
    auto hr = OS.CoCreateInstance (CLSID_TF_InputProcessorProfiles.ptr, null, OS.CLSCTX_INPROC_SERVER, IID_ITfInputProcessorProfiles.ptr, &pProfiles);
    TF_DISPLAYATTRIBUTE* pda;
    if (hr is OS.S_OK) {
        byte [16] pclsid;
        byte [16] pguidProfile;
        /* pProfiles.GetDefaultLanguageProfile () */
        hr = OS.VtblCall (8, pProfiles, langid, GUID_TFCAT_TIP_KEYBOARD.ptr, pclsid.ptr, pguidProfile.ptr);
        if (hr is OS.S_OK) {
            void* pProvider;
            hr = OS.CoCreateInstance (pclsid.ptr, null, OS.CLSCTX_INPROC_SERVER, IID_ITfDisplayAttributeProvider.ptr, &pProvider);
            if (hr is OS.S_OK) {
                void* pEnum;
                /* pProvider.EnumDisplayAttributeInfo () */
                hr = OS.VtblCall (3, pProvider, cast(void*)&pEnum);
                if (hr is OS.S_OK) {
                    void* pDispInfo;
                    TF_DISPLAYATTRIBUTE* tempPda = new TF_DISPLAYATTRIBUTE();
                    /* pEnum.Next () */
                    while ((hr = OS.VtblCall (4, pEnum, 1, &pDispInfo, null )) is OS.S_OK) {
                        /* pDispInfo.GetAttributeInfo(); */
                        OS.VtblCall (5, pDispInfo, cast(void*)tempPda);
                        /* pDispInfo.Release () */
                        OS.VtblCall (2, pDispInfo);
                        if (tempPda.bAttr is attInfo) {
                            pda = tempPda;
                            break;
                        }
                    }
                    /* pEnum.Release () */
                    hr = OS.VtblCall (2, pEnum);
                }
                /* pProvider.Release () */
                hr = OS.VtblCall (2, pProvider);
            }
        }
        /* pProfiles.Release () */
        hr = OS.VtblCall (2, pProfiles);
    }
    if (pda is null) {
        pda = new TF_DISPLAYATTRIBUTE ();
        switch (attInfo) {
            case OS.TF_ATTR_INPUT:
                pda.lsStyle = OS.TF_LS_SQUIGGLE;
                break;
            case OS.TF_ATTR_CONVERTED:
            case OS.TF_ATTR_TARGET_CONVERTED:
                pda.lsStyle = OS.TF_LS_SOLID;
                pda.fBoldLine = attInfo is OS.TF_ATTR_TARGET_CONVERTED;
                break;
            default:
        }
    }
    return pda;
}

/**
 * Returns the ranges for the style that should be applied during the
 * in-line edit session.
 * <p>
 * The ranges array contains start and end pairs.  Each pair refers to
 * the corresponding style in the styles array.  For example, the pair
 * that starts at ranges[n] and ends at ranges[n+1] uses the style
 * at styles[n/2] returned by <code>getStyles()</code>.
 * </p>
 * @return the ranges for the styles
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see IME#getStyles
 */
public int [] getRanges () {
    checkWidget ();
    if (ranges is null) return new int [0];
    int [] result = new int [ranges.length];
    for (int i = 0; i < result.length; i++) {
        result [i] = ranges [i] + startOffset;
    }
    return result;
}

/**
 * Returns the styles for the ranges.
 * <p>
 * The ranges array contains start and end pairs.  Each pair refers to
 * the corresponding style in the styles array.  For example, the pair
 * that starts at ranges[n] and ends at ranges[n+1] uses the style
 * at styles[n/2].
 * </p>
 * 
 * @return the ranges for the styles
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see IME#getRanges
 */
public TextStyle [] getStyles () {
    checkWidget ();
    if (styles is null) return new TextStyle [0];
    TextStyle [] result = new TextStyle [styles.length];
    System.arraycopy (styles, 0, result, 0, styles.length);
    return result;
}

/**
 * Returns the composition text.
 * <p>
 * The text for an IME is the characters in the widget that
 * are in the current composition. When the commit count is
 * equal to the length of the composition text, then the
 * in-line edit operation is complete.
 * </p>
 *
 * @return the widget text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget ();
    return text;
}

/**
 * Returns <code>true</code> if the caret should be wide, and
 * <code>false</code> otherwise.  In some languages, for example
 * Korean, the caret is typically widened to the width of the
 * current character in the in-line edit session.
 * 
 * @return the wide caret state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getWideCaret() {
    checkWidget ();
    auto layout = OS.GetKeyboardLayout (0);
    short langID = cast(short)OS.LOWORD (cast(ptrdiff_t)layout);
    return OS.PRIMARYLANGID (langID) is OS.LANG_KOREAN;
}

bool isInlineEnabled () {
    if (OS.IsWinCE || OS.WIN32_VERSION < OS.VERSION (5, 1)) return false;
    return OS.IsDBLocale && hooks (SWT.ImeComposition);
}

override
void releaseParent () {
    super.releaseParent ();
    if (this is parent.getIME ()) parent.setIME (null);
}

override
void releaseWidget () {
    super.releaseWidget ();
    parent = null;
    text = null;
    styles = null;
    ranges = null;
}

/**
 * Sets the offset of the composition from the start of the document.
 * This is the start offset of the composition within the document and
 * in not changed by the input method editor itself during the in-line edit
 * session but may need to be changed by clients of the IME.  For example,
 * if during an in-line edit operation, a text editor inserts characters
 * above the IME, then the IME must be informed that the composition
 * offset has changed.
 *
 * @return the offset of the composition
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCompositionOffset (int offset) {
    checkWidget ();
    if (offset < 0) return;
    if (startOffset !is -1) {
        startOffset = offset;
    }
}

LRESULT WM_IME_COMPOSITION (WPARAM wParam, LPARAM lParam) {
    if (!isInlineEnabled ()) return null;
    ranges = null;
    styles = null;
    caretOffset = commitCount = 0;
    auto hwnd = parent.handle;
    auto hIMC = OS.ImmGetContext (hwnd);
    int codePage = parent.getCodePage ();
    if (hIMC !is null) {
        TCHAR[] buffer = null;
        if ((lParam & OS.GCS_RESULTSTR) !is 0) {
            int length_ = OS.ImmGetCompositionString (hIMC, OS.GCS_RESULTSTR, null, 0);
            if (length_ > 0) {
                buffer = NewTCHARs (codePage, length_ / TCHAR.sizeof);
                OS.ImmGetCompositionString (hIMC, OS.GCS_RESULTSTR, buffer.ptr, length_);
                if (startOffset is -1) {
                    Event event = new Event ();
                    event.detail = SWT.COMPOSITION_SELECTION;
                    sendEvent (SWT.ImeComposition, event);
                    startOffset = event.start;
                }
                Event event = new Event ();
                event.detail = SWT.COMPOSITION_CHANGED;
                event.start = startOffset;
                event.end = startOffset + cast(int)/*64bit*/text.length;
                event.text = text = buffer !is null ? TCHARsToStr(buffer) : "";
                commitCount = cast(int)/*64bit*/text.length ;
                sendEvent (SWT.ImeComposition, event);
                String chars = text;
                text = ""; //$NON-NLS-1$
                startOffset = -1;
                commitCount = 0;
                if (event.doit) {
                    Display display = this.display;
                    display.lastKey = 0;
                    display.lastVirtual = display.lastNull = display.lastDead = false;
                    length_ = cast(int)/*64bit*/chars.length;
                    ptrdiff_t di;
                    for (int i = 0; i < length_; i += di) {
                        dchar c = chars.dcharAt(i, di);
                        display.lastAscii = c;
                        event = new Event ();
                        event.character = cast(wchar) c;
                        parent.sendEvent (SWT.KeyDown, event);
                    }
                }
            }
            if ((lParam & OS.GCS_COMPSTR) is 0) return LRESULT.ONE;
        }
        buffer = null;
        if ((lParam & OS.GCS_COMPSTR) !is 0) {
            int length_ = OS.ImmGetCompositionString (hIMC, OS.GCS_COMPSTR, null, 0);
            if (length_ > 0) {
                buffer = NewTCHARs (codePage, length_ / TCHAR.sizeof);
                OS.ImmGetCompositionString (hIMC, OS.GCS_COMPSTR, buffer.ptr, length_);
                if ((lParam & OS.GCS_CURSORPOS) !is 0) {
                    caretOffset = OS.ImmGetCompositionString (hIMC, OS.GCS_CURSORPOS, null, 0);
                }
                int [] clauses = null;
                if ((lParam & OS.GCS_COMPCLAUSE) !is 0) {
                    length_ = OS.ImmGetCompositionStringW (hIMC, OS.GCS_COMPCLAUSE, /+cast(int [])+/null, 0);
                    if (length_ > 0) {
                        clauses = new int [length_ / 4];
                        OS.ImmGetCompositionStringW (hIMC, OS.GCS_COMPCLAUSE, clauses.ptr, length_);
                    }
                }
                if ((lParam & OS.GCS_COMPATTR) !is 0 && clauses !is null) {
                    length_ = OS.ImmGetCompositionStringA (hIMC, OS.GCS_COMPATTR, /+cast(byte [])+/null, 0);
                    if (length_ > 0) {
                        byte [] attrs = new byte [length_];
                        OS.ImmGetCompositionStringA (hIMC, OS.GCS_COMPATTR, attrs.ptr, length_);
                        length_ = cast(int)/*64bit*/clauses.length - 1;
                        ranges = new int [length_ * 2];
                        styles = new TextStyle [length_];
                        auto layout = OS.GetKeyboardLayout (0);
                        short langID = cast(short)OS.LOWORD (cast(ptrdiff_t)layout);
                        TF_DISPLAYATTRIBUTE* attr = null;
                        TextStyle style = null;
                        for (int i = 0; i < length_; i++) {
                            ranges [i * 2] = clauses [i];
                            ranges [i * 2 + 1] = clauses [i + 1] - 1;
                            styles [i] = style = new TextStyle ();
                            attr = getDisplayAttribute (langID, attrs [clauses [i]]);
                            if (attr !is null) {
                                switch (attr.crText.type) {
                                    case OS.TF_CT_COLORREF:
                                        style.foreground = Color.win32_new (display, attr.crText.cr);
                                        break;
                                    case OS.TF_CT_SYSCOLOR:
                                        int colorRef = OS.GetSysColor (attr.crText.cr);
                                        style.foreground = Color.win32_new (display, colorRef);
                                        break;
                                    default:
                                }
                                switch (attr.crBk.type) {
                                    case OS.TF_CT_COLORREF:
                                        style.background = Color.win32_new (display, attr.crBk.cr);
                                        break;
                                    case OS.TF_CT_SYSCOLOR:
                                        int colorRef = OS.GetSysColor (attr.crBk.cr);
                                        style.background = Color.win32_new (display, colorRef);
                                        break;
                                    default:
                                }
                                switch (attr.crLine.type) {
                                    case OS.TF_CT_COLORREF:
                                        style.underlineColor = Color.win32_new (display, attr.crLine.cr);
                                        break;
                                    case OS.TF_CT_SYSCOLOR:
                                        int colorRef = OS.GetSysColor (attr.crLine.cr);
                                        style.underlineColor = Color.win32_new (display, colorRef);
                                        break;
                                    default:
                                }
                                style.underline = attr.lsStyle !is OS.TF_LS_NONE;
                                switch (attr.lsStyle) {
                                    case OS.TF_LS_SQUIGGLE:
                                        style.underlineStyle = SWT.UNDERLINE_SQUIGGLE;
                                        break;
                                    case OS.TF_LS_DASH:
                                        style.underlineStyle = UNDERLINE_IME_DASH;
                                        break;
                                    case OS.TF_LS_DOT:
                                        style.underlineStyle = UNDERLINE_IME_DOT;
                                        break;
                                    case OS.TF_LS_SOLID:
                                        style.underlineStyle = attr.fBoldLine ? UNDERLINE_IME_THICK : SWT.UNDERLINE_SINGLE;
                                        break;
                                    default:
                                }
                            }
                            delete attr;
                        }
                    }
                }
            }
            OS.ImmReleaseContext (hwnd, hIMC);
        }
        int end = startOffset + cast(int)/*64bit*/text.length;
        if (startOffset is -1) {
            Event event = new Event ();
            event.detail = SWT.COMPOSITION_SELECTION;
            sendEvent (SWT.ImeComposition, event);
            startOffset = event.start;
            end = event.end;
        }
        Event event = new Event ();
        event.detail = SWT.COMPOSITION_CHANGED;
        event.start = startOffset;
        event.end = end;
        event.text = text = buffer !is null ? TCHARsToStr(buffer) : "";
        sendEvent (SWT.ImeComposition, event);
        if (text.length is 0) {
            startOffset = -1;
            ranges = null;
            styles = null;
        }
    }
    return LRESULT.ONE;
}

LRESULT WM_IME_COMPOSITION_START (WPARAM wParam, LPARAM lParam) {
    return isInlineEnabled () ? LRESULT.ONE : null;
}

LRESULT WM_IME_ENDCOMPOSITION (WPARAM wParam, LPARAM lParam) {
    return isInlineEnabled () ? LRESULT.ONE : null;
}

LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {
    if (!isInlineEnabled ()) return null;
    auto hwnd = parent.handle;
    auto hIMC = OS.ImmGetContext (hwnd);
    if (hIMC !is null) {
        if (OS.ImmGetOpenStatus (hIMC)) {
            OS.ImmNotifyIME (hIMC, OS.NI_COMPOSITIONSTR, OS.CPS_COMPLETE, 0);
        }
        OS.ImmReleaseContext (hwnd, hIMC);
    }
    return null;
}

LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    if (!isInlineEnabled ()) return null;
    auto hwnd = parent.handle;
    auto hIMC = OS.ImmGetContext (hwnd);
    if (hIMC !is null) {
        if (OS.ImmGetOpenStatus (hIMC)) {
            if (OS.ImmGetCompositionString (hIMC, OS.GCS_COMPSTR, null, 0) > 0) {
                Event event = new Event ();
                event.detail = SWT.COMPOSITION_OFFSET;
                event.x = OS.GET_X_LPARAM (lParam);
                event.y = OS.GET_Y_LPARAM (lParam);
                sendEvent (SWT.ImeComposition, event);
                int offset = event.index;
                int length_ = cast(int)/*64bit*/text.length;
                if (offset !is -1 && startOffset !is -1 && startOffset <= offset && offset < startOffset + length_) {
                    auto imeWnd = OS.ImmGetDefaultIMEWnd (hwnd);
                    offset = event.index + event.count - startOffset;
                    int trailing = event.count > 0 ? 1 : 2;
                    auto param = OS.MAKEWPARAM (OS.MAKEWORD (OS.IMEMOUSE_LDOWN, trailing), offset);
                    OS.SendMessage (imeWnd, WM_MSIME_MOUSE, param, hIMC);
                } else {
                    OS.ImmNotifyIME (hIMC, OS.NI_COMPOSITIONSTR, OS.CPS_COMPLETE, 0);
                }
            }
        }
        OS.ImmReleaseContext (hwnd, hIMC);
    }
    return null;
}

}
