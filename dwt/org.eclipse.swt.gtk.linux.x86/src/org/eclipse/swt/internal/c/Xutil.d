/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.Xutil;

import java.lang.all;

public import org.eclipse.swt.internal.c.Xlib;
private import org.eclipse.swt.internal.c.X;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):

const c_int NoValue = 0x0000;
const c_int XValue = 0x0001;
const c_int YValue = 0x0002;
const c_int WidthValue = 0x0004;
const c_int HeightValue = 0x0008;
const c_int AllValues = 0x000F;
const c_int XNegative = 0x0010;
const c_int YNegative = 0x0020;
const c_int WithdrawnState = 0;
const c_int NormalState = 1;
const c_int IconicState = 3;
const c_int DontCareState = 0;
const c_int ZoomState = 2;
const c_int InactiveState = 4;
const c_int XNoMemory = -1;
const c_int XLocaleNotSupported = -2;
const c_int XConverterNotFound = -3;
const c_int RectangleOut = 0;
const c_int RectangleIn = 1;
const c_int RectanglePart = 2;
const c_int VisualNoMask = 0x0;
const c_int VisualIDMask = 0x1;
const c_int VisualScreenMask = 0x2;
const c_int VisualDepthMask = 0x4;
const c_int VisualClassMask = 0x8;
const c_int VisualRedMaskMask = 0x10;
const c_int VisualGreenMaskMask = 0x20;
const c_int VisualBlueMaskMask = 0x40;
const c_int VisualColormapSizeMask = 0x80;
const c_int VisualBitsPerRGBMask = 0x100;
const c_int VisualAllMask = 0x1FF;
const c_int BitmapSuccess = 0;
const c_int BitmapOpenFailed = 1;
const c_int BitmapFileInvalid = 2;
const c_int BitmapNoMemory = 3;
const c_int XCSUCCESS = 0;
const c_int XCNOMEM = 1;
const c_int XCNOENT = 2;
alias c_int XContext;
alias void * Region;
alias _XComposeStatus XComposeStatus;
enum XICCEncodingStyle {
XStringStyle=0,
XCompoundTextStyle=1,
XTextStyle=2,
XStdICCTextStyle=3,
XUTF8StringStyle=4,
}
alias void function(void *, char *, c_int, c_int, char * *) _BCD_func__1029;
alias c_int function(void *) _BCD_func__1071;
alias c_int function(void *, XErrorEvent *) _BCD_func__1072;
alias void function(void *, char *, char *) _BCD_func__1145;
alias c_int function(void *, char *, char *) _BCD_func__1146;
alias void function(void *, char *, char *) _BCD_func__1147;
struct XStandardColormap {
Colormap colormap;
c_ulong red_max;
c_ulong red_mult;
c_ulong green_max;
c_ulong green_mult;
c_ulong blue_max;
c_ulong blue_mult;
c_ulong base_pixel;
VisualID visualid;
XID killid;
}
struct XVisualInfo {
Visual * visual;
VisualID visualid;
c_int screen;
c_int depth;
c_int c_class;
c_ulong red_mask;
c_ulong green_mask;
c_ulong blue_mask;
c_int colormap_size;
c_int bits_per_rgb;
}
struct _XComposeStatus {
XPointer compose_ptr;
c_int chars_matched;
}
struct XClassHint {
char * res_name;
char * res_class;
}
struct XIconSize {
c_int min_width;
c_int min_height;
c_int max_width;
c_int max_height;
c_int width_inc;
c_int height_inc;
}
struct XTextProperty {
char * value;
Atom encoding;
c_int format;
c_ulong nitems;
}
struct XWMHints {
c_long flags;
Bool input;
c_int initial_state;
Pixmap icon_pixmap;
Window icon_window;
c_int icon_x;
c_int icon_y;
Pixmap icon_mask;
XID window_group;
}
struct N10XSizeHints4__94E {
c_int x;
c_int y;
}
struct XSizeHints {
c_long flags;
c_int x;
c_int y;
c_int width;
c_int height;
c_int min_width;
c_int min_height;
c_int max_width;
c_int max_height;
c_int width_inc;
c_int height_inc;
N10XSizeHints4__94E min_aspect;
N10XSizeHints4__94E max_aspect;
c_int base_width;
c_int base_height;
c_int win_gravity;
}
version(DYNLINK){
mixin(gshared!(
"extern(C) void function(Region, Region, Region) XXorRegion;
extern(C) c_int function(Display*, c_int, const char*, const char*, c_uint, XSizeHints*, c_int*, c_int*, c_int*, c_int*, c_int*) XWMGeometry;
extern(C) void function(Region, Region, Region) XUnionRegion;
extern(C) void function(XRectangle*, Region, Region) XUnionRectWithRegion;
extern(C) c_int function(Display*, XTextProperty*, char***, c_int*) Xutf8TextPropertyToTextList;
extern(C) c_int function(Display*, XTextProperty*, wchar***, c_int*) XwcTextPropertyToTextList;
extern(C) c_int function(Display*, XTextProperty*, char***, c_int*) XmbTextPropertyToTextList;
extern(C) Status function(XTextProperty*, char***, c_int*) XTextPropertyToStringList;
extern(C) void function(wchar**) XwcFreeStringList;
extern(C) c_int function(Display*, char**, c_int, XICCEncodingStyle, XTextProperty*) Xutf8TextListToTextProperty;
extern(C) c_int function(Display*, wchar**, c_int, XICCEncodingStyle, XTextProperty*) XwcTextListToTextProperty;
extern(C) c_int function(Display*, char**, c_int, XICCEncodingStyle, XTextProperty*) XmbTextListToTextProperty;
extern(C) void function(Region, Region, Region) XSubtractRegion;
extern(C) Status function(char**, c_int, XTextProperty*) XStringListToTextProperty;
extern(C) void function(Region, c_int, c_int) XShrinkRegion;
extern(C) void function(Display*, Window, XSizeHints*) XSetZoomHints;
extern(C) void function(Display*, Window, XStandardColormap*, Atom) XSetStandardColormap;
extern(C) void function(Display*, GC, Region) XSetRegion;
extern(C) void function(Display*, Window, XSizeHints*, Atom) XSetWMSizeHints;
extern(C) void function(Display*, Window, char*, char*, char**, c_int, XSizeHints*, XWMHints*, XClassHint*) Xutf8SetWMProperties;
extern(C) void function(Display*, Window, const char*, const char*, char**, c_int, XSizeHints*, XWMHints*, XClassHint*) XmbSetWMProperties;
extern(C) void function(Display*, Window, XTextProperty*, XTextProperty*, char**, c_int, XSizeHints*, XWMHints*, XClassHint*) XSetWMProperties;
extern(C) void function(Display*, Window, XSizeHints*) XSetWMNormalHints;
extern(C) void function(Display*, Window, XTextProperty*) XSetWMName;
extern(C) void function(Display*, Window, XTextProperty*) XSetWMIconName;
extern(C) void function(Display*, Window, XWMHints*) XSetWMHints;
extern(C) void function(Display*, Window, XTextProperty*) XSetWMClientMachine;
extern(C) void function(Display*, Window, XTextProperty*, Atom) XSetTextProperty;
extern(C) void function(Display*, Window, const char*, const char*, Pixmap, char**, c_int, XSizeHints*) XSetStandardProperties;
extern(C) void function(Display*, Window, XSizeHints*, Atom) XSetSizeHints;
extern(C) void function(Display*, Window, XStandardColormap*, c_int, Atom) XSetRGBColormaps;
extern(C) void function(Display*, Window, XSizeHints*) XSetNormalHints;
extern(C) void function(Display*, Window, XIconSize*, c_int) XSetIconSizes;
extern(C) void function(Display*, Window, XClassHint*) XSetClassHint;
extern(C) c_int function(Display*, XID, XContext, const char*) XSaveContext;
extern(C) c_int function(Region, c_int, c_int, c_uint, c_uint) XRectInRegion;
extern(C) Region function(XPoint*, c_int, c_int) XPolygonRegion;
extern(C) Bool function(Region, c_int, c_int) XPointInRegion;
extern(C) void function(Region, c_int, c_int) XOffsetRegion;
extern(C) Status function(Display*, c_int, c_int, c_int, XVisualInfo*) XMatchVisualInfo;
extern(C) c_int function(XKeyEvent*, char*, c_int, KeySym*, XComposeStatus*) XLookupString;
extern(C) void function(KeySym, KeySym*, KeySym*) XConvertCase;
extern(C) void function(Region, Region, Region) XIntersectRegion;
extern(C) Status function(Display*, Window, XSizeHints*) XGetZoomHints;
extern(C) Status function(Display*, Window, XSizeHints*, c_long*, Atom) XGetWMSizeHints;
extern(C) Status function(Display*, Window, XSizeHints*, c_long*) XGetWMNormalHints;
extern(C) Status function(Display*, Window, XTextProperty*) XGetWMName;
extern(C) Status function(Display*, Window, XTextProperty*) XGetWMIconName;
extern(C) XWMHints* function(Display*, Window) XGetWMHints;
extern(C) Status function(Display*, Window, XTextProperty*) XGetWMClientMachine;
extern(C) XVisualInfo* function(Display*, c_long, XVisualInfo*, c_int*) XGetVisualInfo;
extern(C) Status function(Display*, Window, XTextProperty*, Atom) XGetTextProperty;
extern(C) Status function(Display*, Window, XStandardColormap*, Atom) XGetStandardColormap;
extern(C) Status function(Display*, Window, XSizeHints*, Atom) XGetSizeHints;
extern(C) Status function(Display*, Window, XStandardColormap**, c_int*, Atom) XGetRGBColormaps;
extern(C) Status function(Display*, Window, XSizeHints*) XGetNormalHints;
extern(C) Status function(Display*, Window, XIconSize**, c_int*) XGetIconSizes;
extern(C) Status function(Display*, Window, XClassHint*) XGetClassHint;
extern(C) c_int function(Display*, XID, XContext, XPointer*) XFindContext;
extern(C) void function(Region, Region) XEqualRegion;
extern(C) void function(Region) XEmptyRegion;
extern(C) void function(Region) XDestroyRegion;
extern(C) c_int function(Display*, XID, XContext) XDeleteContext;
extern(C) char* function() XDefaultString;
extern(C) Region function() XCreateRegion;
extern(C) void function(Region, XRectangle*) XClipBox;
extern(C) XWMHints* function() XAllocWMHints;
extern(C) XStandardColormap* function() XAllocStandardColormap;
extern(C) XSizeHints* function() XAllocSizeHints;
extern(C) XIconSize* function() XAllocIconSize;
extern(C) XClassHint* function() XAllocClassHint;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("XXorRegion",  cast(void**)& XXorRegion),
        Symbol("XWMGeometry",  cast(void**)& XWMGeometry),
        Symbol("XUnionRegion",  cast(void**)& XUnionRegion),
        Symbol("XUnionRectWithRegion",  cast(void**)& XUnionRectWithRegion),
        Symbol("Xutf8TextPropertyToTextList",  cast(void**)& Xutf8TextPropertyToTextList),
        Symbol("XwcTextPropertyToTextList",  cast(void**)& XwcTextPropertyToTextList),
        Symbol("XmbTextPropertyToTextList",  cast(void**)& XmbTextPropertyToTextList),
        Symbol("XTextPropertyToStringList",  cast(void**)& XTextPropertyToStringList),
        Symbol("XwcFreeStringList",  cast(void**)& XwcFreeStringList),
        Symbol("Xutf8TextListToTextProperty",  cast(void**)& Xutf8TextListToTextProperty),
        Symbol("XwcTextListToTextProperty",  cast(void**)& XwcTextListToTextProperty),
        Symbol("XmbTextListToTextProperty",  cast(void**)& XmbTextListToTextProperty),
        Symbol("XSubtractRegion",  cast(void**)& XSubtractRegion),
        Symbol("XStringListToTextProperty",  cast(void**)& XStringListToTextProperty),
        Symbol("XShrinkRegion",  cast(void**)& XShrinkRegion),
        Symbol("XSetZoomHints",  cast(void**)& XSetZoomHints),
        Symbol("XSetStandardColormap",  cast(void**)& XSetStandardColormap),
        Symbol("XSetRegion",  cast(void**)& XSetRegion),
        Symbol("XSetWMSizeHints",  cast(void**)& XSetWMSizeHints),
        Symbol("Xutf8SetWMProperties",  cast(void**)& Xutf8SetWMProperties),
        Symbol("XmbSetWMProperties",  cast(void**)& XmbSetWMProperties),
        Symbol("XSetWMProperties",  cast(void**)& XSetWMProperties),
        Symbol("XSetWMNormalHints",  cast(void**)& XSetWMNormalHints),
        Symbol("XSetWMName",  cast(void**)& XSetWMName),
        Symbol("XSetWMIconName",  cast(void**)& XSetWMIconName),
        Symbol("XSetWMHints",  cast(void**)& XSetWMHints),
        Symbol("XSetWMClientMachine",  cast(void**)& XSetWMClientMachine),
        Symbol("XSetTextProperty",  cast(void**)& XSetTextProperty),
        Symbol("XSetStandardProperties",  cast(void**)& XSetStandardProperties),
        Symbol("XSetSizeHints",  cast(void**)& XSetSizeHints),
        Symbol("XSetRGBColormaps",  cast(void**)& XSetRGBColormaps),
        Symbol("XSetNormalHints",  cast(void**)& XSetNormalHints),
        Symbol("XSetIconSizes",  cast(void**)& XSetIconSizes),
        Symbol("XSetClassHint",  cast(void**)& XSetClassHint),
        Symbol("XSaveContext",  cast(void**)& XSaveContext),
        Symbol("XRectInRegion",  cast(void**)& XRectInRegion),
        Symbol("XPolygonRegion",  cast(void**)& XPolygonRegion),
        Symbol("XPointInRegion",  cast(void**)& XPointInRegion),
        Symbol("XOffsetRegion",  cast(void**)& XOffsetRegion),
        Symbol("XMatchVisualInfo",  cast(void**)& XMatchVisualInfo),
        Symbol("XLookupString",  cast(void**)& XLookupString),
        Symbol("XConvertCase",  cast(void**)& XConvertCase),
        Symbol("XIntersectRegion",  cast(void**)& XIntersectRegion),
        Symbol("XGetZoomHints",  cast(void**)& XGetZoomHints),
        Symbol("XGetWMSizeHints",  cast(void**)& XGetWMSizeHints),
        Symbol("XGetWMNormalHints",  cast(void**)& XGetWMNormalHints),
        Symbol("XGetWMName",  cast(void**)& XGetWMName),
        Symbol("XGetWMIconName",  cast(void**)& XGetWMIconName),
        Symbol("XGetWMHints",  cast(void**)& XGetWMHints),
        Symbol("XGetWMClientMachine",  cast(void**)& XGetWMClientMachine),
        Symbol("XGetVisualInfo",  cast(void**)& XGetVisualInfo),
        Symbol("XGetTextProperty",  cast(void**)& XGetTextProperty),
        Symbol("XGetStandardColormap",  cast(void**)& XGetStandardColormap),
        Symbol("XGetSizeHints",  cast(void**)& XGetSizeHints),
        Symbol("XGetRGBColormaps",  cast(void**)& XGetRGBColormaps),
        Symbol("XGetNormalHints",  cast(void**)& XGetNormalHints),
        Symbol("XGetIconSizes",  cast(void**)& XGetIconSizes),
        Symbol("XGetClassHint",  cast(void**)& XGetClassHint),
        Symbol("XFindContext",  cast(void**)& XFindContext),
        Symbol("XEqualRegion",  cast(void**)& XEqualRegion),
        Symbol("XEmptyRegion",  cast(void**)& XEmptyRegion),
        Symbol("XDestroyRegion",  cast(void**)& XDestroyRegion),
        Symbol("XDeleteContext",  cast(void**)& XDeleteContext),
        Symbol("XDefaultString",  cast(void**)& XDefaultString),
        Symbol("XCreateRegion",  cast(void**)& XCreateRegion),
        Symbol("XClipBox",  cast(void**)& XClipBox),
        Symbol("XAllocWMHints",  cast(void**)& XAllocWMHints),
        Symbol("XAllocStandardColormap",  cast(void**)& XAllocStandardColormap),
        Symbol("XAllocSizeHints",  cast(void**)& XAllocSizeHints),
        Symbol("XAllocIconSize",  cast(void**)& XAllocIconSize),
        Symbol("XAllocClassHint",  cast(void**)& XAllocClassHint)
    ];
}

} else { // version(DYNLINK)
extern(C) void XXorRegion(Region, Region, Region);
extern(C) c_int XWMGeometry(Display*, c_int, const char*, const char*, c_uint, XSizeHints*, c_int*, c_int*, c_int*, c_int*, c_int*);
extern(C) void XUnionRegion(Region, Region, Region);
extern(C) void XUnionRectWithRegion(XRectangle*, Region, Region);
extern(C) c_int Xutf8TextPropertyToTextList(Display*, XTextProperty*, char***, c_int*);
extern(C) c_int XwcTextPropertyToTextList(Display*, XTextProperty*, wchar***, c_int*);
extern(C) c_int XmbTextPropertyToTextList(Display*, XTextProperty*, char***, c_int*);
extern(C) Status XTextPropertyToStringList(XTextProperty*, char***, c_int*);
extern(C) void XwcFreeStringList(wchar**);
extern(C) c_int Xutf8TextListToTextProperty(Display*, char**, c_int, XICCEncodingStyle, XTextProperty*);
extern(C) c_int XwcTextListToTextProperty(Display*, wchar**, c_int, XICCEncodingStyle, XTextProperty*);
extern(C) c_int XmbTextListToTextProperty(Display*, char**, c_int, XICCEncodingStyle, XTextProperty*);
extern(C) void XSubtractRegion(Region, Region, Region);
extern(C) Status XStringListToTextProperty(char**, c_int, XTextProperty*);
extern(C) void XShrinkRegion(Region, c_int, c_int);
extern(C) void XSetZoomHints(Display*, Window, XSizeHints*);
extern(C) void XSetStandardColormap(Display*, Window, XStandardColormap*, Atom);
extern(C) void XSetRegion(Display*, GC, Region);
extern(C) void XSetWMSizeHints(Display*, Window, XSizeHints*, Atom);
extern(C) void Xutf8SetWMProperties(Display*, Window, char*, char*, char**, c_int, XSizeHints*, XWMHints*, XClassHint*);
extern(C) void XmbSetWMProperties(Display*, Window, const char*, const char*, char**, c_int, XSizeHints*, XWMHints*, XClassHint*);
extern(C) void XSetWMProperties(Display*, Window, XTextProperty*, XTextProperty*, char**, c_int, XSizeHints*, XWMHints*, XClassHint*);
extern(C) void XSetWMNormalHints(Display*, Window, XSizeHints*);
extern(C) void XSetWMName(Display*, Window, XTextProperty*);
extern(C) void XSetWMIconName(Display*, Window, XTextProperty*);
extern(C) void XSetWMHints(Display*, Window, XWMHints*);
extern(C) void XSetWMClientMachine(Display*, Window, XTextProperty*);
extern(C) void XSetTextProperty(Display*, Window, XTextProperty*, Atom);
extern(C) void XSetStandardProperties(Display*, Window, const char*, const char*, Pixmap, char**, c_int, XSizeHints*);
extern(C) void XSetSizeHints(Display*, Window, XSizeHints*, Atom);
extern(C) void XSetRGBColormaps(Display*, Window, XStandardColormap*, c_int, Atom);
extern(C) void XSetNormalHints(Display*, Window, XSizeHints*);
extern(C) void XSetIconSizes(Display*, Window, XIconSize*, c_int);
extern(C) void XSetClassHint(Display*, Window, XClassHint*);
extern(C) c_int XSaveContext(Display*, XID, XContext, const char*);
extern(C) c_int XRectInRegion(Region, c_int, c_int, c_uint, c_uint);
extern(C) Region XPolygonRegion(XPoint*, c_int, c_int);
extern(C) Bool XPointInRegion(Region, c_int, c_int);
extern(C) void XOffsetRegion(Region, c_int, c_int);
extern(C) Status XMatchVisualInfo(Display*, c_int, c_int, c_int, XVisualInfo*);
extern(C) c_int XLookupString(XKeyEvent*, char*, c_int, KeySym*, XComposeStatus*);
extern(C) void XConvertCase(KeySym, KeySym*, KeySym*);
extern(C) void XIntersectRegion(Region, Region, Region);
extern(C) Status XGetZoomHints(Display*, Window, XSizeHints*);
extern(C) Status XGetWMSizeHints(Display*, Window, XSizeHints*, c_long*, Atom);
extern(C) Status XGetWMNormalHints(Display*, Window, XSizeHints*, c_long*);
extern(C) Status XGetWMName(Display*, Window, XTextProperty*);
extern(C) Status XGetWMIconName(Display*, Window, XTextProperty*);
extern(C) XWMHints* XGetWMHints(Display*, Window);
extern(C) Status XGetWMClientMachine(Display*, Window, XTextProperty*);
extern(C) XVisualInfo* XGetVisualInfo(Display*, long, XVisualInfo*, c_int*);
extern(C) Status XGetTextProperty(Display*, Window, XTextProperty*, Atom);
extern(C) Status XGetStandardColormap(Display*, Window, XStandardColormap*, Atom);
extern(C) Status XGetSizeHints(Display*, Window, XSizeHints*, Atom);
extern(C) Status XGetRGBColormaps(Display*, Window, XStandardColormap**, c_int*, Atom);
extern(C) Status XGetNormalHints(Display*, Window, XSizeHints*);
extern(C) Status XGetIconSizes(Display*, Window, XIconSize**, c_int*);
extern(C) Status XGetClassHint(Display*, Window, XClassHint*);
extern(C) c_int XFindContext(Display*, XID, XContext, XPointer*);
extern(C) void XEqualRegion(Region, Region);
extern(C) void XEmptyRegion(Region);
extern(C) void XDestroyRegion(Region);
extern(C) c_int XDeleteContext(Display*, XID, XContext);
extern(C) char* XDefaultString();
extern(C) Region XCreateRegion();
extern(C) void XClipBox(Region, XRectangle*);
extern(C) XWMHints* XAllocWMHints();
extern(C) XStandardColormap* XAllocStandardColormap();
extern(C) XSizeHints* XAllocSizeHints();
extern(C) XIconSize* XAllocIconSize();
extern(C) XClassHint* XAllocClassHint();
} // version(DYNLINK)

