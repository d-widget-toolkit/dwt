/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.Xrender;

import java.lang.all;

public import org.eclipse.swt.internal.c.Xlib;
private import org.eclipse.swt.internal.c.X;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):

const c_int PictStandardARGB32 = 0;
const c_int PictStandardRGB24 = 1;
const c_int PictStandardA8 = 2;
const c_int PictStandardA4 = 3;
const c_int PictStandardA1 = 4;
const c_int PictStandardNUM = 5;
alias _XConicalGradient XConicalGradient;
alias _XPointFixed XPointFixed;
alias c_int XFixed;
alias _XRadialGradient XRadialGradient;
alias _XCircle XCircle;
alias _XLinearGradient XLinearGradient;
alias _XTrap XTrap;
alias _XSpanFix XSpanFix;
alias _XAnimCursor XAnimCursor;
alias _XIndexValue XIndexValue;
alias _XFilters XFilters;
alias _XTransform XTransform;
alias _XTrapezoid XTrapezoid;
alias _XLineFixed XLineFixed;
alias _XTriangle XTriangle;
alias _XPointDouble XPointDouble;
alias double XDouble;
alias _XGlyphElt32 XGlyphElt32;
alias _XGlyphElt16 XGlyphElt16;
alias _XGlyphElt8 XGlyphElt8;
alias _XGlyphInfo XGlyphInfo;
alias _XRenderPictureAttributes XRenderPictureAttributes;
alias void function(void *, char *, c_int, c_int, char * *) _BCD_func__1287;
alias c_int function(void *) _BCD_func__1329;
alias c_int function(void *, XErrorEvent *) _BCD_func__1330;
alias void function(void *, char *, char *) _BCD_func__1403;
alias c_int function(void *, char *, char *) _BCD_func__1404;
alias void function(void *, char *, char *) _BCD_func__1405;
struct _XConicalGradient {
_XPointFixed center;
XFixed angle;
}
struct _XRadialGradient {
_XCircle inner;
_XCircle outer;
}
struct _XLinearGradient {
_XPointFixed p1;
_XPointFixed p2;
}
struct _XTrap {
_XSpanFix top;
_XSpanFix bottom;
}
struct _XSpanFix {
XFixed left;
XFixed right;
XFixed y;
}
struct _XAnimCursor {
Cursor cursor;
c_uint delay;
}
struct _XIndexValue {
c_uint pixel;
ushort red;
ushort green;
ushort blue;
ushort alpha;
}
struct _XFilters {
c_int nfilter;
char * * filter;
c_int nalias;
short * alias_;
}
struct _XTransform {
XFixed [3] [3] matrix;
}
struct _XTrapezoid {
XFixed top;
XFixed bottom;
_XLineFixed left;
_XLineFixed right;
}
struct _XCircle {
XFixed x;
XFixed y;
XFixed radius;
}
struct _XTriangle {
_XPointFixed p1;
_XPointFixed p2;
_XPointFixed p3;
}
struct _XLineFixed {
_XPointFixed p1;
_XPointFixed p2;
}
struct _XPointFixed {
XFixed x;
XFixed y;
}
struct _XPointDouble {
double x;
double y;
}
struct _XGlyphElt32 {
GlyphSet glyphset;
c_uint * chars;
c_int nchars;
c_int xOff;
c_int yOff;
}
struct _XGlyphElt16 {
GlyphSet glyphset;
ushort * chars;
c_int nchars;
c_int xOff;
c_int yOff;
}
struct _XGlyphElt8 {
GlyphSet glyphset;
char * chars;
c_int nchars;
c_int xOff;
c_int yOff;
}
struct _XGlyphInfo {
ushort width;
ushort height;
short x;
short y;
short xOff;
short yOff;
}
struct XRenderColor {
ushort red;
ushort green;
ushort blue;
ushort alpha;
}
struct _XRenderPictureAttributes {
c_int repeat;
Picture alpha_map;
c_int alpha_x_origin;
c_int alpha_y_origin;
c_int clip_x_origin;
c_int clip_y_origin;
Pixmap clip_mask;
Bool graphics_exposures;
c_int subwindow_mode;
c_int poly_edge;
c_int poly_mode;
Atom dither;
Bool component_alpha;
}
struct XRenderPictFormat {
PictFormat id;
c_int type;
c_int depth;
XRenderDirectFormat direct;
Colormap colormap;
}
struct XRenderDirectFormat {
short red;
short redMask;
short green;
short greenMask;
short blue;
short blueMask;
short alpha;
short alphaMask;
}
version(DYNLINK){
mixin(gshared!(
"extern(C) Picture function(Display*, const XConicalGradient*, const XFixed*, const XRenderColor*, c_int) XRenderCreateConicalGradient;
extern(C) Picture function(Display*, const XRadialGradient*, const XFixed*, const XRenderColor*, c_int) XRenderCreateRadialGradient;
extern(C) Picture function(Display*, const XLinearGradient*, const XFixed*, const XRenderColor*, c_int) XRenderCreateLinearGradient;
extern(C) Picture function(Display*, const XRenderColor*) XRenderCreateSolidFill;
extern(C) void function(Display*, Picture, c_int, c_int, const XTrap*, c_int) XRenderAddTraps;
extern(C) Cursor function(Display*, c_int, XAnimCursor*) XRenderCreateAnimCursor;
extern(C) void function(Display*, Picture, char*, const char*, XFixed*, c_int) XRenderSetPictureFilter;
extern(C) XFilters* function(Display*, Drawable) XRenderQueryFilters;
extern(C) Cursor function(Display*, Picture, c_uint, c_uint) XRenderCreateCursor;
extern(C) c_int function(Display*, char*, XRenderColor*) XRenderParseColor;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, c_int, c_int, const XPointDouble*, c_int, c_int) XRenderCompositeDoublePoly;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, const XPointFixed*, c_int) XRenderCompositeTriFan;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, const XPointFixed*, c_int) XRenderCompositeTriStrip;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, const XTriangle*, c_int) XRenderCompositeTriangles;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, const XTrapezoid*, c_int) XRenderCompositeTrapezoids;
extern(C) void function(Display*, c_int, Picture, const XRenderColor*, const XRectangle*, c_int n_rects) XRenderFillRectangles;
extern(C) void function(Display*, c_int, Picture, const XRenderColor*, c_int, c_int, c_uint, c_uint) XRenderFillRectangle;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, c_int, c_int, const XGlyphElt32*, c_int) XRenderCompositeText32;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, c_int, c_int, const XGlyphElt16*, c_int) XRenderCompositeText16;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, c_int, c_int, const XGlyphElt8*, c_int) XRenderCompositeText8;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, GlyphSet, c_int, c_int, c_int, c_int, const c_uint*, c_int) XRenderCompositeString32;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, GlyphSet, c_int, c_int, c_int, c_int, const ushort*, c_int) XRenderCompositeString16;
extern(C) void function(Display*, c_int, Picture, Picture, const XRenderPictFormat*, GlyphSet, c_int, c_int, c_int, c_int, const char*, c_int) XRenderCompositeString8;
extern(C) void function(Display*, GlyphSet, const Glyph*, c_int) XRenderFreeGlyphs;
extern(C) void function(Display*, GlyphSet, const Glyph*, const XGlyphInfo*, c_int, const char*, c_int) XRenderAddGlyphs;
extern(C) void function(Display*, GlyphSet) XRenderFreeGlyphSet;
extern(C) GlyphSet function(Display*, GlyphSet) XRenderReferenceGlyphSet;
extern(C) GlyphSet function(Display*, const XRenderPictFormat*) XRenderCreateGlyphSet;
extern(C) void function(Display*, c_int, Picture, Picture, Picture, c_int, c_int, c_int, c_int, c_int, c_int, c_uint, c_uint) XRenderComposite;
extern(C) void function(Display*, Picture) XRenderFreePicture;
extern(C) void function(Display*, Picture, XTransform*) XRenderSetPictureTransform;
extern(C) void function(Display*, Picture, Region) XRenderSetPictureClipRegion;
extern(C) void function(Display*, Picture, c_int, c_int, const XRectangle*, c_int) XRenderSetPictureClipRectangles;
extern(C) void function(Display*, Picture, c_ulong, const XRenderPictureAttributes*) XRenderChangePicture;
extern(C) Picture function(Display*, Drawable, const XRenderPictFormat*, c_ulong, const XRenderPictureAttributes*) XRenderCreatePicture;
extern(C) XIndexValue* function(Display*, const XRenderPictFormat*, c_int*) XRenderQueryPictIndexValues;
extern(C) XRenderPictFormat* function(Display*, c_int) XRenderFindStandardFormat;
extern(C) XRenderPictFormat* function(Display*, c_ulong, const XRenderPictFormat*, c_int) XRenderFindFormat;
extern(C) XRenderPictFormat* function(Display*, const Visual*) XRenderFindVisualFormat;
extern(C) Bool function(Display*, c_int, c_int) XRenderSetSubpixelOrder;
extern(C) c_int function(Display*, c_int) XRenderQuerySubpixelOrder;
extern(C) Status function(Display* dpy) XRenderQueryFormats;
extern(C) Status function(Display*, c_int*, c_int*) XRenderQueryVersion;
extern(C) Bool function(Display*, c_int*, c_int*) XRenderQueryExtension;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("XRenderCreateConicalGradient",  cast(void**)& XRenderCreateConicalGradient),
        Symbol("XRenderCreateRadialGradient",  cast(void**)& XRenderCreateRadialGradient),
        Symbol("XRenderCreateLinearGradient",  cast(void**)& XRenderCreateLinearGradient),
        Symbol("XRenderCreateSolidFill",  cast(void**)& XRenderCreateSolidFill),
        Symbol("XRenderAddTraps",  cast(void**)& XRenderAddTraps),
        Symbol("XRenderCreateAnimCursor",  cast(void**)& XRenderCreateAnimCursor),
        Symbol("XRenderSetPictureFilter",  cast(void**)& XRenderSetPictureFilter),
        Symbol("XRenderQueryFilters",  cast(void**)& XRenderQueryFilters),
        Symbol("XRenderCreateCursor",  cast(void**)& XRenderCreateCursor),
        Symbol("XRenderParseColor",  cast(void**)& XRenderParseColor),
        Symbol("XRenderCompositeDoublePoly",  cast(void**)& XRenderCompositeDoublePoly),
        Symbol("XRenderCompositeTriFan",  cast(void**)& XRenderCompositeTriFan),
        Symbol("XRenderCompositeTriStrip",  cast(void**)& XRenderCompositeTriStrip),
        Symbol("XRenderCompositeTriangles",  cast(void**)& XRenderCompositeTriangles),
        Symbol("XRenderCompositeTrapezoids",  cast(void**)& XRenderCompositeTrapezoids),
        Symbol("XRenderFillRectangles",  cast(void**)& XRenderFillRectangles),
        Symbol("XRenderFillRectangle",  cast(void**)& XRenderFillRectangle),
        Symbol("XRenderCompositeText32",  cast(void**)& XRenderCompositeText32),
        Symbol("XRenderCompositeText16",  cast(void**)& XRenderCompositeText16),
        Symbol("XRenderCompositeText8",  cast(void**)& XRenderCompositeText8),
        Symbol("XRenderCompositeString32",  cast(void**)& XRenderCompositeString32),
        Symbol("XRenderCompositeString16",  cast(void**)& XRenderCompositeString16),
        Symbol("XRenderCompositeString8",  cast(void**)& XRenderCompositeString8),
        Symbol("XRenderFreeGlyphs",  cast(void**)& XRenderFreeGlyphs),
        Symbol("XRenderAddGlyphs",  cast(void**)& XRenderAddGlyphs),
        Symbol("XRenderFreeGlyphSet",  cast(void**)& XRenderFreeGlyphSet),
        Symbol("XRenderReferenceGlyphSet",  cast(void**)& XRenderReferenceGlyphSet),
        Symbol("XRenderCreateGlyphSet",  cast(void**)& XRenderCreateGlyphSet),
        Symbol("XRenderComposite",  cast(void**)& XRenderComposite),
        Symbol("XRenderFreePicture",  cast(void**)& XRenderFreePicture),
        Symbol("XRenderSetPictureTransform",  cast(void**)& XRenderSetPictureTransform),
        Symbol("XRenderSetPictureClipRegion",  cast(void**)& XRenderSetPictureClipRegion),
        Symbol("XRenderSetPictureClipRectangles",  cast(void**)& XRenderSetPictureClipRectangles),
        Symbol("XRenderChangePicture",  cast(void**)& XRenderChangePicture),
        Symbol("XRenderCreatePicture",  cast(void**)& XRenderCreatePicture),
        Symbol("XRenderQueryPictIndexValues",  cast(void**)& XRenderQueryPictIndexValues),
        Symbol("XRenderFindStandardFormat",  cast(void**)& XRenderFindStandardFormat),
        Symbol("XRenderFindFormat",  cast(void**)& XRenderFindFormat),
        Symbol("XRenderFindVisualFormat",  cast(void**)& XRenderFindVisualFormat),
        Symbol("XRenderSetSubpixelOrder",  cast(void**)& XRenderSetSubpixelOrder),
        Symbol("XRenderQuerySubpixelOrder",  cast(void**)& XRenderQuerySubpixelOrder),
        Symbol("XRenderQueryFormats",  cast(void**)& XRenderQueryFormats),
        Symbol("XRenderQueryVersion",  cast(void**)& XRenderQueryVersion),
        Symbol("XRenderQueryExtension",  cast(void**)& XRenderQueryExtension)
    ];
}

} else { // version(DYNLINK)
extern(C) Picture XRenderCreateConicalGradient(Display*, const XConicalGradient*, const XFixed*, const XRenderColor*, c_int);
extern(C) Picture XRenderCreateRadialGradient(Display*, const XRadialGradient*, const XFixed*, const XRenderColor*, c_int);
extern(C) Picture XRenderCreateLinearGradient(Display*, const XLinearGradient*, const XFixed*, const XRenderColor*, c_int);
extern(C) Picture XRenderCreateSolidFill(Display*, const XRenderColor*);
extern(C) void XRenderAddTraps(Display*, Picture, c_int, c_int, const XTrap*, c_int);
extern(C) Cursor XRenderCreateAnimCursor(Display*, c_int, XAnimCursor*);
extern(C) void XRenderSetPictureFilter(Display*, Picture, char*, const char*, XFixed*, c_int);
extern(C) XFilters* XRenderQueryFilters(Display*, Drawable);
extern(C) Cursor XRenderCreateCursor(Display*, Picture, c_uint, c_uint);
extern(C) c_int XRenderParseColor(Display*, char*, XRenderColor*);
extern(C) void XRenderCompositeDoublePoly(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, c_int, c_int, const XPointDouble*, c_int, c_int);
extern(C) void XRenderCompositeTriFan(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, const XPointFixed*, c_int);
extern(C) void XRenderCompositeTriStrip(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, const XPointFixed*, c_int);
extern(C) void XRenderCompositeTriangles(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, const XTriangle*, c_int);
extern(C) void XRenderCompositeTrapezoids(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, const XTrapezoid*, c_int);
extern(C) void XRenderFillRectangles(Display*, c_int, Picture, const XRenderColor*, const XRectangle*, c_int n_rects);
extern(C) void XRenderFillRectangle(Display*, c_int, Picture, const XRenderColor*, c_int, c_int, c_uint, c_uint);
extern(C) void XRenderCompositeText32(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, c_int, c_int, const XGlyphElt32*, c_int);
extern(C) void XRenderCompositeText16(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, c_int, c_int, const XGlyphElt16*, c_int);
extern(C) void XRenderCompositeText8(Display*, c_int, Picture, Picture, const XRenderPictFormat*, c_int, c_int, c_int, c_int, const XGlyphElt8*, c_int);
extern(C) void XRenderCompositeString32(Display*, c_int, Picture, Picture, const XRenderPictFormat*, GlyphSet, c_int, c_int, c_int, c_int, const c_uint*, c_int);
extern(C) void XRenderCompositeString16(Display*, c_int, Picture, Picture, const XRenderPictFormat*, GlyphSet, c_int, c_int, c_int, c_int, const ushort*, c_int);
extern(C) void XRenderCompositeString8(Display*, c_int, Picture, Picture, const XRenderPictFormat*, GlyphSet, c_int, c_int, c_int, c_int, const char*, c_int);
extern(C) void XRenderFreeGlyphs(Display*, GlyphSet, const Glyph*, c_int);
extern(C) void XRenderAddGlyphs(Display*, GlyphSet, const Glyph*, const XGlyphInfo*, c_int, const char*, c_int);
extern(C) void XRenderFreeGlyphSet(Display*, GlyphSet);
extern(C) GlyphSet XRenderReferenceGlyphSet(Display*, GlyphSet);
extern(C) GlyphSet XRenderCreateGlyphSet(Display*, const XRenderPictFormat*);
extern(C) void XRenderComposite(Display*, c_int, Picture, Picture, Picture, c_int, c_int, c_int, c_int, c_int, c_int, c_uint, c_uint);
extern(C) void XRenderFreePicture(Display*, Picture);
extern(C) void XRenderSetPictureTransform(Display*, Picture, XTransform*);
extern(C) void XRenderSetPictureClipRegion(Display*, Picture, Region);
extern(C) void XRenderSetPictureClipRectangles(Display*, Picture, c_int, c_int, const XRectangle*, c_int);
extern(C) void XRenderChangePicture(Display*, Picture, c_ulong, const XRenderPictureAttributes*);
extern(C) Picture XRenderCreatePicture(Display*, Drawable, const XRenderPictFormat*, c_ulong, const XRenderPictureAttributes*);
extern(C) XIndexValue* XRenderQueryPictIndexValues(Display*, const XRenderPictFormat*, c_int*);
extern(C) XRenderPictFormat* XRenderFindStandardFormat(Display*, c_int);
extern(C) XRenderPictFormat* XRenderFindFormat(Display*, c_ulong, const XRenderPictFormat*, c_int);
extern(C) XRenderPictFormat* XRenderFindVisualFormat(Display*, const Visual*);
extern(C) Bool XRenderSetSubpixelOrder(Display*, c_int, c_int);
extern(C) c_int XRenderQuerySubpixelOrder(Display*, c_int);
extern(C) Status XRenderQueryFormats(Display* dpy);
extern(C) Status XRenderQueryVersion(Display*, c_int*, c_int*);
extern(C) Bool XRenderQueryExtension(Display*, c_int*, c_int*);
} // version(DYNLINK)

