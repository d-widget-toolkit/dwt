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



import java.lang.all;



import org.eclipse.swt.SWT;

import org.eclipse.swt.SWTException;

import org.eclipse.swt.graphics.Color;

import org.eclipse.swt.graphics.TextStyle;

import org.eclipse.swt.internal.Converter;

import org.eclipse.swt.internal.gtk.OS;



import org.eclipse.swt.widgets.Widget;

import org.eclipse.swt.widgets.Canvas;

import org.eclipse.swt.widgets.Event;



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

    bool inComposition;



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

    text = "";

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

public bool getWideCaret () {

    checkWidget ();

    return false;

}



override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {

    if (!isInlineEnabled ()) return 0;

    auto imHandle_ = imHandle ();

    if (imHandle_ !is null) OS.gtk_im_context_reset (imHandle_);

    return 0;

}



override int gtk_commit (GtkIMContext* imcontext, char* textPtr) {

    if (!isInlineEnabled ()) return 0;

    bool doit = true;

    ranges = null;

    styles = null;

    caretOffset = commitCount = 0;

    if (textPtr !is null && inComposition) {

        int length = OS.strlen (textPtr);

        if (length !is 0) {

            String chars = fromStringz(textPtr)._idup();

            Event event = new Event();

            event.detail = SWT.COMPOSITION_CHANGED;

            event.start = startOffset;

            event.end = cast(int)/*64bit*/(startOffset + text.length);

            event.text = text = chars !is null ? chars : "";

            commitCount = cast(int)/*64bit*/text.length;

            sendEvent (SWT.ImeComposition, event);

            doit = event.doit;

            text = "";

            startOffset = -1;

            commitCount = 0;

        }

    }

    inComposition = false;

    return doit ? 0 : 1;

}



override int gtk_preedit_changed (GtkIMContext* imcontext) {

    if (!isInlineEnabled ()) return 0;

    ranges = null;

    styles = null;

    commitCount = 0;

    auto imHandle_ = imHandle ();

    char* preeditString;

    void* pangoAttrs;

    int cursorPos;

    OS.gtk_im_context_get_preedit_string (imHandle_, &preeditString, &pangoAttrs, &cursorPos);

    caretOffset = cursorPos ;

    String chars = null;

    if (preeditString !is null) {

        int length = OS.strlen (preeditString);

        chars = fromStringz(preeditString)._idup();

        if (pangoAttrs !is null) {

            int count = 0;

            auto iterator = OS.pango_attr_list_get_iterator (pangoAttrs );

            while (OS.pango_attr_iterator_next (iterator)) count++;

            OS.pango_attr_iterator_destroy (iterator);

            ranges = new int [count * 2];

            styles = new TextStyle [count];

            iterator = OS.pango_attr_list_get_iterator (pangoAttrs );

            PangoAttrColor* attrColor;

            PangoAttrInt* attrInt;

            int start;

            int end;

            for (int i = 0; i < count; i++) {

                OS.pango_attr_iterator_range (iterator, &start, &end);

                ranges [i * 2] = cast(int)/*64bit*/OS.g_utf8_pointer_to_offset (preeditString, preeditString + start);

                ranges [i * 2 + 1] = cast(int)/*64bit*/OS.g_utf8_pointer_to_offset (preeditString, preeditString + end) - 1;

                styles [i] = new TextStyle (null, null, null);

                auto attr = OS.pango_attr_iterator_get (iterator, OS.PANGO_ATTR_FOREGROUND);

                if (attr !is null) {

                    attrColor = cast(PangoAttrColor*) attr;

                    GdkColor* color = new GdkColor ();

                    color.red = attrColor.color.red;

                    color.green = attrColor.color.green;

                    color.blue = attrColor.color.blue;

                    styles [i].foreground = Color.gtk_new (display, color);

                }

                attr = OS.pango_attr_iterator_get (iterator, OS.PANGO_ATTR_BACKGROUND);

                if (attr !is null) {

                    attrColor = cast(PangoAttrColor*) attr;

                    GdkColor* color = new GdkColor ();

                    color.red = attrColor.color.red;

                    color.green = attrColor.color.green;

                    color.blue = attrColor.color.blue;

                    styles [i].background = Color.gtk_new (display, color);

                }

                attr = OS.pango_attr_iterator_get (iterator, OS.PANGO_ATTR_UNDERLINE);

                if (attr !is null) {

                    attrInt = cast(PangoAttrInt*) attr;

                    styles [i].underline = attrInt.value !is OS.PANGO_UNDERLINE_NONE;

                    styles [i].underlineStyle = SWT.UNDERLINE_SINGLE;

                    switch (attrInt.value) {

                        case OS.PANGO_UNDERLINE_DOUBLE:

                            styles [i].underlineStyle = SWT.UNDERLINE_DOUBLE;

                            break;

                        case OS.PANGO_UNDERLINE_ERROR:

                            styles [i].underlineStyle = SWT.UNDERLINE_ERROR;

                            break;

                        default: break;

                    }

                    if (styles [i].underline) {

                        attr = OS.pango_attr_iterator_get(iterator, OS.PANGO_ATTR_UNDERLINE_COLOR);

                        if (attr !is null) {

                            attrColor = cast(PangoAttrColor*) attr;

                            GdkColor* color = new GdkColor;

                            color.red = attrColor.color.red;

                            color.green = attrColor.color.green;

                            color.blue = attrColor.color.blue;

                            styles [i].underlineColor = Color.gtk_new (display, color);

                        }

                    }

                }

                OS.pango_attr_iterator_next (iterator);

            }

            OS.pango_attr_iterator_destroy (iterator);

            OS.pango_attr_list_unref (pangoAttrs);

        }

        OS.g_free (preeditString);

    }

    if (chars !is null) {

        if (text.length is 0) startOffset = -1;

        ptrdiff_t end = startOffset + text.length;

        if (startOffset is -1) {

            Event event = new Event ();

            event.detail = SWT.COMPOSITION_SELECTION;

            sendEvent (SWT.ImeComposition, event);

            startOffset = event.start;

            end = event.end;

        }

        inComposition = true;

        Event event = new Event ();

        event.detail = SWT.COMPOSITION_CHANGED;

        event.start = startOffset;

        event.end = cast(int)/*64bit*/end;

        event.text = text = chars !is null ? chars : "";

        sendEvent (SWT.ImeComposition, event);

    }

    return 1;

}



GtkIMContext* imHandle () {

    return parent.imHandle ();

}



bool isInlineEnabled () {

    return hooks (SWT.ImeComposition);

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



}

