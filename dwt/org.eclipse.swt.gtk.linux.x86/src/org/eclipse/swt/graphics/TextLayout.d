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
module org.eclipse.swt.graphics.TextLayout;

import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.internal.cairo.Cairo : Cairo;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.FontMetrics;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.GlyphMetrics;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Region;
import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.TextStyle;
import java.lang.all;
import java.nonstandard.UnsafeUtf;

version(Tango){
    import tango.stdc.string : memmove;
    import tango.text.convert.Utf;
} else { // Phobos
    import core.stdc.string : memmove;
}

/**
 * <code>TextLayout</code> is a graphic object that represents
 * styled text.
 * <p>
 * Instances of this class provide support for drawing, cursor
 * navigation, hit testing, text wrapping, alignment, tab expansion
 * line breaking, etc.  These are aspects required for rendering internationalized text.
 * </p><p>
 * Application code must explicitly invoke the <code>TextLayout#dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#textlayout">TextLayout, TextStyle snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: CustomControlExample, StyledText tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.0
 */
public final class TextLayout : Resource {

    static class StyleItem {
        TextStyle style;
        int start;

        public override String toString () {
            return Format( "StyleItem {{{}, {}}", start, style );
        }
    }

    Font font;
    String text;
    int ascent, descent;
    int[] segments;
    int[] tabs;
    StyleItem[] styles;
    PangoLayout* layout;
    PangoContext* context;
    PangoAttrList* attrList;
    int[] invalidOffsets;
    // LTR_MARK LEFT-TO-RIGHT MARK
    // RTL_MARK RIGHT-TO-LEFT MARK
    // ZWS      ZERO WIDTH SPACE
    // ZWNBS    ZERO WIDTH NO-BREAK SPACE
    static const dchar LTR_MARK      = '\u200E'; // x"E2 80 8E" LEFT-TO-RIGHT MARK
    static const dchar RTL_MARK      = '\u200F'; // x"E2 80 8F" RIGHT-TO-LEFT MARK
    static const dchar ZWS           = '\u200B'; // x"E2 80 8B" ZERO WIDTH SPACE
    static const dchar ZWNBS         = '\uFEFF'; // x"EF BB BF" ZERO WIDTH NO-BREAK SPACE
    static const String STR_LTR_MARK = "\u200E";
    static const String STR_RTL_MARK = "\u200F";
    static const String STR_ZWS      = "\u200B";
    static const String STR_ZWNBS    = "\uFEFF";

/**
 * Constructs a new instance of this class on the given device.
 * <p>
 * You must dispose the text layout when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the text layout
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 * </ul>
 *
 * @see #dispose()
 */
public this (Device device) {
    super(device);
    device = this.device;
    context = OS.gdk_pango_context_get();
    if (context is null) SWT.error(SWT.ERROR_NO_HANDLES);
    OS.pango_context_set_language(context, OS.gtk_get_default_language());
    OS.pango_context_set_base_dir(context, OS.PANGO_DIRECTION_LTR);
    OS.gdk_pango_context_set_colormap(context, OS.gdk_colormap_get_system());
    layout = OS.pango_layout_new(context);
    if (layout is null) SWT.error(SWT.ERROR_NO_HANDLES);
    OS.pango_layout_set_font_description(layout, device.systemFont.handle);
    OS.pango_layout_set_wrap(layout, OS.PANGO_WRAP_WORD_CHAR);
    OS.pango_layout_set_tabs(layout, device.emptyTab);
    if (OS.GTK_VERSION >= OS.buildVERSION(2, 4, 0)) {
        OS.pango_layout_set_auto_dir(layout, false);
    }
    text = "";
    ascent = descent = -1;
    styles = new StyleItem[2];
    styles[0] = new StyleItem();
    styles[1] = new StyleItem();
    init_();
}

void checkLayout() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
}

void computeRuns () {
    if (attrList !is null) return;
    String segmentsText = getSegmentsText();
    OS.pango_layout_set_text (layout, segmentsText.ptr,
                              cast(int)/*64bit*/segmentsText.length);
    if (styles.length is 2 && styles[0].style is null && ascent is -1 && descent is -1 && segments is null) return;
    auto ptr = OS.pango_layout_get_text(layout);
    attrList = OS.pango_attr_list_new();
    PangoAttribute* attribute;
    char[] chars = null;
    auto segementsLength = segmentsText.length;
    if ((ascent !is -1  || descent !is -1) && segementsLength > 0) {
        PangoRectangle rect;
        if (ascent !is -1) rect.y =  -(ascent  * OS.PANGO_SCALE);
        rect.height = (Math.max(0, ascent) + Math.max(0, descent)) * OS.PANGO_SCALE;
        int lineCount = OS.pango_layout_get_line_count(layout);
        chars = new char[segementsLength + lineCount * 6/*2*/];
        int oldPos = 0, lineIndex = 0;
        while (lineIndex < lineCount) {
            auto line = OS.pango_layout_get_line(layout, lineIndex);
            int bytePos = line.start_index;
            /* Note: The length in bytes of ZWS and ZWNBS are both equals to 3 */
            int offset = lineIndex * 6;
            PangoAttribute* attr = OS.pango_attr_shape_new (&rect, &rect);
            attribute = attr;
            attribute.start_index = bytePos + offset;
            attribute.end_index = bytePos + offset + 3;
            OS.pango_attr_list_insert(attrList, attr);
            attr = OS.pango_attr_shape_new (&rect, &rect);
            attribute = attr;
            attribute.start_index = bytePos + offset + 3;
            attribute.end_index = bytePos + offset + 6;
            OS.pango_attr_list_insert(attrList, attr);
            int pos = bytePos;//OS.g_utf8_pointer_to_offset(ptr, ptr + bytePos);
            chars[pos + lineIndex * 6 +0 .. pos + lineIndex * 6 + 3] = STR_ZWS;
            chars[pos + lineIndex * 6 +3 .. pos + lineIndex * 6 + 6] = STR_ZWNBS;
            chars[ oldPos + lineIndex*6 .. oldPos + lineIndex*6 + pos - oldPos ] =
                segmentsText[ oldPos .. pos ];
            oldPos = pos;
            lineIndex++;
        }
        segmentsText.getChars(oldPos, cast(int)/*64bit*/segementsLength, chars,  oldPos + lineIndex * 6);
        auto buffer = chars;// Converter.wcsToMbcs(null, chars, false);

        OS.pango_layout_set_text (layout, buffer.ptr, cast(int)/*64bit*/buffer.length);
        ptr = OS.pango_layout_get_text(layout);
    } else {
        chars = segmentsText.dup;
    }
    int offsetCount = 0;
    {
        int i = 0;
        while( i < chars.length ){
            ptrdiff_t incr;
            dchar c = chars.dcharAt(i, incr);
            if (c is LTR_MARK || c is RTL_MARK || c is ZWNBS || c is ZWS) {
                offsetCount+=3;
            }
            i += incr;
        }
    }
    invalidOffsets = new int[offsetCount];
    offsetCount = 0;
    {
        int i = 0;
        while( i < chars.length ){
            ptrdiff_t incr;
            dchar c = chars.dcharAt(i, incr);
            if (c is LTR_MARK || c is RTL_MARK || c is ZWNBS || c is ZWS) {
                invalidOffsets[offsetCount++] = i;
                invalidOffsets[offsetCount++] = i+1;
                invalidOffsets[offsetCount++] = i+2;
            }
            i += incr;
        }
    }
    int slen = OS.strlen(ptr);
    Font defaultFont = font !is null ? font : device.systemFont;
    for (int i = 0; i < styles.length - 1; i++) {
        StyleItem styleItem = styles[i];
        TextStyle style = styleItem.style;
        if (style is null) continue;
        int start = translateOffset(styleItem.start);
        int end = translateOffset(styles[i+1].start - 1);
        int byteStart = start;//(OS.g_utf8_offset_to_pointer(ptr, start) - ptr);
        int byteEnd = end+1;//(OS.g_utf8_offset_to_pointer(ptr, end + 1) - ptr);
        byteStart = Math.min(byteStart, slen);
        byteEnd = Math.min(byteEnd, slen);
        Font font = style.font;
        if (font !is null && !font.isDisposed() && !defaultFont.opEquals(font)) {
            auto attr = OS.pango_attr_font_desc_new (font.handle);
            attr.start_index = byteStart;
            attr.end_index = byteEnd;
            OS.pango_attr_list_insert(attrList, attr);
        }
        if (style.underline) {
            int underlineStyle = OS.PANGO_UNDERLINE_NONE;
            switch (style.underlineStyle) {
                case SWT.UNDERLINE_SINGLE:
                    underlineStyle = OS.PANGO_UNDERLINE_SINGLE;
                    break;
                case SWT.UNDERLINE_DOUBLE:
                    underlineStyle = OS.PANGO_UNDERLINE_DOUBLE;
                    break;
                case SWT.UNDERLINE_SQUIGGLE:
                case SWT.UNDERLINE_ERROR:
                    if (OS.GTK_VERSION >= OS.buildVERSION(2, 4, 0)) {
                        underlineStyle = OS.PANGO_UNDERLINE_ERROR;
                    }
                    break;
                default: break;
            }
            if (underlineStyle !is OS.PANGO_UNDERLINE_NONE && style.underlineColor is null) {
                auto attr = OS.pango_attr_underline_new(underlineStyle);
                attr.start_index = byteStart;
                attr.end_index = byteEnd;
                OS.pango_attr_list_insert(attrList, attr);
            }
        }
        if (style.strikeout && style.strikeoutColor is null) {
            auto attr = OS.pango_attr_strikethrough_new(true);
            attr.start_index = byteStart;
            attr.end_index = byteEnd;
            OS.pango_attr_list_insert(attrList, attr);
        }
        Color foreground = style.foreground;
        if (foreground !is null && !foreground.isDisposed()) {
            GdkColor* fg = foreground.handle;
            auto attr = OS.pango_attr_foreground_new(fg.red, fg.green, fg.blue);
            attr.start_index = byteStart;
            attr.end_index = byteEnd;
            OS.pango_attr_list_insert(attrList, attr);
        }
        Color background = style.background;
        if (background !is null && !background.isDisposed()) {
            GdkColor* bg = background.handle;
            auto attr = OS.pango_attr_background_new(bg.red, bg.green, bg.blue);
            attr.start_index = byteStart;
            attr.end_index = byteEnd;
            OS.pango_attr_list_insert(attrList, attr);
        }
        GlyphMetrics metrics = style.metrics;
        if (metrics !is null) {
            PangoRectangle rect;
            rect.y =  -(metrics.ascent * OS.PANGO_SCALE);
            rect.height = (metrics.ascent + metrics.descent) * OS.PANGO_SCALE;
            rect.width = metrics.width * OS.PANGO_SCALE;
            auto attr = OS.pango_attr_shape_new (&rect, &rect);
            attr.start_index = byteStart;
            attr.end_index = byteEnd;
            OS.pango_attr_list_insert(attrList, attr);
        }
        int rise = style.rise;
        if (rise !is 0) {
            auto attr = OS.pango_attr_rise_new (rise * OS.PANGO_SCALE);
            attr.start_index = byteStart;
            attr.end_index = byteEnd;
            OS.pango_attr_list_insert(attrList, attr);
        }
    }
    OS.pango_layout_set_attributes(layout, attrList);
}

