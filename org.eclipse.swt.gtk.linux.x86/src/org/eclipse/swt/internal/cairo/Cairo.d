/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * Contributor(s):
 *
 * IBM
 * -  Binding to permit interfacing between Cairo and SWT
 * -  Copyright (C) 2005 IBM Corp.  All Rights Reserved.
 *
 * ***** END LICENSE BLOCK ***** */
/* Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 */
module org.eclipse.swt.internal.cairo.Cairo;

import java.lang.all;

import  org.eclipse.swt.internal.c.cairo;
import  org.eclipse.swt.internal.c.cairo_xlib;
import  org.eclipse.swt.internal.c.cairo_ps;
import  org.eclipse.swt.internal.c.cairo_pdf;
import  org.eclipse.swt.internal.c.Xlib;
import  org.eclipse.swt.internal.Platform;

version(Tango){
    import tango.core.Traits;
} else { // Phobos
    import std.traits;
}

public alias org.eclipse.swt.internal.c.cairo.cairo_t cairo_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_pattern_t cairo_pattern_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_surface_t cairo_surface_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_text_extents_t cairo_text_extents_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_font_extents_t cairo_font_extents_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_matrix_t cairo_matrix_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_path_t cairo_path_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_path_data_t cairo_path_data_t;

/++++
private extern(C) {
cairo_surface_t *
cairo_xlib_surface_create (void     *dpy,
               XID/*Drawable*/ drawable,
               Visual      *visual,
               int      width,
               int      height);
}
++++/

private int CAIRO_VERSION_ENCODE(int major, int minor, int micro) {
    return ((major) * 10000)
        + ((minor) *   100)
        + ((micro) *     1);
}

template NameOfFunc(alias f) {
    // Note: highly dependent on the .stringof formatting
    // the value begins with "& " which is why the first two chars are cut off
    version( LDC ){
        // stringof in LLVMDC is "&foobar"
        const char[] NameOfFunc = (&f).stringof[1 .. $];
    }
    else{
        // stringof in DMD is "& foobar"
        const char[] NameOfFunc = (&f).stringof[2 .. $];
    }
}

template ForwardGtkCairoCFunc( alias cFunc ) {
    version(Tango){
        alias ParameterTupleOf!(cFunc) P;
        alias ReturnTypeOf!(cFunc) R;
        mixin("public static R " ~ NameOfFunc!(cFunc) ~ "( P p ){
                lock.lock();
                scope(exit) lock.unlock();
                return cFunc(p);
                }");
    } else { // Phobos
        alias ParameterTypeTuple!(cFunc) P;
        alias ReturnType!(cFunc) R;
        mixin("public static R " ~ NameOfFunc!(cFunc) ~ "( P p ){
                lock.lock();
                scope(exit) lock.unlock();
                return cFunc(p);
                }");
    }
}

public class Cairo : Platform {

    /** Constants */
    public static const int CAIRO_ANTIALIAS_DEFAULT = 0;
    public static const int CAIRO_ANTIALIAS_NONE = 1;
    public static const int CAIRO_ANTIALIAS_GRAY = 2;
    public static const int CAIRO_ANTIALIAS_SUBPIXEL = 3;
    public static const int CAIRO_FORMAT_ARGB32 = 0;
    public static const int CAIRO_FORMAT_RGB24 = 1;
    public static const int CAIRO_FORMAT_A8 = 2;
    public static const int CAIRO_FORMAT_A1 = 3;
    public static const int CAIRO_OPERATOR_CLEAR = 0;
    public static const int CAIRO_OPERATOR_SRC = 1;
    public static const int CAIRO_OPERATOR_DST = 2;
    public static const int CAIRO_OPERATOR_OVER = 3;
    public static const int CAIRO_OPERATOR_OVER_REVERSE = 4;
    public static const int CAIRO_OPERATOR_IN = 5;
    public static const int CAIRO_OPERATOR_IN_REVERSE = 6;
    public static const int CAIRO_OPERATOR_OUT = 7;
    public static const int CAIRO_OPERATOR_OUT_REVERSE = 8;
    public static const int CAIRO_OPERATOR_ATOP = 9;
    public static const int CAIRO_OPERATOR_ATOP_REVERSE = 10;
    public static const int CAIRO_OPERATOR_XOR = 11;
    public static const int CAIRO_OPERATOR_ADD = 12;
    public static const int CAIRO_OPERATOR_SATURATE = 13;
    public static const int CAIRO_FILL_RULE_WINDING = 0;
    public static const int CAIRO_FILL_RULE_EVEN_ODD = 1;
    public static const int CAIRO_LINE_CAP_BUTT = 0;
    public static const int CAIRO_LINE_CAP_ROUND = 1;
    public static const int CAIRO_LINE_CAP_SQUARE = 2;
    public static const int CAIRO_LINE_JOIN_MITER = 0;
    public static const int CAIRO_LINE_JOIN_ROUND = 1;
    public static const int CAIRO_LINE_JOIN_BEVEL = 2;
    public static const int CAIRO_FONT_SLANT_NORMAL = 0;
    public static const int CAIRO_FONT_SLANT_ITALIC = 1;
    public static const int CAIRO_FONT_SLANT_OBLIQUE = 2;
    public static const int CAIRO_FONT_WEIGHT_NORMAL = 0;
    public static const int CAIRO_FONT_WEIGHT_BOLD = 1;
    public static const int CAIRO_STATUS_SUCCESS = 0;
    public static const int CAIRO_STATUS_NO_MEMORY = 1;
    public static const int CAIRO_STATUS_INVALID_RESTORE = 2;
    public static const int CAIRO_STATUS_INVALID_POP_GROUP = 3;
    public static const int CAIRO_STATUS_NO_CURRENT_POINT = 4;
    public static const int CAIRO_STATUS_INVALID_MATRIX = 5;
    public static const int CAIRO_STATUS_NO_TARGET_SURFACE = 6;
    public static const int CAIRO_STATUS_NULL_POINTER =7;
    public static const int CAIRO_SURFACE_TYPE_IMAGE = 0;
    public static const int CAIRO_SURFACE_TYPE_PDF = 1;
    public static const int CAIRO_SURFACE_TYPE_PS = 2;
    public static const int CAIRO_SURFACE_TYPE_XLIB = 3;
    public static const int CAIRO_SURFACE_TYPE_XCB = 4;
    public static const int CAIRO_SURFACE_TYPE_GLITZ = 5;
    public static const int CAIRO_SURFACE_TYPE_QUARTZ = 6;
    public static const int CAIRO_SURFACE_TYPE_WIN32 = 7;
    public static const int CAIRO_SURFACE_TYPE_BEOS = 8;
    public static const int CAIRO_SURFACE_TYPE_DIRECTFB = 9;
    public static const int CAIRO_SURFACE_TYPE_SVG = 10;
    public static const int CAIRO_FILTER_FAST = 0;
    public static const int CAIRO_FILTER_GOOD = 1;
    public static const int CAIRO_FILTER_BEST = 2;
    public static const int CAIRO_FILTER_NEAREST = 3;
    public static const int CAIRO_FILTER_BILINEAR = 4;
    public static const int CAIRO_FILTER_GAUSSIAN = 5;
    public static const int CAIRO_EXTEND_NONE = 0;
    public static const int CAIRO_EXTEND_REPEAT = 1;
    public static const int CAIRO_EXTEND_REFLECT = 2;
    public static const int CAIRO_EXTEND_PAD = 3;
    public static const int CAIRO_PATH_MOVE_TO = 0;
    public static const int CAIRO_PATH_LINE_TO = 1;
    public static const int CAIRO_PATH_CURVE_TO = 2;
    public static const int CAIRO_PATH_CLOSE_PATH = 3;