int[] computePolyline(int left, int top, int right, int bottom) {
    int height = bottom - top; // can be any number
    int width = 2 * height; // must be even
    int peaks = Compatibility.ceil(right - left, width);
    if (peaks is 0 && right - left > 2) {
        peaks = 1;
    }
    int length_ = ((2 * peaks) + 1) * 2;
    if (length_ < 0) return new int[0];

    int[] coordinates = new int[length_];
    for (int i = 0; i < peaks; i++) {
        int index = 4 * i;
        coordinates[index] = left + (width * i);
        coordinates[index+1] = bottom;
        coordinates[index+2] = coordinates[index] + width / 2;
        coordinates[index+3] = top;
    }
    coordinates[length_-2] = left + (width * peaks);
    coordinates[length_-1] = bottom;
    return coordinates;
}

override
void destroy() {
    font = null;
    text = null;
    styles = null;
    freeRuns();
    if (layout !is null) OS.g_object_unref(layout);
    layout = null;
    if (context !is null) OS.g_object_unref(context);
    context = null;
}

/**
 * Draws the receiver's text using the specified GC at the specified
 * point.
 *
 * @param gc the GC to draw
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 * </ul>
 */
public void draw(GC gc, int x, int y) {
    draw(gc, x, y, -1, -1, null, null);
}

/**
 * Draws the receiver's text using the specified GC at the specified
 * point.
 *
 * @param gc the GC to draw
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param selectionStart the offset where the selections starts, or -1 indicating no selection
 * @param selectionEnd the offset where the selections ends, or -1 indicating no selection
 * @param selectionForeground selection foreground, or NULL to use the system default color
 * @param selectionBackground selection background, or NULL to use the system default color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 * </ul>
 */
public void draw(GC gc, int x, int y, int selectionStart, int selectionEnd, Color selectionForeground, Color selectionBackground) {
    draw(gc, x, y, selectionStart, selectionEnd, selectionForeground, selectionBackground, 0);
}

/**
 * Draws the receiver's text using the specified GC at the specified
 * point.
 * <p>
 * The parameter <code>flags</code> can include one of <code>SWT.DELIMITER_SELECTION</code>
 * or <code>SWT.FULL_SELECTION</code> to specify the selection behavior on all lines except
 * for the last line, and can also include <code>SWT.LAST_LINE_SELECTION</code> to extend
 * the specified selection behavior to the last line.
 * </p>
 * @param gc the GC to draw
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param selectionStart the offset where the selections starts, or -1 indicating no selection
 * @param selectionEnd the offset where the selections ends, or -1 indicating no selection
 * @param selectionForeground selection foreground, or NULL to use the system default color
 * @param selectionBackground selection background, or NULL to use the system default color
 * @param flags drawing options
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 * </ul>
 *
 * @since 3.3
 */
public void draw(GC gc, int x, int y, int selectionStart, int selectionEnd, Color selectionForeground, Color selectionBackground, int flags) {
    checkLayout ();
    computeRuns();
    if (gc is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (selectionForeground !is null && selectionForeground.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (selectionBackground !is null && selectionBackground.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    gc.checkGC(GC.FOREGROUND);
    auto length_ = text.length;
    bool hasSelection = selectionStart <= selectionEnd && selectionStart !is -1 && selectionEnd !is -1;
    GCData data = gc.data;
    auto cairo = data.cairo;
    if (flags !is 0 && (hasSelection || (flags & SWT.LAST_LINE_SELECTION) !is 0)) {
        PangoLogAttr* attrs;
        int nAttrs;
        PangoLogAttr* logAttr = new PangoLogAttr();
        PangoRectangle rect;
        int lineCount = OS.pango_layout_get_line_count(layout);
        auto ptr = OS.pango_layout_get_text(layout);
        auto iter = OS.pango_layout_get_iter(layout);
        if (selectionBackground is null) selectionBackground = device.getSystemColor(SWT.COLOR_LIST_SELECTION);
        if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
            Cairo.cairo_save(cairo);
            GdkColor* color = selectionBackground.handle;
            Cairo.cairo_set_source_rgba(cairo, (color.red & 0xFFFF) / cast(float)0xFFFF, (color.green & 0xFFFF) / cast(float)0xFFFF, (color.blue & 0xFFFF) / cast(float)0xFFFF, data.alpha / cast(float)0xFF);
        } else {
            OS.gdk_gc_set_foreground(gc.handle, selectionBackground.handle);
        }
        int lineIndex = 0;
        do {
            int lineEnd;
            OS.pango_layout_iter_get_line_extents(iter, null, &rect);
            if (OS.pango_layout_iter_next_line(iter)) {
                int bytePos = OS.pango_layout_iter_get_index(iter);
                lineEnd = bytePos;//OS.g_utf8_pointer_to_offset(ptr, ptr + bytePos);
            } else {
                lineEnd = cast(int)/*64bit*/OS.g_utf8_strlen(ptr, -1);
            }
            bool extent = false;
            if (lineIndex is lineCount - 1 && (flags & SWT.LAST_LINE_SELECTION) !is 0) {
                extent = true;
            } else {
                if (attrs is null) OS.pango_layout_get_log_attrs(layout, &attrs, &nAttrs);
                *logAttr = attrs[lineEnd];
                if (!( logAttr.bitfield0 & 0x01 /* PangoLogAttr.is_line_break is Bit0 */)) {
                    if (selectionStart <= lineEnd && lineEnd <= selectionEnd) extent = true;
                } else {
                    if (selectionStart <= lineEnd && lineEnd < selectionEnd && (flags & SWT.FULL_SELECTION) !is 0) {
                        extent = true;
                    }
                }
            }
            if (extent) {
                int lineX = x + OS.PANGO_PIXELS(rect.x) + OS.PANGO_PIXELS(rect.width);
                int lineY = y + OS.PANGO_PIXELS(rect.y);
                int height = OS.PANGO_PIXELS(rect.height);
                if (ascent !is -1 && descent !is -1) {
                    height = Math.max (height, ascent + descent);
                }
                int width = (flags & SWT.FULL_SELECTION) !is 0 ? 0x7fffffff : height / 3;
                if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
                    Cairo.cairo_rectangle(cairo, lineX, lineY, width, height);
                    Cairo.cairo_fill(cairo);
                } else {
                    OS.gdk_draw_rectangle(data.drawable, gc.handle, 1, lineX, lineY, width, height);
                }
            }
            lineIndex++;
        } while (lineIndex < lineCount);
        OS.pango_layout_iter_free(iter);
        if (attrs !is null) OS.g_free(attrs);
        if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
            Cairo.cairo_restore(cairo);
        } else {
            OS.gdk_gc_set_foreground(gc.handle, data.foreground);
        }
    }
    if (length_ is 0) return;
    if (!hasSelection) {
        if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
            if ((data.style & SWT.MIRRORED) !is 0) {
                Cairo.cairo_save(cairo);
                Cairo.cairo_scale(cairo, -1,  1);
                Cairo.cairo_translate(cairo, -2 * x - width(), 0);
            }
            Cairo.cairo_move_to(cairo, x, y);
            OS.pango_cairo_show_layout(cairo, layout);
            drawBorder(gc, x, y, null);
            if ((data.style & SWT.MIRRORED) !is 0) {
                Cairo.cairo_restore(cairo);
            }
        } else {
            OS.gdk_draw_layout(data.drawable, gc.handle, x, y, layout);
            drawBorder(gc, x, y, null);
        }
    } else {
        selectionStart = cast(int)/*64bit*/(Math.min(Math.max
                                         (0, selectionStart), length_ - 1));
        selectionEnd = cast(int)/*64bit*/(Math.min(Math.max
                                (0, selectionEnd), length_ - 1));
        length_ = OS.g_utf8_strlen(OS.pango_layout_get_text(layout), -1);
        selectionStart = translateOffset(selectionStart);
        selectionEnd = translateOffset(selectionEnd);
        if (selectionForeground is null) selectionForeground = device.getSystemColor(SWT.COLOR_LIST_SELECTION_TEXT);
        if (selectionBackground is null) selectionBackground = device.getSystemColor(SWT.COLOR_LIST_SELECTION);
        bool fullSelection = selectionStart is 0 && selectionEnd is length_ - 1;
        if (fullSelection) {
            if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
                auto ptr = OS.pango_layout_get_text(layout);
                if ((data.style & SWT.MIRRORED) !is 0) {
                    Cairo.cairo_save(cairo);
                    Cairo.cairo_scale(cairo, -1,  1);
                    Cairo.cairo_translate(cairo, -2 * x - width(), 0);
                }
                drawWithCairo(gc, x, y, 0, OS.strlen(ptr), fullSelection, selectionForeground.handle, selectionBackground.handle);
                if ((data.style & SWT.MIRRORED) !is 0) {
                    Cairo.cairo_restore(cairo);
                }
            } else {
                OS.gdk_draw_layout_with_colors(data.drawable, gc.handle, x, y, layout, selectionForeground.handle, selectionBackground.handle);
                drawBorder(gc, x, y, selectionForeground.handle);
            }
        } else {
            auto ptr = OS.pango_layout_get_text(layout);
            int byteSelStart = selectionStart;//(OS.g_utf8_offset_to_pointer(ptr, selectionStart) - ptr);
            int byteSelEnd = selectionEnd + 1;//(OS.g_utf8_offset_to_pointer(ptr, selectionEnd + 1) - ptr);
            int slen = OS.strlen(ptr);
            byteSelStart = Math.min(byteSelStart, slen);
            byteSelEnd = Math.min(byteSelEnd, slen);
            if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
                if ((data.style & SWT.MIRRORED) !is 0) {
                    Cairo.cairo_save(cairo);
                    Cairo.cairo_scale(cairo, -1,  1);
                    Cairo.cairo_translate(cairo, -2 * x - width(), 0);
                }
                drawWithCairo(gc, x, y, byteSelStart, byteSelEnd, fullSelection, selectionForeground.handle, selectionBackground.handle);
                if ((data.style & SWT.MIRRORED) !is 0) {
                    Cairo.cairo_restore(cairo);
                }
            } else {
                Region clipping = new Region();
                gc.getClipping(clipping);
                OS.gdk_draw_layout(data.drawable, gc.handle, x, y, layout);
                drawBorder(gc, x, y, null);
                int[] ranges = [byteSelStart, byteSelEnd];
                auto rgn = OS.gdk_pango_layout_get_clip_region(layout, x, y,
                              ranges.ptr, cast(int)/*64bit*/ranges.length / 2);
                if (rgn !is null) {
                    OS.gdk_gc_set_clip_region(gc.handle, rgn);
                    OS.gdk_region_destroy(rgn);
                }
                OS.gdk_draw_layout_with_colors(data.drawable, gc.handle, x, y, layout, selectionForeground.handle, selectionBackground.handle);
                drawBorder(gc, x, y, selectionForeground.handle);
                gc.setClipping(clipping);
                clipping.dispose();
            }
        }
    }
}