    mixin ForwardGtkCairoCFunc!(.CAIRO_VERSION_ENCODE);
    mixin ForwardGtkCairoCFunc!(.cairo_append_path);
    mixin ForwardGtkCairoCFunc!(.cairo_arc);
    mixin ForwardGtkCairoCFunc!(.cairo_arc_negative);
    mixin ForwardGtkCairoCFunc!(.cairo_clip);
    mixin ForwardGtkCairoCFunc!(.cairo_clip_preserve);
    mixin ForwardGtkCairoCFunc!(.cairo_close_path);
    mixin ForwardGtkCairoCFunc!(.cairo_copy_page);
    mixin ForwardGtkCairoCFunc!(.cairo_copy_path);
    mixin ForwardGtkCairoCFunc!(.cairo_copy_path_flat);
    mixin ForwardGtkCairoCFunc!(.cairo_create);
    mixin ForwardGtkCairoCFunc!(.cairo_curve_to);
    mixin ForwardGtkCairoCFunc!(.cairo_destroy);
    mixin ForwardGtkCairoCFunc!(.cairo_device_to_user);
    mixin ForwardGtkCairoCFunc!(.cairo_device_to_user_distance);
    mixin ForwardGtkCairoCFunc!(.cairo_fill);
    mixin ForwardGtkCairoCFunc!(.cairo_fill_extents);
    mixin ForwardGtkCairoCFunc!(.cairo_fill_preserve);
    mixin ForwardGtkCairoCFunc!(.cairo_font_extents);
    mixin ForwardGtkCairoCFunc!(.cairo_font_options_create);
    mixin ForwardGtkCairoCFunc!(.cairo_font_options_destroy);
    mixin ForwardGtkCairoCFunc!(.cairo_font_options_get_antialias);
    mixin ForwardGtkCairoCFunc!(.cairo_font_options_set_antialias);
    mixin ForwardGtkCairoCFunc!(.cairo_get_antialias);
    mixin ForwardGtkCairoCFunc!(.cairo_get_current_point);
    mixin ForwardGtkCairoCFunc!(.cairo_get_fill_rule);
    mixin ForwardGtkCairoCFunc!(.cairo_get_font_face);
    mixin ForwardGtkCairoCFunc!(.cairo_get_font_matrix);
    mixin ForwardGtkCairoCFunc!(.cairo_get_font_options);
    mixin ForwardGtkCairoCFunc!(.cairo_get_line_cap);
    mixin ForwardGtkCairoCFunc!(.cairo_get_line_join);
    mixin ForwardGtkCairoCFunc!(.cairo_get_line_width);
    mixin ForwardGtkCairoCFunc!(.cairo_get_matrix);
    mixin ForwardGtkCairoCFunc!(.cairo_get_miter_limit);
    mixin ForwardGtkCairoCFunc!(.cairo_get_operator);
    mixin ForwardGtkCairoCFunc!(.cairo_get_source);
    mixin ForwardGtkCairoCFunc!(.cairo_get_target);
    mixin ForwardGtkCairoCFunc!(.cairo_get_tolerance);
    mixin ForwardGtkCairoCFunc!(.cairo_glyph_extents);
    mixin ForwardGtkCairoCFunc!(.cairo_glyph_path);
    mixin ForwardGtkCairoCFunc!(.cairo_identity_matrix);
    mixin ForwardGtkCairoCFunc!(.cairo_image_surface_create);
    mixin ForwardGtkCairoCFunc!(.cairo_image_surface_create_for_data);
    mixin ForwardGtkCairoCFunc!(.cairo_image_surface_get_height);
    mixin ForwardGtkCairoCFunc!(.cairo_image_surface_get_width);
    mixin ForwardGtkCairoCFunc!(.cairo_in_fill);
    mixin ForwardGtkCairoCFunc!(.cairo_in_stroke);
    mixin ForwardGtkCairoCFunc!(.cairo_line_to);
    mixin ForwardGtkCairoCFunc!(.cairo_mask);
    mixin ForwardGtkCairoCFunc!(.cairo_mask_surface);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_init);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_init_identity);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_init_rotate);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_init_scale);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_init_translate);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_invert);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_multiply);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_rotate);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_scale);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_transform_distance);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_transform_point);
    mixin ForwardGtkCairoCFunc!(.cairo_matrix_translate);
    mixin ForwardGtkCairoCFunc!(.cairo_move_to);
    mixin ForwardGtkCairoCFunc!(.cairo_new_path);
    mixin ForwardGtkCairoCFunc!(.cairo_paint);
    mixin ForwardGtkCairoCFunc!(.cairo_paint_with_alpha);
    mixin ForwardGtkCairoCFunc!(.cairo_path_destroy);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_add_color_stop_rgb);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_add_color_stop_rgba);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_create_for_surface);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_create_linear);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_create_radial);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_destroy);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_get_extend);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_get_filter);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_get_matrix);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_reference);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_set_extend);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_set_filter);
    mixin ForwardGtkCairoCFunc!(.cairo_pattern_set_matrix);
    mixin ForwardGtkCairoCFunc!(.cairo_pdf_surface_set_size);
    mixin ForwardGtkCairoCFunc!(.cairo_ps_surface_set_size);
    mixin ForwardGtkCairoCFunc!(.cairo_rectangle);
    mixin ForwardGtkCairoCFunc!(.cairo_reference);
    mixin ForwardGtkCairoCFunc!(.cairo_rel_curve_to);
    mixin ForwardGtkCairoCFunc!(.cairo_rel_line_to);
    mixin ForwardGtkCairoCFunc!(.cairo_rel_move_to);
    mixin ForwardGtkCairoCFunc!(.cairo_reset_clip);
    mixin ForwardGtkCairoCFunc!(.cairo_restore);
    mixin ForwardGtkCairoCFunc!(.cairo_rotate);
    mixin ForwardGtkCairoCFunc!(.cairo_save);
    mixin ForwardGtkCairoCFunc!(.cairo_scale);
    mixin ForwardGtkCairoCFunc!(.cairo_select_font_face);
    mixin ForwardGtkCairoCFunc!(.cairo_set_antialias);
    mixin ForwardGtkCairoCFunc!(.cairo_set_dash);
    mixin ForwardGtkCairoCFunc!(.cairo_set_fill_rule);
    mixin ForwardGtkCairoCFunc!(.cairo_set_font_face);
    mixin ForwardGtkCairoCFunc!(.cairo_set_font_matrix);
    mixin ForwardGtkCairoCFunc!(.cairo_set_font_options);
    mixin ForwardGtkCairoCFunc!(.cairo_set_font_size);
    mixin ForwardGtkCairoCFunc!(.cairo_set_line_cap);
    mixin ForwardGtkCairoCFunc!(.cairo_set_line_join);
    mixin ForwardGtkCairoCFunc!(.cairo_set_line_width);
    mixin ForwardGtkCairoCFunc!(.cairo_set_matrix);
    mixin ForwardGtkCairoCFunc!(.cairo_set_miter_limit);
    mixin ForwardGtkCairoCFunc!(.cairo_set_operator);
    mixin ForwardGtkCairoCFunc!(.cairo_set_source);
    mixin ForwardGtkCairoCFunc!(.cairo_set_source_rgb);
    mixin ForwardGtkCairoCFunc!(.cairo_set_source_rgba);
    mixin ForwardGtkCairoCFunc!(.cairo_set_source_surface);
    mixin ForwardGtkCairoCFunc!(.cairo_set_tolerance);
    mixin ForwardGtkCairoCFunc!(.cairo_show_glyphs);
    mixin ForwardGtkCairoCFunc!(.cairo_show_page);
    mixin ForwardGtkCairoCFunc!(.cairo_show_text);
    mixin ForwardGtkCairoCFunc!(.cairo_status);
    mixin ForwardGtkCairoCFunc!(.cairo_status_to_string);
    mixin ForwardGtkCairoCFunc!(.cairo_stroke);
    mixin ForwardGtkCairoCFunc!(.cairo_stroke_extents);
    mixin ForwardGtkCairoCFunc!(.cairo_stroke_preserve);
    mixin ForwardGtkCairoCFunc!(.cairo_surface_create_similar);
    mixin ForwardGtkCairoCFunc!(.cairo_surface_destroy);
    mixin ForwardGtkCairoCFunc!(.cairo_surface_finish);
    mixin ForwardGtkCairoCFunc!(.cairo_surface_get_type);
    mixin ForwardGtkCairoCFunc!(.cairo_surface_get_user_data);
    mixin ForwardGtkCairoCFunc!(.cairo_surface_reference);
    mixin ForwardGtkCairoCFunc!(.cairo_surface_set_device_offset);
    mixin ForwardGtkCairoCFunc!(.cairo_surface_set_fallback_resolution);
    mixin ForwardGtkCairoCFunc!(.cairo_surface_set_user_data);
    mixin ForwardGtkCairoCFunc!(.cairo_text_extents);
    mixin ForwardGtkCairoCFunc!(.cairo_text_path);
    mixin ForwardGtkCairoCFunc!(.cairo_transform);
    mixin ForwardGtkCairoCFunc!(.cairo_translate);
    mixin ForwardGtkCairoCFunc!(.cairo_user_to_device);
    mixin ForwardGtkCairoCFunc!(.cairo_user_to_device_distance);
    mixin ForwardGtkCairoCFunc!(.cairo_version);
    mixin ForwardGtkCairoCFunc!(.cairo_xlib_surface_create);
    /++/
    mixin ForwardGtkCairoCFunc!(.cairo_xlib_surface_create_for_bitmap);
    mixin ForwardGtkCairoCFunc!(.cairo_xlib_surface_set_size);
/++/
}