void drawWithCairo(GC gc, int x, int y, int start, int end, bool fullSelection, GdkColor* fg, GdkColor* bg) {
    GCData data = gc.data;
    cairo_t* cairo = data.cairo;
    Cairo.cairo_save(cairo);
    if (!fullSelection) {
        Cairo.cairo_move_to(cairo, x, y);
        OS.pango_cairo_show_layout(cairo, layout);
        drawBorder(gc, x, y, null);
    }
    int[] ranges = [start, end];
    auto rgn = OS.gdk_pango_layout_get_clip_region(layout, x, y, ranges.ptr,
                                                   cast(int)/*64bit*/ranges.length / 2);
    if (rgn !is null) {
        OS.gdk_cairo_region(cairo, rgn);
        Cairo.cairo_clip(cairo);
        Cairo.cairo_set_source_rgba(cairo, (bg.red & 0xFFFF) / cast(float)0xFFFF, (bg.green & 0xFFFF) / cast(float)0xFFFF, (bg.blue & 0xFFFF) / cast(float)0xFFFF, data.alpha / cast(float)0xFF);
        Cairo.cairo_paint(cairo);
        OS.gdk_region_destroy(rgn);
    }
    Cairo.cairo_set_source_rgba(cairo, (fg.red & 0xFFFF) / cast(float)0xFFFF, (fg.green & 0xFFFF) / cast(float)0xFFFF, (fg.blue & 0xFFFF) / cast(float)0xFFFF, data.alpha / cast(float)0xFF);
    Cairo.cairo_move_to(cairo, x, y);
    OS.pango_cairo_show_layout(cairo, layout);
    drawBorder(gc, x, y, fg);
    Cairo.cairo_restore(cairo);
}

void drawBorder(GC gc, int x, int y, GdkColor* selectionColor) {
    GCData data = gc.data;
    auto cairo = data.cairo;
    auto gdkGC = gc.handle;
    auto ptr = OS.pango_layout_get_text(layout);
    GdkGCValues* gcValues = null;
    if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
        Cairo.cairo_save(cairo);
    }
    for (int i = 0; i < styles.length - 1; i++) {
        TextStyle style = styles[i].style;
        if (style is null) continue;

        bool drawBorder = style.borderStyle !is SWT.NONE;
        if (drawBorder && !style.isAdherentBorder(styles[i+1].style)) {
            int start = styles[i].start;
            for (int j = i; j > 0 && style.isAdherentBorder(styles[j-1].style); j--) {
                start = styles[j - 1].start;
            }
            start = translateOffset(start);
            int end = translateOffset(styles[i+1].start - 1);
            int byteStart = cast(int)/*64bit*/(OS.g_utf8_offset_to_pointer(ptr, start) - ptr);
            int byteEnd = cast(int)/*64bit*/(OS.g_utf8_offset_to_pointer(ptr, end + 1) - ptr);
            int[] ranges = [byteStart, byteEnd];
            auto rgn = OS.gdk_pango_layout_get_clip_region(layout, x, y,
                          ranges.ptr, cast(int)/*64bit*/ranges.length / 2);
            if (rgn !is null) {
                int nRects;
                GdkRectangle* rects;
                OS.gdk_region_get_rectangles(rgn, &rects, &nRects);
                GdkRectangle rect;
                GdkColor* color = null;
                if (color is null && style.borderColor !is null) color = style.borderColor.handle;
                if (color is null && selectionColor !is null) color = selectionColor;
                if (color is null && style.foreground !is null) color = style.foreground.handle;
                if (color is null) color = data.foreground;
                int width = 1;
                TryConst!(float)[] dashes = null;
                switch (style.borderStyle) {
                    case SWT.BORDER_SOLID: break;
                    case SWT.BORDER_DASH: dashes = width !is 0 ? GC.LINE_DASH : GC.LINE_DASH_ZERO; break;
                    case SWT.BORDER_DOT: dashes = width !is 0 ? GC.LINE_DOT : GC.LINE_DOT_ZERO; break;
                    default: break;
                }
                if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
                    Cairo.cairo_set_source_rgba(cairo, (color.red & 0xFFFF) / cast(float)0xFFFF, (color.green & 0xFFFF) / cast(float)0xFFFF, (color.blue & 0xFFFF) / cast(float)0xFFFF, data.alpha / cast(float)0xFF);
                    Cairo.cairo_set_line_width(cairo, width);
                    if (dashes !is null) {
                        double[] cairoDashes = new double[dashes.length];
                        for (int j = 0; j < cairoDashes.length; j++) {
                            cairoDashes[j] = width is 0 || data.lineStyle is SWT.LINE_CUSTOM ? dashes[j] : dashes[j] * width;
                        }
                        Cairo.cairo_set_dash(cairo, cairoDashes.ptr,
                                             cast(int)/*64bit*/cairoDashes.length, 0);
                    } else {
                        Cairo.cairo_set_dash(cairo, null, 0, 0);
                    }
                    for (int j=0; j<nRects; j++) {
                        rect = rects[j];
                        Cairo.cairo_rectangle(cairo, rect.x + 0.5, rect.y + 0.5, rect.width - 1, rect.height - 1);
                    }
                    Cairo.cairo_stroke(cairo);
                } else {
                    if (gcValues is null) {
                        gcValues = new GdkGCValues();
                        OS.gdk_gc_get_values(gdkGC, gcValues);
                    }
                    OS.gdk_gc_set_foreground(gdkGC, color);
                    int cap_style = OS.GDK_CAP_BUTT;
                    int join_style = OS.GDK_JOIN_MITER;
                    int line_style = 0;
                    if (dashes !is null) {
                        byte[] dash_list = new byte[dashes.length];
                        for (int j = 0; j < dash_list.length; j++) {
                            dash_list[j] = cast(byte)(width is 0 || data.lineStyle is SWT.LINE_CUSTOM ? dashes[j] : dashes[j] * width);
                        }
                        OS.gdk_gc_set_dashes(gdkGC, 0, cast(char*)dash_list.ptr, cast(int)/*64bit*/dash_list.length);
                        line_style = OS.GDK_LINE_ON_OFF_DASH;
                    } else {
                        line_style = OS.GDK_LINE_SOLID;
                    }
                    OS.gdk_gc_set_line_attributes(gdkGC, width, line_style, cap_style, join_style);
                    for (int j=0; j<nRects; j++) {
                        rect = rects[j];
                        OS.gdk_draw_rectangle(data.drawable, gdkGC, 0, rect.x, rect.y, rect.width - 1, rect.height - 1);
                    }
                }
                if (rects !is null) OS.g_free(rects);
                OS.gdk_region_destroy(rgn);
            }
        }

        bool drawUnderline = false;
        if (style.underline && style.underlineColor !is null) drawUnderline = true;
        if (style.underline && (style.underlineStyle is SWT.UNDERLINE_ERROR || style.underlineStyle is SWT.UNDERLINE_SQUIGGLE)&& OS.GTK_VERSION < OS.buildVERSION(2, 4, 0)) drawUnderline = true;
        if (drawUnderline && !style.isAdherentUnderline(styles[i+1].style)) {
            int start = styles[i].start;
            for (int j = i; j > 0 && style.isAdherentUnderline(styles[j-1].style); j--) {
                start = styles[j - 1].start;
            }
            start = translateOffset(start);
            int end = translateOffset(styles[i+1].start - 1);
            int byteStart = cast(int)/*64bit*/(OS.g_utf8_offset_to_pointer(ptr, start) - ptr);
            int byteEnd = cast(int)/*64bit*/(OS.g_utf8_offset_to_pointer(ptr, end + 1) - ptr);
            int[] ranges = [byteStart, byteEnd];
            auto rgn = OS.gdk_pango_layout_get_clip_region(layout, x, y, ranges.ptr, cast(int)/*64bit*/ranges.length / 2);
            if (rgn !is null) {
                int nRects;
                GdkRectangle* rects;
                OS.gdk_region_get_rectangles(rgn, &rects, &nRects);
                GdkRectangle rect;
                GdkColor* color = null;
                if (color is null && style.underlineColor !is null) color = style.underlineColor.handle;
                if (color is null && selectionColor !is null) color = selectionColor;
                if (color is null && style.foreground !is null) color = style.foreground.handle;
                if (color is null) color = data.foreground;
                if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
                    Cairo.cairo_set_source_rgba(cairo, (color.red & 0xFFFF) / cast(float)0xFFFF, (color.green & 0xFFFF) / cast(float)0xFFFF, (color.blue & 0xFFFF) / cast(float)0xFFFF, data.alpha / cast(float)0xFF);
                } else {
                    if (gcValues is null) {
                        gcValues = new GdkGCValues();
                        OS.gdk_gc_get_values(gdkGC, gcValues);
                    }
                    OS.gdk_gc_set_foreground(gdkGC, color);
                }
                int underlinePosition = -1;
                int underlineThickness = 1;
                if (OS.GTK_VERSION >= OS.buildVERSION(2, 6, 0)) {
                    Font font = style.font;
                    if (font is null) font = this.font;
                    if (font is null) font = device.systemFont;
                    auto lang = OS.pango_context_get_language(context);
                    auto metrics = OS.pango_context_get_metrics(context, font.handle, lang);
                    underlinePosition = OS.PANGO_PIXELS(OS.pango_font_metrics_get_underline_position(metrics));
                    underlineThickness = OS.PANGO_PIXELS(OS.pango_font_metrics_get_underline_thickness(metrics));
                    OS.pango_font_metrics_unref(metrics);
                }
                for (int j=0; j<nRects; j++) {
                    rect = rects[j];
                    int offset = getOffset(rect.x - x, rect.y - y, null);
                    int lineIndex = getLineIndex(offset);
                    FontMetrics metrics = getLineMetrics(lineIndex);
                    int underlineY = rect.y + metrics.ascent - underlinePosition - style.rise;
                    switch (style.underlineStyle) {
                        case SWT.UNDERLINE_SQUIGGLE:
                        case SWT.UNDERLINE_ERROR: {
                            int squigglyThickness = underlineThickness;
                            int squigglyHeight = 2 * squigglyThickness;
                            int squigglyY = Math.min(underlineY, rect.y + rect.height - squigglyHeight - 1);
                            int[] points = computePolyline(rect.x, squigglyY, (rect.x + rect.width), squigglyY + squigglyHeight);
                            if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
                                Cairo.cairo_set_line_width(cairo, squigglyThickness);
                                Cairo.cairo_set_line_cap(cairo, Cairo.CAIRO_LINE_CAP_BUTT);
                                Cairo.cairo_set_line_join(cairo, Cairo.CAIRO_LINE_JOIN_MITER);
                                if (points.length > 0) {
                                    double xOffset = 0.5, yOffset = 0.5;
                                    Cairo.cairo_move_to(cairo, points[0] + xOffset, points[1] + yOffset);
                                    for (int k = 2; k < points.length; k += 2) {
                                        Cairo.cairo_line_to(cairo, points[k] + xOffset, points[k + 1] + yOffset);
                                    }
                                    Cairo.cairo_stroke(cairo);
                                }
                            } else {
                                OS.gdk_gc_set_line_attributes(gdkGC, squigglyThickness, OS.GDK_LINE_SOLID, OS.GDK_CAP_BUTT, OS.GDK_JOIN_MITER);
                                OS.gdk_draw_lines(data.drawable, gdkGC, cast(GdkPoint*)points.ptr, cast(int)/*64bit*/points.length / 2);
                            }
                            break;
                        }
                        case SWT.UNDERLINE_DOUBLE:
                            if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
                                Cairo.cairo_rectangle(cairo, rect.x, underlineY + underlineThickness * 2, rect.width, underlineThickness);
                                Cairo.cairo_fill(cairo);
                            } else {
                                OS.gdk_draw_rectangle(data.drawable, gdkGC, 1, rect.x, underlineY + underlineThickness * 2, rect.width, underlineThickness);
                            }
                            goto case SWT.UNDERLINE_SINGLE;
                        case SWT.UNDERLINE_SINGLE:
                            if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
                                Cairo.cairo_rectangle(cairo, rect.x, underlineY, rect.width, underlineThickness);
                                Cairo.cairo_fill(cairo);
                            } else {
                                OS.gdk_draw_rectangle(data.drawable, gdkGC, 1, rect.x, underlineY, rect.width, underlineThickness);
                            }
                            break;
                        default: break;
                    }
                }
                if (rects !is null) OS.g_free(rects);
                OS.gdk_region_destroy(rgn);
            }
        }

        bool drawStrikeout = false;
        if (style.strikeout && style.strikeoutColor !is null) drawStrikeout = true;
        if (drawStrikeout && !style.isAdherentStrikeout(styles[i+1].style)) {
            int start = styles[i].start;
            for (int j = i; j > 0 && style.isAdherentStrikeout(styles[j-1].style); j--) {
                start = styles[j - 1].start;
            }
            start = translateOffset(start);
            int end = translateOffset(styles[i+1].start - 1);
            int byteStart = cast(int)/*64bit*/(OS.g_utf8_offset_to_pointer(ptr, start) - ptr);
            int byteEnd = cast(int)/*64bit*/(OS.g_utf8_offset_to_pointer(ptr, end + 1) - ptr);
            int[] ranges = [byteStart, byteEnd];
            auto rgn = OS.gdk_pango_layout_get_clip_region(layout, x, y, ranges.ptr, cast(int)/*64bit*/ranges.length / 2);
            if (rgn !is null) {
                int nRects;
                GdkRectangle* rects;
                OS.gdk_region_get_rectangles(rgn, &rects, &nRects);
                GdkRectangle rect;
                GdkColor* color = null;
                if (color is null && style.strikeoutColor !is null) color = style.strikeoutColor.handle;
                if (color is null && selectionColor !is null) color = selectionColor;
                if (color is null && style.foreground !is null) color = style.foreground.handle;
                if (color is null) color = data.foreground;
                if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
                    Cairo.cairo_set_source_rgba(cairo, (color.red & 0xFFFF) / cast(float)0xFFFF, (color.green & 0xFFFF) / cast(float)0xFFFF, (color.blue & 0xFFFF) / cast(float)0xFFFF, data.alpha / cast(float)0xFF);
                } else {
                    if (gcValues is null) {
                        gcValues = new GdkGCValues();
                        OS.gdk_gc_get_values(gdkGC, gcValues);
                    }
                    OS.gdk_gc_set_foreground(gdkGC, color);
                }
                int strikeoutPosition = -1;
                int strikeoutThickness = 1;
                if (OS.GTK_VERSION >= OS.buildVERSION(2, 6, 0)) {
                    Font font = style.font;
                    if (font is null) font = this.font;
                    if (font is null) font = device.systemFont;
                    auto lang = OS.pango_context_get_language(context);
                    auto metrics = OS.pango_context_get_metrics(context, font.handle, lang);
                    strikeoutPosition = OS.PANGO_PIXELS(OS.pango_font_metrics_get_strikethrough_position(metrics));
                    strikeoutThickness = OS.PANGO_PIXELS(OS.pango_font_metrics_get_strikethrough_thickness(metrics));
                    OS.pango_font_metrics_unref(metrics);
                }
                for (int j=0; j<nRects; j++) {
                    rect = rects[j];
                    int strikeoutY = rect.y + rect.height / 2 - style.rise;
                    if (OS.GTK_VERSION >= OS.buildVERSION(2, 6, 0)) {
                        int offset = getOffset(rect.x - x, rect.y - y, null);
                        int lineIndex = getLineIndex(offset);
                        FontMetrics metrics = getLineMetrics(lineIndex);
                        strikeoutY = rect.y + metrics.ascent - strikeoutPosition - style.rise;
                    }
                    if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
                        Cairo.cairo_rectangle(cairo, rect.x, strikeoutY, rect.width, strikeoutThickness);
                        Cairo.cairo_fill(cairo);
                    } else {
                        OS.gdk_draw_rectangle(data.drawable, gdkGC, 1, rect.x, strikeoutY, rect.width, strikeoutThickness);
                    }
                }
                if (rects !is null) OS.g_free(rects);
                OS.gdk_region_destroy(rgn);
            }
        }
    }
    if (gcValues !is null) {
        int mask = OS.GDK_GC_FOREGROUND | OS.GDK_GC_LINE_WIDTH | OS.GDK_GC_LINE_STYLE | OS.GDK_GC_CAP_STYLE | OS.GDK_GC_JOIN_STYLE;
        OS.gdk_gc_set_values(gdkGC, gcValues, mask);
        data.state &= ~GC.LINE_STYLE;
    }
    if (cairo !is null && OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
        Cairo.cairo_restore(cairo);
    }
}

void freeRuns() {
    if (attrList is null) return;
    OS.pango_layout_set_attributes(layout, null );
    OS.pango_attr_list_unref(attrList);
    attrList = null;
    invalidOffsets = null;
}

/**
 * Returns the receiver's horizontal text alignment, which will be one
 * of <code>SWT.LEFT</code>, <code>SWT.CENTER</code> or
 * <code>SWT.RIGHT</code>.
 *
 * @return the alignment used to positioned text horizontally
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getAlignment() {
    checkLayout();
    auto alignment = OS.pango_layout_get_alignment(layout);
    bool rtl = OS.pango_context_get_base_dir(context) is OS.PANGO_DIRECTION_RTL;
    switch ( cast(int)alignment) {
        case OS.PANGO_ALIGN_LEFT: return rtl ? SWT.RIGHT : SWT.LEFT;
        case OS.PANGO_ALIGN_RIGHT: return rtl ? SWT.LEFT : SWT.RIGHT;
        default:
    }
    return SWT.CENTER;
}

/**
 * Returns the ascent of the receiver.
 *
 * @return the ascent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getDescent()
 * @see #setDescent(int)
 * @see #setAscent(int)
 * @see #getLineMetrics(int)
 */
public int getAscent () {
    checkLayout();
    return ascent;
}

/**
 * Returns the bounds of the receiver. The width returned is either the
 * width of the longest line or the width set using {@link TextLayout#setWidth(int)}.
 * To obtain the text bounds of a line use {@link TextLayout#getLineBounds(int)}.
 *
 * @return the bounds of the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setWidth(int)
 * @see #getLineBounds(int)
 */
public Rectangle getBounds() {
    checkLayout();
    computeRuns();
    int w, h;
    OS.pango_layout_get_size(layout, &w, &h);
    int wrapWidth = OS.pango_layout_get_width(layout);
    w = wrapWidth !is -1 ? wrapWidth : w + OS.pango_layout_get_indent(layout);
    int width = OS.PANGO_PIXELS(w);
    int height = OS.PANGO_PIXELS(h);
    if (ascent !is -1 && descent !is -1) {
        height = Math.max (height, ascent + descent);
    }
    return new Rectangle(0, 0, width, height);
}

/**
 * Returns the bounds for the specified range of characters. The
 * bounds is the smallest rectangle that encompasses all characters
 * in the range. The start and end offsets are inclusive and will be
 * clamped if out of range.
 *
 * @param start the start offset
 * @param end the end offset
 * @return the bounds of the character range
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Rectangle getBounds(int start, int end) {
    checkLayout();
    computeRuns();
    auto length_ = text.length;
    if (length_ is 0) return new Rectangle(0, 0, 0, 0);
    if (start > end) return new Rectangle(0, 0, 0, 0);
    start = cast(int)/*64bit*/Math.min(Math.max(0, start), length_ - 1);
    end = cast(int)/*64bit*/Math.min(Math.max(0, end), length_ - 1);
    start = translateOffset(start);
    end = translateOffset(end);
    auto ptr = OS.pango_layout_get_text(layout);
    auto cont = fromStringz(ptr);
    UTF8index longStart = start;
    UTF8index longEnd = end;
    cont.adjustUTF8index( longStart );
    cont.adjustUTF8index( longEnd );
    start = cast(int)/*64bit*/longStart;
    end = cast(int)/*64bit*/longEnd;
    int incr = 1;
    if( end < cont.length ){
        incr = cast(int)cont.UTF8strideAt(end);
    }
    auto byteStart = start;//(OS.g_utf8_offset_to_pointer (ptr, start) - ptr);
    auto byteEnd = end + incr;//(OS.g_utf8_offset_to_pointer (ptr, end + 1) - ptr);
    auto slen = OS.strlen(ptr);
    byteStart = Math.min(byteStart, slen);
    byteEnd = Math.min(byteEnd, slen);
    int[] ranges = [byteStart, byteEnd];
    auto clipRegion = OS.gdk_pango_layout_get_clip_region(layout, 0, 0, ranges.ptr, 1);
    if (clipRegion is null) return new Rectangle(0, 0, 0, 0);
    GdkRectangle rect;

    /*
    * Bug in Pango. The region returned by gdk_pango_layout_get_clip_region()
    * includes areas from lines outside of the requested range.  The fix
    * is to subtract these areas from the clip region.
    */
    PangoRectangle* pangoRect = new PangoRectangle();
    auto iter = OS.pango_layout_get_iter(layout);
    if (iter is null) SWT.error(SWT.ERROR_NO_HANDLES);
    auto linesRegion = OS.gdk_region_new();
    if (linesRegion is null) SWT.error(SWT.ERROR_NO_HANDLES);
    int lineEnd = 0;
    do {
        OS.pango_layout_iter_get_line_extents(iter, null, pangoRect);
        if (OS.pango_layout_iter_next_line(iter)) {
            lineEnd = OS.pango_layout_iter_get_index(iter) - 1;
        } else {
            lineEnd = slen;
        }
        if (byteStart > lineEnd) continue;
        rect.x = OS.PANGO_PIXELS(pangoRect.x);
        rect.y = OS.PANGO_PIXELS(pangoRect.y);
        rect.width = OS.PANGO_PIXELS(pangoRect.width);
        rect.height = OS.PANGO_PIXELS(pangoRect.height);
        OS.gdk_region_union_with_rect(linesRegion, &rect);
    } while (lineEnd + 1 <= byteEnd);
    OS.gdk_region_intersect(clipRegion, linesRegion);
    OS.gdk_region_destroy(linesRegion);
    OS.pango_layout_iter_free(iter);

    OS.gdk_region_get_clipbox(clipRegion, &rect);
    OS.gdk_region_destroy(clipRegion);
    if (OS.pango_context_get_base_dir(context) is OS.PANGO_DIRECTION_RTL) {
        rect.x = width() - rect.x - rect.width;
    }
    return new Rectangle(rect.x, rect.y, rect.width, rect.height);
}

/**
 * Returns the descent of the receiver.
 *
 * @return the descent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getAscent()
 * @see #setAscent(int)
 * @see #setDescent(int)
 * @see #getLineMetrics(int)
 */
public int getDescent () {
    checkLayout();
    return descent;
}

/**
 * Returns the default font currently being used by the receiver
 * to draw and measure text.
 *
 * @return the receiver's font
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Font getFont () {
    checkLayout();
    return font;
}

/**
* Returns the receiver's indent.
*
* @return the receiver's indent
*
* @exception SWTException <ul>
*    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
* </ul>
*
* @since 3.2
*/
public int getIndent () {
    checkLayout();
    return OS.PANGO_PIXELS(OS.pango_layout_get_indent(layout));
}

/**
* Returns the receiver's justification.
*
* @return the receiver's justification
*
* @exception SWTException <ul>
*    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
* </ul>
*
* @since 3.2
*/
public bool getJustify () {
    checkLayout();
    return cast(bool) OS.pango_layout_get_justify(layout);
}

/**
 * Returns the embedding level for the specified character offset. The
 * embedding level is usually used to determine the directionality of a
 * character in bidirectional text.
 *
 * @param offset the character offset
 * @return the embedding level
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the character offset is out of range</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 */
public int getLevel(int offset) {
    checkLayout();
    computeRuns();
    auto length_ = text.length;
    if (!(0 <= offset && offset <= length_)) SWT.error(SWT.ERROR_INVALID_RANGE);
    offset = translateOffset(offset);
    auto iter = OS.pango_layout_get_iter(layout);
    if (iter is null) SWT.error(SWT.ERROR_NO_HANDLES);
    int level = 0;
    PangoItem* item = new PangoItem();
    PangoLayoutRun* run = new PangoLayoutRun();
    auto ptr = OS.pango_layout_get_text(layout);
    auto byteOffset = offset;//OS.g_utf8_offset_to_pointer(ptr, offset) - ptr;
    auto slen = OS.strlen(ptr);
    byteOffset = Math.min(byteOffset, slen);
    do {
        auto runPtr = OS.pango_layout_iter_get_run(iter);
        if (runPtr !is null) {
            memmove(run, runPtr, PangoLayoutRun.sizeof);
            memmove(item, run.item, PangoItem.sizeof);
            if (item.offset <= byteOffset && byteOffset < item.offset + item.length) {
                level = item.analysis.level;
                break;
            }
        }
    } while (OS.pango_layout_iter_next_run(iter));
    OS.pango_layout_iter_free(iter);
    return level;
}

/**
 * Returns the bounds of the line for the specified line index.
 *
 * @param lineIndex the line index
 * @return the line bounds
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the line index is out of range</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Rectangle getLineBounds(int lineIndex) {
    checkLayout();
    computeRuns();
    int lineCount = OS.pango_layout_get_line_count(layout);
    if (!(0 <= lineIndex && lineIndex < lineCount)) SWT.error(SWT.ERROR_INVALID_RANGE);
    auto iter = OS.pango_layout_get_iter(layout);
    if (iter is null) SWT.error(SWT.ERROR_NO_HANDLES);
    for (int i = 0; i < lineIndex; i++) OS.pango_layout_iter_next_line(iter);
    PangoRectangle rect;
    OS.pango_layout_iter_get_line_extents(iter, null, &rect);
    OS.pango_layout_iter_free(iter);
    int x = OS.PANGO_PIXELS(rect.x);
    int y = OS.PANGO_PIXELS(rect.y);
    int width_ = OS.PANGO_PIXELS(rect.width);
    int height = OS.PANGO_PIXELS(rect.height);
    if (ascent !is -1 && descent !is -1) {
        height = Math.max (height, ascent + descent);
    }
    if (OS.pango_context_get_base_dir(context) is OS.PANGO_DIRECTION_RTL) {
        x = width() - x - width_;
    }
    return new Rectangle(x, y, width_, height);
}

/**
 * Returns the receiver's line count. This includes lines caused
 * by wrapping.
 *
 * @return the line count
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getLineCount() {
    checkLayout ();
    computeRuns();
    return OS.pango_layout_get_line_count(layout);
}

/**
 * Returns the index of the line that contains the specified
 * character offset.
 *
 * @param offset the character offset
 * @return the line index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the character offset is out of range</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getLineIndex(int offset) {
    checkLayout ();
    computeRuns();
    auto length_ = text.length;
    if (!(0 <= offset && offset <= length_)) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    offset = translateOffset(offset);
    int line = 0;
    auto ptr = OS.pango_layout_get_text(layout);
    auto byteOffset = offset;//OS.g_utf8_offset_to_pointer(ptr,offset) - ptr;
    int slen = OS.strlen(ptr);
    byteOffset = Math.min(byteOffset, slen);
    auto iter = OS.pango_layout_get_iter(layout);
    if (iter is null) SWT.error(SWT.ERROR_NO_HANDLES);
    while (OS.pango_layout_iter_next_line(iter)) {
        if (OS.pango_layout_iter_get_index(iter) > byteOffset) break;
        line++;
    }
    OS.pango_layout_iter_free(iter);
    return line;
}

/**
 * Returns the font metrics for the specified line index.
 *
 * @param lineIndex the line index
 * @return the font metrics
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the line index is out of range</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public FontMetrics getLineMetrics (int lineIndex) {
    checkLayout ();
    computeRuns();
    int lineCount = OS.pango_layout_get_line_count(layout);
    if (!(0 <= lineIndex && lineIndex < lineCount)) SWT.error(SWT.ERROR_INVALID_RANGE);
    int ascent = 0, descent = 0;
    PangoLayoutLine* line = new PangoLayoutLine();
    memmove(line, OS.pango_layout_get_line(layout, lineIndex), PangoLayoutLine.sizeof);
    if (line.runs is null) {
        auto font = this.font !is null ? this.font.handle : device.systemFont.handle;
        auto lang = OS.pango_context_get_language(context);
        auto metrics = OS.pango_context_get_metrics(context, font, lang);
        ascent = OS.pango_font_metrics_get_ascent(metrics);
        descent = OS.pango_font_metrics_get_descent(metrics);
        OS.pango_font_metrics_unref(metrics);
    } else {
        PangoRectangle rect;
        OS.pango_layout_line_get_extents(OS.pango_layout_get_line(layout, lineIndex), null, &rect);
        ascent = -rect.y;
        descent = rect.height - ascent;
    }
    ascent = Math.max(this.ascent, OS.PANGO_PIXELS(ascent));
    descent = Math.max(this.descent, OS.PANGO_PIXELS(descent));
    return FontMetrics.gtk_new(ascent, descent, 0, 0, ascent + descent);
}

/**
 * Returns the line offsets.  Each value in the array is the
 * offset for the first character in a line except for the last
 * value, which contains the length of the text.
 *
 * @return the line offsets
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int[] getLineOffsets() {
    checkLayout();
    computeRuns();
    int lineCount = OS.pango_layout_get_line_count(layout);
    int[] offsets = new int [lineCount + 1];
    auto ptr = OS.pango_layout_get_text(layout);
    for (int i = 0; i < lineCount; i++) {
        auto line = OS.pango_layout_get_line(layout, i);
        int pos = cast(int)/*64bit*/OS.g_utf8_pointer_to_offset(ptr, ptr + line.start_index);
        offsets[i] = untranslateOffset(pos);
    }
    offsets[lineCount] = cast(int)/*64bit*/text.length;
    return offsets;
}

/**
 * Returns the location for the specified character offset. The
 * <code>trailing</code> argument indicates whether the offset
 * corresponds to the leading or trailing edge of the cluster.
 *
 * @param offset the character offset
 * @param trailing the trailing flag
 * @return the location of the character offset
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getOffset(Point, int[])
 * @see #getOffset(int, int, int[])
 */
public Point getLocation(int offset, bool trailing) {
    checkLayout();
    computeRuns();
    auto length_ = text.length;
    if (!(0 <= offset && offset <= length_)) SWT.error(SWT.ERROR_INVALID_RANGE);
    offset = translateOffset(offset);
    auto ptr = OS.pango_layout_get_text(layout);
    auto cont = fromStringz(ptr);
    ptrdiff_t longOffset = offset;
    cont.adjustUTF8index(longOffset);
    // leading ZWS+ZWNBS are 2 codepoints in 6 bytes, so we miss 4 bytes here
    int byteOffset = cast(int)/*64bit*/longOffset;//(OS.g_utf8_offset_to_pointer(ptr, offset) - ptr);
    int slen = cast(int)/*64bit*/cont.length;
    byteOffset = Math.min(byteOffset, slen);
    PangoRectangle* pos = new PangoRectangle();
    OS.pango_layout_index_to_pos(layout, byteOffset, pos);
    int x = trailing ? pos.x + pos.width : pos.x;
    int y = pos.y;
    x = OS.PANGO_PIXELS(x);
    if (OS.pango_context_get_base_dir(context) is OS.PANGO_DIRECTION_RTL) {
        x = width() - x;
    }
    return new Point(x, OS.PANGO_PIXELS(y));
}

/**
 * Returns the next offset for the specified offset and movement
 * type.  The movement is one of <code>SWT.MOVEMENT_CHAR</code>,
 * <code>SWT.MOVEMENT_CLUSTER</code>, <code>SWT.MOVEMENT_WORD</code>,
 * <code>SWT.MOVEMENT_WORD_END</code> or <code>SWT.MOVEMENT_WORD_START</code>.
 *
 * @param offset the start offset
 * @param movement the movement type
 * @return the next offset
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the offset is out of range</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getPreviousOffset(int, int)
 */
public int getNextOffset (int offset, int movement) {
    return _getOffset(offset, movement, true);
}

int _getOffset (int offset, int movement, bool forward) {
    checkLayout();
    computeRuns();
    auto length_ = text.length;
    if (!(0 <= offset && offset <= length_)) SWT.error(SWT.ERROR_INVALID_RANGE);
    if (forward) {
        if (offset is length_) return cast(int)/*64bit*/length_;
    } else {
        if (offset is 0) return 0;
    }
    auto cont = OS.pango_layout_get_text(layout);
    assert( cont );
    auto dcont = fromStringz(cont);
    int step = forward ? 1 : -1;
    if ((movement & SWT.MOVEMENT_CHAR) !is 0){
        //PORTING take care of utf8
        ptrdiff_t toffset = translateOffset(offset);
        dcont.adjustUTF8index( toffset );
        int incr = cast(int)/*64bit*/dcont.toUTF8shift(toffset, step);
        return offset + incr;
    }
    PangoLogAttr* attrs;
    int nAttrs;
    // return one attr per codepoint (=char in pango)
    OS.pango_layout_get_log_attrs(layout, &attrs, &nAttrs);
    if (attrs is null) return offset + step;
    length_ = dcont.length;//OS.g_utf8_strlen(cont, -1);
    offset = translateOffset(offset);
    ptrdiff_t longOffset = offset;
    dcont.adjustUTF8index( longOffset );
    offset = cast(int)/*64bit*/longOffset;

    PangoLogAttr* logAttr;
    offset = validateOffset( dcont, offset, step);
    // the loop is byte oriented
    while (0 < offset && offset < length_) {
        logAttr = & attrs[ OS.g_utf8_pointer_to_offset( cont, cont+offset) ];
        if (((movement & SWT.MOVEMENT_CLUSTER) !is 0) && logAttr.is_cursor_position ) break;
        if ((movement & SWT.MOVEMENT_WORD) !is 0) {
            if (forward) {
                if (logAttr.is_word_end ) break;
            } else {
                if (logAttr.is_word_start ) break;
            }
        }
        if ((movement & SWT.MOVEMENT_WORD_START) !is 0) {
            if (logAttr.is_word_start ) break;
        }
        if ((movement & SWT.MOVEMENT_WORD_END) !is 0) {
            if (logAttr.is_word_end ) break;
        }
        offset = validateOffset( dcont, offset, step);
    }
    OS.g_free(attrs);
    return cast(int)/*64bit*/Math.min(Math.max
                           (0, untranslateOffset(offset)), text.length);
}

/**
 * Returns the character offset for the specified point.
 * For a typical character, the trailing argument will be filled in to
 * indicate whether the point is closer to the leading edge (0) or
 * the trailing edge (1).  When the point is over a cluster composed
 * of multiple characters, the trailing argument will be filled with the
 * position of the character in the cluster that is closest to
 * the point.
 *
 * @param point the point
 * @param trailing the trailing buffer
 * @return the character offset
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the trailing length is less than <code>1</code></li>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getLocation(int, bool)
 */
public int getOffset(Point point, int[] trailing) {
    checkLayout();
    if (point is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    return getOffset(point.x, point.y, trailing);
}

/**
 * Returns the character offset for the specified point.
 * For a typical character, the trailing argument will be filled in to
 * indicate whether the point is closer to the leading edge (0) or
 * the trailing edge (1).  When the point is over a cluster composed
 * of multiple characters, the trailing argument will be filled with the
 * position of the character in the cluster that is closest to
 * the point.
 *
 * @param x the x coordinate of the point
 * @param y the y coordinate of the point
 * @param trailing the trailing buffer
 * @return the character offset
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the trailing length is less than <code>1</code></li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getLocation(int, bool)
 */
public int getOffset(int x, int y, int[] trailing) {
    checkLayout();
    computeRuns();
    if (trailing !is null && trailing.length < 1) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (OS.pango_context_get_base_dir(context) is OS.PANGO_DIRECTION_RTL) {
        x = width() - x;
    }

    /*
    * Feature in GTK.  pango_layout_xy_to_index() returns the
    * logical end/start offset of a line when the coordinates are outside
    * the line bounds. In SWT the correct behavior is to return the closest
    * visual offset. The fix is to clamp the coordinates inside the
    * line bounds.
    */
    auto iter = OS.pango_layout_get_iter(layout);
    if (iter is null) SWT.error(SWT.ERROR_NO_HANDLES);
    PangoRectangle rect;
    do {
        OS.pango_layout_iter_get_line_extents(iter, null, &rect);
        rect.y = OS.PANGO_PIXELS(rect.y);
        rect.height = OS.PANGO_PIXELS(rect.height);
        if (rect.y <= y && y < rect.y + rect.height) {
            rect.x = OS.PANGO_PIXELS(rect.x);
            rect.width = OS.PANGO_PIXELS(rect.width);
            if (x >= rect.x + rect.width) x = rect.x + rect.width - 1;
            if (x < rect.x) x = rect.x;
            break;
        }
    } while (OS.pango_layout_iter_next_line(iter));
    OS.pango_layout_iter_free(iter);

    int index;
    int piTrailing;
    OS.pango_layout_xy_to_index(layout, x * OS.PANGO_SCALE, y * OS.PANGO_SCALE, &index, &piTrailing);
    auto ptr = OS.pango_layout_get_text(layout);
    int offset = index;//OS.g_utf8_pointer_to_offset(ptr, ptr + index);
    if (trailing !is null) trailing[0] = piTrailing;
    return untranslateOffset(offset);
}

/**
 * Returns the orientation of the receiver.
 *
 * @return the orientation style
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getOrientation() {
    checkLayout();
    ptrdiff_t baseDir = OS.pango_context_get_base_dir(context);
    return baseDir is OS.PANGO_DIRECTION_RTL ? SWT.RIGHT_TO_LEFT : SWT.LEFT_TO_RIGHT;
}

/**
 * Returns the previous offset for the specified offset and movement
 * type.  The movement is one of <code>SWT.MOVEMENT_CHAR</code>,
 * <code>SWT.MOVEMENT_CLUSTER</code> or <code>SWT.MOVEMENT_WORD</code>,
 * <code>SWT.MOVEMENT_WORD_END</code> or <code>SWT.MOVEMENT_WORD_START</code>.
 *
 * @param offset the start offset
 * @param movement the movement type
 * @return the previous offset
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the offset is out of range</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getNextOffset(int, int)
 */
public int getPreviousOffset (int index, int movement) {
    return _getOffset(index, movement, false);
}

/**
 * Gets the ranges of text that are associated with a <code>TextStyle</code>.
 *
 * @return the ranges, an array of offsets representing the start and end of each
 * text style.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getStyles()
 *
 * @since 3.2
 */
public int[] getRanges () {
    checkLayout();
    int[] result = new int[styles.length * 2];
    int count = 0;
    for (int i=0; i<styles.length - 1; i++) {
        if (styles[i].style !is null) {
            result[count++] = styles[i].start;
            result[count++] = styles[i + 1].start - 1;
        }
    }
    if (count !is result.length) {
        int[] newResult = new int[count];
        System.arraycopy(result, 0, newResult, 0, count);
        result = newResult;
    }
    return result;
}

/**
 * Returns the text segments offsets of the receiver.
 *
 * @return the text segments offsets
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int[] getSegments() {
    checkLayout();
    return segments;
}

String getSegmentsText() {
    if (segments is null) return text;
    auto nSegments = segments.length;
    if (nSegments <= 1) return text;
    auto len = text.length;
    if (len is 0) return text;
    if (nSegments is 2) {
        if (segments[0] is 0 && segments[1] is len) return text;
    }
    char[] oldChars = text[0..len].dup;
    char[] newChars = new char[len + nSegments*3];
    int charCount = 0, segmentCount = 0;
    String separator = getOrientation() is SWT.RIGHT_TO_LEFT ? STR_RTL_MARK : STR_LTR_MARK;
    while (charCount < len) {
        if (segmentCount < nSegments && charCount is segments[segmentCount]) {
            newChars[charCount + segmentCount .. charCount + segmentCount + separator.length ] = separator;
            segmentCount+=separator.length;
        } else {
            newChars[charCount + segmentCount] = oldChars[charCount];
            charCount++;
        }
    }
    if (segmentCount < nSegments) {
        segments[segmentCount] = charCount;
        newChars[charCount + segmentCount .. charCount + segmentCount + separator.length ] = separator;
        segmentCount+=separator.length;
    }
    return cast(String)newChars[ 0 .. Math.min(charCount + segmentCount, newChars.length) ];
}

/**
 * Returns the line spacing of the receiver.
 *
 * @return the line spacing
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getSpacing () {
    checkLayout();
    return OS.PANGO_PIXELS(OS.pango_layout_get_spacing(layout));
}

/**
 * Gets the style of the receiver at the specified character offset.
 *
 * @param offset the text offset
 * @return the style or <code>null</code> if not set
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the character offset is out of range</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public TextStyle getStyle (int offset) {
    checkLayout();
    auto length_ = text.length;
    if (!(0 <= offset && offset < length_)) SWT.error(SWT.ERROR_INVALID_RANGE);
    for (int i=1; i<styles.length; i++) {
        StyleItem item = styles[i];
        if (item.start > offset) {
            return styles[i - 1].style;
        }
    }
    return null;
}

/**
 * Gets all styles of the receiver.
 *
 * @return the styles
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getRanges()
 *
 * @since 3.2
 */
public TextStyle[] getStyles () {
    checkLayout();
    TextStyle[] result = new TextStyle[styles.length];
    int count = 0;
    for (int i=0; i<styles.length; i++) {
        if (styles[i].style !is null) {
            result[count++] = styles[i].style;
        }
    }
    if (count !is result.length) {
        TextStyle[] newResult = new TextStyle[count];
        System.arraycopy(result, 0, newResult, 0, count);
        result = newResult;
    }
    return result;
}

/**
 * Returns the tab list of the receiver.
 *
 * @return the tab list
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int[] getTabs() {
    checkLayout();
    return tabs;
}

/**
 * Gets the receiver's text, which will be an empty
 * string if it has never been set.
 *
 * @return the receiver's text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public String getText () {
    checkLayout ();
    return text;
}

/**
 * Returns the width of the receiver.
 *
 * @return the width
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getWidth () {
    checkLayout ();
    int width = OS.pango_layout_get_width(layout);
    return width !is -1 ? OS.PANGO_PIXELS(width) : -1;
}

/**
 * Returns <code>true</code> if the text layout has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the text layout.
 * When a text layout has been disposed, it is an error to
 * invoke any other method using the text layout.
 * </p>
 *
 * @return <code>true</code> when the text layout is disposed and <code>false</code> otherwise
 */
public override bool isDisposed () {
    return layout is null;
}

/**
 * Sets the text alignment for the receiver. The alignment controls
 * how a line of text is positioned horizontally. The argument should
 * be one of <code>SWT.LEFT</code>, <code>SWT.RIGHT</code> or <code>SWT.CENTER</code>.
 * <p>
 * The default alignment is <code>SWT.LEFT</code>.  Note that the receiver's
 * width must be set in order to use <code>SWT.RIGHT</code> or <code>SWT.CENTER</code>
 * alignment.
 * </p>
 *
 * @param alignment the new alignment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setWidth(int)
 */
public void setAlignment (int alignment) {
    checkLayout();
    int mask = SWT.LEFT | SWT.CENTER | SWT.RIGHT;
    alignment &= mask;
    if (alignment is 0) return;
    if ((alignment & SWT.LEFT) !is 0) alignment = SWT.LEFT;
    if ((alignment & SWT.RIGHT) !is 0) alignment = SWT.RIGHT;
    bool rtl = OS.pango_context_get_base_dir(context) is OS.PANGO_DIRECTION_RTL;
    int align_ = OS.PANGO_ALIGN_CENTER;
    switch (alignment) {
        case SWT.LEFT:
            align_ = rtl ? OS.PANGO_ALIGN_RIGHT : OS.PANGO_ALIGN_LEFT;
            break;
        case SWT.RIGHT:
            align_ = rtl ? OS.PANGO_ALIGN_LEFT : OS.PANGO_ALIGN_RIGHT;
            break;
        default: break;
    }
    OS.pango_layout_set_alignment(layout, align_);
}

/**
 * Sets the ascent of the receiver. The ascent is distance in pixels
 * from the baseline to the top of the line and it is applied to all
 * lines. The default value is <code>-1</code> which means that the
 * ascent is calculated from the line fonts.
 *
 * @param ascent the new ascent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the ascent is less than <code>-1</code></li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setDescent(int)
 * @see #getLineMetrics(int)
 */
public void setAscent (int ascent) {
    checkLayout();
    if (ascent < -1) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (this.ascent is ascent) return;
    freeRuns();
    this.ascent = ascent;
}

/**
 * Sets the descent of the receiver. The descent is distance in pixels
 * from the baseline to the bottom of the line and it is applied to all
 * lines. The default value is <code>-1</code> which means that the
 * descent is calculated from the line fonts.
 *
 * @param descent the new descent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the descent is less than <code>-1</code></li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setAscent(int)
 * @see #getLineMetrics(int)
 */
public void setDescent (int descent) {
    checkLayout();
    if (descent < -1) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (this.descent is descent) return;
    freeRuns();
    this.descent = descent;
}

/**
 * Sets the default font which will be used by the receiver
 * to draw and measure text. If the
 * argument is null, then a default font appropriate
 * for the platform will be used instead. Note that a text
 * style can override the default font.
 *
 * @param font the new font for the receiver, or null to indicate a default font
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the font has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setFont (Font font) {
    checkLayout ();
    if (font !is null && font.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    Font oldFont = this.font;
    if (oldFont is font) return;
    freeRuns();
    this.font = font;
    if (oldFont !is null && oldFont.opEquals(font)) return;
    OS.pango_layout_set_font_description(layout, font !is null ? font.handle : device.systemFont.handle);
}

/**
 * Sets the indent of the receiver. This indent it applied of the first line of
 * each paragraph.
 *
 * @param indent new indent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.2
 */
public void setIndent (int indent) {
    checkLayout();
    if (indent < 0) return;
    OS.pango_layout_set_indent(layout, indent * OS.PANGO_SCALE);
}

/**
 * Sets the justification of the receiver. Note that the receiver's
 * width must be set in order to use justification.
 *
 * @param justify new justify
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.2
 */
public void setJustify (bool justify) {
    checkLayout();
    OS.pango_layout_set_justify(layout, justify);
}

/**
 * Sets the orientation of the receiver, which must be one
 * of <code>SWT.LEFT_TO_RIGHT</code> or <code>SWT.RIGHT_TO_LEFT</code>.
 *
 * @param orientation new orientation style
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setOrientation(int orientation) {
    checkLayout();
    int mask = SWT.RIGHT_TO_LEFT | SWT.LEFT_TO_RIGHT;
    orientation &= mask;
    if (orientation is 0) return;
    if ((orientation & SWT.LEFT_TO_RIGHT) !is 0) orientation = SWT.LEFT_TO_RIGHT;
    int baseDir = orientation is SWT.RIGHT_TO_LEFT ? OS.PANGO_DIRECTION_RTL : OS.PANGO_DIRECTION_LTR;
    if (OS.pango_context_get_base_dir(context) is baseDir) return;
    OS.pango_context_set_base_dir(context, baseDir);
    OS.pango_layout_context_changed(layout);
    int align_ = OS.pango_layout_get_alignment(layout);
    if (align_ !is OS.PANGO_ALIGN_CENTER) {
        align_ = align_ is OS.PANGO_ALIGN_LEFT ? OS.PANGO_ALIGN_RIGHT : OS.PANGO_ALIGN_LEFT;
        OS.pango_layout_set_alignment(layout, align_);
    }
}

/**
 * Sets the line spacing of the receiver.  The line spacing
 * is the space left between lines.
 *
 * @param spacing the new line spacing
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the spacing is negative</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setSpacing (int spacing) {
    checkLayout();
    if (spacing < 0) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    OS.pango_layout_set_spacing(layout, spacing * OS.PANGO_SCALE);
}

/**
 * Sets the offsets of the receiver's text segments. Text segments are used to
 * override the default behaviour of the bidirectional algorithm.
 * Bidirectional reordering can happen within a text segment but not
 * between two adjacent segments.
 * <p>
 * Each text segment is determined by two consecutive offsets in the
 * <code>segments</code> arrays. The first element of the array should
 * always be zero and the last one should always be equals to length of
 * the text.
 * </p>
 *
 * @param segments the text segments offset
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setSegments(int[] segments) {
    checkLayout();
    if (this.segments is null && segments is null) return;
    if (this.segments !is null && segments !is null) {
        if (this.segments.length is segments.length) {
            int i;
            for (i = 0; i <segments.length; i++) {
                if (this.segments[i] !is segments[i]) break;
            }
            if (i is segments.length) return;
        }
    }
    freeRuns();
    this.segments = segments;
}

/**
 * Sets the style of the receiver for the specified range.  Styles previously
 * set for that range will be overwritten.  The start and end offsets are
 * inclusive and will be clamped if out of range.
 *
 * @param style the style
 * @param start the start offset
 * @param end the end offset
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setStyle (TextStyle style, int start, int end) {
    checkLayout();
    auto length_ = text.length;
    if (length_ is 0) return;
    if (start > end) return;
    start = cast(int)/*64bit*/Math.min(Math.max(0, start), length_ - 1);
    end = cast(int)/*64bit*/Math.min(Math.max(0, end), length_ - 1);
    ptrdiff_t longStart = start;
    ptrdiff_t longEnd = end;
    text.adjustUTF8index( longStart );
    text.adjustUTF8index( longEnd );
    start = cast(int)/*64bit*/longStart;
    end = cast(int)/*64bit*/longEnd;


    /*
    * Bug in Pango. Pango 1.2.2 will cause a segmentation fault if a style
    * is not applied for a whole ligature.  The fix is to applied the
    * style for the whole ligature.
    *
    * NOTE that fix only LamAlef ligatures.
    */
    if ((start > 0 ) && isAlef(text.dcharAt(start)) && isLam(text.dcharBefore(start))) {
        start += text.offsetBefore(start);
    }
    if ((end < length_ - 1) && isLam(text.dcharAt(end)) && isAlef(text.dcharAfter(end))) {
        end = cast(int)/*64bit*/text.offsetAfter(end);
    }

    int low = -1;
    int high = cast(int)/*64bit*/styles.length;
    while (high - low > 1) {
        auto index = (high + low) / 2;
        if (styles[index + 1].start > start) {
            high = index;
        } else {
            low = index;
        }
    }
    if (0 <= high && high < styles.length) {
        StyleItem item = styles[high];
        if (item.start is start && styles[high + 1].start - 1 is end) {
            if (style is null) {
                if (item.style is null) return;
            } else {
                if (style.opEquals(item.style)) return;
            }
        }
    }
    freeRuns();
    auto modifyStart = high;
    auto modifyEnd = modifyStart;
    while (modifyEnd < styles.length) {
        if (styles[modifyEnd + 1].start > end) break;
        modifyEnd++;
    }
    if (modifyStart is modifyEnd) {
        auto styleStart = styles[modifyStart].start;
        auto styleEnd = styles[modifyEnd + 1].start - 1;
        if (styleStart is start && styleEnd is end) {
            styles[modifyStart].style = style;
            return;
        }
        if (styleStart !is start && styleEnd !is end) {
            StyleItem[] newStyles = new StyleItem[styles.length + 2];
            System.arraycopy(styles, 0, newStyles, 0, modifyStart + 1);
            StyleItem item = new StyleItem();
            item.start = start;
            item.style = style;
            newStyles[modifyStart + 1] = item;
            item = new StyleItem();
            item.start = end + 1;
            item.style = styles[modifyStart].style;
            newStyles[modifyStart + 2] = item;
            System.arraycopy(styles, modifyEnd + 1, newStyles, modifyEnd + 3, styles.length - modifyEnd - 1);
            styles = newStyles;
            return;
        }
    }
    if (start is styles[modifyStart].start) modifyStart--;
    if (end is styles[modifyEnd + 1].start - 1) modifyEnd++;
    auto newLength = styles.length + 1 - (modifyEnd - modifyStart - 1);
    StyleItem[] newStyles = new StyleItem[newLength];
    System.arraycopy(styles, 0, newStyles, 0, modifyStart + 1);
    StyleItem item = new StyleItem();
    item.start = start;
    item.style = style;
    newStyles[modifyStart + 1] = item;
    styles[modifyEnd].start = end + 1;
    System.arraycopy(styles, modifyEnd, newStyles, modifyStart + 2, styles.length - modifyEnd);
    styles = newStyles;
}

/**
 * Sets the receiver's tab list. Each value in the tab list specifies
 * the space in pixels from the origin of the text layout to the respective
 * tab stop.  The last tab stop width is repeated continuously.
 *
 * @param tabs the new tab list
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setTabs(int[] tabs) {
    checkLayout();
    if (this.tabs is null && tabs is null) return;
    if (this.tabs!is null && tabs !is null) {
        if (this.tabs.length is tabs.length) {
            int i;
            for (i = 0; i <tabs.length; i++) {
                if (this.tabs[i] !is tabs[i]) break;
            }
            if (i is tabs.length) return;
        }
    }
    this.tabs = tabs;
    if (tabs is null) {
        OS.pango_layout_set_tabs(layout, device.emptyTab);
    } else {
        auto tabArray = OS.pango_tab_array_new(cast(int)/*64bit*/tabs.length, true);
        if (tabArray !is null) {
            for (int i = 0; i < tabs.length; i++) {
                OS.pango_tab_array_set_tab(tabArray, i, OS.PANGO_TAB_LEFT, tabs[i]);
            }
            OS.pango_layout_set_tabs(layout, tabArray);
            OS.pango_tab_array_free(tabArray);
        }
    }
    /*
    * Bug in Pango. A change in the tab stop array is not automatically reflected in the
    * pango layout object because the call pango_layout_set_tabs() does not free the
    * lines cache. The fix to use pango_layout_context_changed() to free the lines cache.
    */
    OS.pango_layout_context_changed(layout);
}

/**
 * Sets the receiver's text.
 *
 * @param text the new text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setText (String text) {
    checkLayout ();
    if (text.equals(this.text)) return;
    freeRuns();
    this.text = text;
    styles = new StyleItem[2];
    styles[0] = new StyleItem();
    styles[1] = new StyleItem();
    styles[styles.length - 1].start = cast(int)/*64bit*/text.length;
}

/**
 * Sets the line width of the receiver, which determines how
 * text should be wrapped and aligned. The default value is
 * <code>-1</code> which means wrapping is disabled.
 *
 * @param width the new width
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the width is <code>0</code> or less than <code>-1</code></li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setAlignment(int)
 */
public void setWidth (int width) {
    checkLayout ();
    if (width < -1 || width is 0) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    freeRuns();
    if (width is -1) {
        OS.pango_layout_set_width(layout, -1);
        bool rtl = OS.pango_context_get_base_dir(context) is OS.PANGO_DIRECTION_RTL;
        OS.pango_layout_set_alignment(layout, rtl ? OS.PANGO_ALIGN_RIGHT : OS.PANGO_ALIGN_LEFT);
    } else {
        OS.pango_layout_set_width(layout, width * OS.PANGO_SCALE);
    }
}

static final bool isLam(int ch) {
    return ch is 0x0644;
}

static final bool isAlef(int ch) {
    switch (ch) {
        case 0x0622:
        case 0x0623:
        case 0x0625:
        case 0x0627:
        case 0x0649:
        case 0x0670:
        case 0x0671:
        case 0x0672:
        case 0x0673:
        case 0x0675:
            return true;
        default:
    }
    return false;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
public override String toString () {
    if (isDisposed()) return "TextLayout {*DISPOSED*}";
    return Format( "TextLayout {{{}}", layout );
}

/*
 *  Translate a client offset to an internal offset
 */
int translateOffset(int offset) {
    auto length_ = text.length;
    if (length_ is 0) return offset;
    if (invalidOffsets is null) return offset;
    for (int i = 0; i < invalidOffsets.length; i++) {
        if (offset < invalidOffsets[i]) break;
        offset++;
    }
    return offset;
}

/*
 *  Translate an internal offset to a client offset
 */
int untranslateOffset(int offset) {
    auto length_ = text.length;
    if (length_ is 0) return offset;
    if (invalidOffsets is null) return offset;
    for (int i = 0; i < invalidOffsets.length; i++) {
        if (offset is invalidOffsets[i]) {
            offset++;
            continue;
        }
        if (offset < invalidOffsets[i]) {
            return offset - i;
        }
    }
    return cast(int)/*64bit*/(offset - invalidOffsets.length);
}

int validateOffset( in char[] cont, int offset, int step) {
    if (invalidOffsets is null) return offset + step;
    size_t i = step > 0 ? 0 : invalidOffsets.length - 1;
    do {
        if( offset is 0 && step < 0 ){
            offset += step;
        }
        else{
            offset += cont.toUTF8shift( offset, step );
        }
        while (0 <= i && i < invalidOffsets.length) {
            if (invalidOffsets[i] is offset) break;
            i += step;
        }
    } while (0 <= i && i < invalidOffsets.length);
    return offset;
}

int width () {
    int wrapWidth = OS.pango_layout_get_width(layout);
    if (wrapWidth !is -1) return OS.PANGO_PIXELS(wrapWidth);
    int w, h;
    OS.pango_layout_get_size(layout, &w, &h);
    return OS.PANGO_PIXELS(w + OS.pango_layout_get_indent(layout));
}

}
