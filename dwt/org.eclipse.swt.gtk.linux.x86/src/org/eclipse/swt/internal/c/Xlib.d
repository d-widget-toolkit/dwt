/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.Xlib;

private import org.eclipse.swt.internal.c.X;

import java.lang.all;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):

const c_int XlibSpecificationRelease = 6;
const c_int X_HAVE_UTF8_STRING = 1;
const c_int True = 1;
const c_int False = 0;
const c_int QueuedAlready = 0;
const c_int QueuedAfterReading = 1;
const c_int QueuedAfterFlush = 2;
const String XNRequiredCharSet = "requiredCharSet";
const String XNQueryOrientation = "queryOrientation";
const String XNBaseFontName = "baseFontName";
const String XNOMAutomatic = "omAutomatic";
const String XNMissingCharSet = "missingCharSet";
const String XNDefaultString = "defaultString";
const String XNOrientation = "orientation";
const String XNDirectionalDependentDrawing = "directionalDependentDrawing";
const String XNContextualDrawing = "contextualDrawing";
const String XNFontInfo = "fontInfo";
const c_int XIMPreeditArea = 0x0001;
const c_int XIMPreeditCallbacks = 0x0002;
const c_int XIMPreeditPosition = 0x0004;
const c_int XIMPreeditNothing = 0x0008;
const c_int XIMPreeditNone = 0x0010;
const c_int XIMStatusArea = 0x0100;
const c_int XIMStatusCallbacks = 0x0200;
const c_int XIMStatusNothing = 0x0400;
const c_int XIMStatusNone = 0x0800;
const String XNVaNestedList = "XNVaNestedList";
const String XNQueryInputStyle = "queryInputStyle";
const String XNClientWindow = "clientWindow";
const String XNInputStyle = "inputStyle";
const String XNFocusWindow = "focusWindow";
const String XNResourceName = "resourceName";
const String XNResourceClass = "resourceClass";
const String XNGeometryCallback = "geometryCallback";
const String XNDestroyCallback = "destroyCallback";
const String XNFilterEvents = "filterEvents";
const String XNPreeditStartCallback = "preeditStartCallback";
const String XNPreeditDoneCallback = "preeditDoneCallback";
const String XNPreeditDrawCallback = "preeditDrawCallback";
const String XNPreeditCaretCallback = "preeditCaretCallback";
const String XNPreeditStateNotifyCallback = "preeditStateNotifyCallback";
const String XNPreeditAttributes = "preeditAttributes";
const String XNStatusStartCallback = "statusStartCallback";
const String XNStatusDoneCallback = "statusDoneCallback";
const String XNStatusDrawCallback = "statusDrawCallback";
const String XNStatusAttributes = "statusAttributes";
const String XNArea = "area";
const String XNAreaNeeded = "areaNeeded";
const String XNSpotLocation = "spotLocation";
const String XNColormap = "colorMap";
const String XNStdColormap = "stdColorMap";
const String XNForeground = "foreground";
const String XNBackground = "background";
const String XNBackgroundPixmap = "backgroundPixmap";
const String XNFontSet = "fontSet";
const String XNLineSpace = "lineSpace";
const String XNCursor = "cursor";
const String XNQueryIMValuesList = "queryIMValuesList";
const String XNQueryICValuesList = "queryICValuesList";
const String XNVisiblePosition = "visiblePosition";
const String XNR6PreeditCallback = "r6PreeditCallback";
const String XNStringConversionCallback = "stringConversionCallback";
const String XNStringConversion = "stringConversion";
const String XNResetState = "resetState";
const String XNHotKey = "hotKey";
const String XNHotKeyState = "hotKeyState";
const String XNPreeditState = "preeditState";
const String XNSeparatorofNestedList = "separatorofNestedList";
const c_int XBufferOverflow = -1;
const c_int XLookupNone = 1;
const c_int XLookupChars = 2;
const c_int XLookupKeySym = 3;
const c_int XLookupBoth = 4;
const c_int XIMReverse = 1;
const c_int XIMPreeditUnKnown = 0;
const c_int XIMPreeditEnable = 1;
const c_int XIMInitialState = 1;
alias void _XDisplay;
alias _XDisplay Display;
alias char * XPointer;
alias void function(Display *, XPointer, c_int, Bool, XPointer *) _BCD_func__846;
alias _BCD_func__846 XConnectionWatchProc;
alias c_int function(Display *) _BCD_func__894;
alias _BCD_func__894 XIOErrorHandler;
alias c_int function(Display *, XErrorEvent *) _BCD_func__895;
alias _BCD_func__895 XErrorHandler;
alias c_ulong XIMHotKeyState;
alias _XIMHotKeyTriggers XIMHotKeyTriggers;
alias _XIMHotKeyTrigger XIMHotKeyTrigger;
alias _XIMStatusDrawCallbackStruct XIMStatusDrawCallbackStruct;
alias _XIMText XIMText;
enum XIMStatusDataType {
XIMTextType=0,
XIMBitmapType=1,
}
alias _XIMPreeditCaretCallbackStruct XIMPreeditCaretCallbackStruct;
enum XIMCaretDirection {
XIMForwardChar=0,
XIMBackwardChar=1,
XIMForwardWord=2,
XIMBackwardWord=3,
XIMCaretUp=4,
XIMCaretDown=5,
XIMNextLine=6,
XIMPreviousLine=7,
XIMLineStart=8,
XIMLineEnd=9,
XIMAbsolutePosition=10,
XIMDontChange=11,
}
enum XIMCaretStyle {
XIMIsInvisible=0,
XIMIsPrimary=1,
XIMIsSecondary=2,
}
alias _XIMPreeditDrawCallbackStruct XIMPreeditDrawCallbackStruct;
alias _XIMStringConversionCallbackStruct XIMStringConversionCallbackStruct;
alias ushort XIMStringConversionPosition;
alias ushort XIMStringConversionOperation;
alias _XIMStringConversionText XIMStringConversionText;
alias ushort XIMStringConversionType;
alias c_ulong XIMStringConversionFeedback;
alias c_ulong XIMResetState;
alias _XIMPreeditStateNotifyCallbackStruct XIMPreeditStateNotifyCallbackStruct;
alias c_ulong XIMPreeditState;
alias c_ulong XIMFeedback;
alias c_int function(XIC, XPointer, XPointer) _BCD_func__970;
alias _BCD_func__970 XICProc;
alias void function(XIC, XPointer, XPointer) _BCD_func__971;
alias _BCD_func__971 XIMProc;
alias void * XVaNestedList;
alias c_ulong XIMStyle;
alias void function(Display *, XPointer, XPointer) _BCD_func__969;
alias _BCD_func__969 XIDProc;
alias void * XIC;
alias void * XIM;
enum XOrientation {
XOMOrientation_LTR_TTB=0,
XOMOrientation_RTL_TTB=1,
XOMOrientation_TTB_LTR=2,
XOMOrientation_TTB_RTL=3,
XOMOrientation_Context=4,
}
alias void * XFontSet;
alias void * XOC;
alias void * XOM;
alias void * GC;
alias _XExtData XExtData;
alias _XEvent XEvent;
alias XFocusChangeEvent XFocusOutEvent;
alias XFocusChangeEvent XFocusInEvent;
alias XCrossingEvent XLeaveWindowEvent;
alias XCrossingEvent XEnterWindowEvent;
alias XMotionEvent XPointerMovedEvent;
alias XButtonEvent XButtonReleasedEvent;
alias XButtonEvent XButtonPressedEvent;
alias XKeyEvent XKeyReleasedEvent;
alias XKeyEvent XKeyPressedEvent;
alias void _XrmHashBucketRec;
alias c_uint function(void *) _BCD_func__2044;
alias c_int function(void *) _BCD_func__2045;
alias _XImage XImage;
alias _XImage * function(_XDisplay *, Visual *, c_uint, c_int, c_int, char *, c_uint, c_uint, c_int, c_int) _BCD_func__2099;
alias c_int function(_XImage *) _BCD_func__2100;
alias c_ulong function(_XImage *, c_int, c_int) _BCD_func__2101;
alias c_int function(_XImage *, c_int, c_int, _BCD_func__2101) _BCD_func__2102;
alias _XImage * function(_XImage *, c_int, c_int, c_uint, c_uint) _BCD_func__2103;
alias c_int function(_XImage *, c_long) _BCD_func__2104;
alias c_int function(_XExtData *) _BCD_func__2075;
alias Bool function(Display *, _XEvent *, XPointer) _BCD_func__1795;
struct XIMValuesList {
ushort count_values;
char * * supported_values;
}
struct _XIMHotKeyTriggers {
c_int num_hot_key;
_XIMHotKeyTrigger * key;
}
struct _XIMHotKeyTrigger {
KeySym keysym;
c_int modifier;
c_int modifier_mask;
}
union N28_XIMStatusDrawCallbackStruct4__91E {
_XIMText * text;
Pixmap bitmap;
}
struct _XIMStatusDrawCallbackStruct {
XIMStatusDataType type;
N28_XIMStatusDrawCallbackStruct4__91E data;
}
struct _XIMPreeditCaretCallbackStruct {
c_int position;
XIMCaretDirection direction;
XIMCaretStyle style;
}
struct _XIMPreeditDrawCallbackStruct {
c_int caret;
c_int chg_first;
c_int chg_length;
_XIMText * text;
}
struct _XIMStringConversionCallbackStruct {
XIMStringConversionPosition position;
XIMCaretDirection direction;
XIMStringConversionOperation operation;
ushort factor;
_XIMStringConversionText * text;
}
union N24_XIMStringConversionText4__87E {
char * mbs;
wchar * wcs;
}
struct _XIMStringConversionText {
ushort length;
XIMStringConversionFeedback * feedback;
Bool encoding_is_wchar;
N24_XIMStringConversionText4__87E string;
}
struct _XIMPreeditStateNotifyCallbackStruct {
XIMPreeditState state;
}
union N8_XIMText4__86E {
char * multi_byte;
wchar * wide_char;
}
struct _XIMText {
ushort length;
XIMFeedback * feedback;
Bool encoding_is_wchar;
N8_XIMText4__86E string;
}
struct XICCallback {
XPointer client_data;
XICProc callback;
}
struct XIMCallback {
XPointer client_data;
XIMProc callback;
}
struct XIMStyles {
ushort count_styles;
XIMStyle * supported_styles;
}
struct XOMFontInfo {
c_int num_font;
XFontStruct * * font_struct_list;
char * * font_name_list;
}
struct XOMOrientation {
c_int num_orientation;
XOrientation * orientation;
}
struct XOMCharSetList {
c_int charset_count;
char * * charset_list;
}
struct XwcTextItem {
wchar * chars;
c_int nchars;
c_int delta;
XFontSet font_set;
}
struct XmbTextItem {
char * chars;
c_int nchars;
c_int delta;
XFontSet font_set;
}
struct XFontSetExtents {
XRectangle max_ink_extent;
XRectangle max_logical_extent;
}
union XEDataObject {
Display * display;
GC gc;
Visual * visual;
Screen * screen;
ScreenFormat * pixmap_format;
XFontStruct * font;
}
struct XTextItem16 {
XChar2b * chars;
c_int nchars;
c_int delta;
Font font;
}
struct XChar2b {
char byte1;
char byte2;
}
struct XTextItem {
char * chars;
c_int nchars;
c_int delta;
Font font;
}
struct XFontStruct {
_XExtData * ext_data;
Font fid;
c_uint direction;
c_uint min_char_or_byte2;
c_uint max_char_or_byte2;
c_uint min_byte1;
c_uint max_byte1;
Bool all_chars_exist;
c_uint default_char;
c_int n_properties;
XFontProp * properties;
XCharStruct min_bounds;
XCharStruct max_bounds;
XCharStruct * per_char;
c_int ascent;
c_int descent;
}
struct XFontProp {
Atom name;
c_ulong card32;
}
struct XCharStruct {
short lbearing;
short rbearing;
short width;
short ascent;
short descent;
ushort attributes;
}
union _XEvent {
c_int type;
XAnyEvent xany;
XKeyEvent xkey;
XButtonEvent xbutton;
XMotionEvent xmotion;
XCrossingEvent xcrossing;
XFocusChangeEvent xfocus;
XExposeEvent xexpose;
XGraphicsExposeEvent xgraphicsexpose;
XNoExposeEvent xnoexpose;
XVisibilityEvent xvisibility;
XCreateWindowEvent xcreatewindow;
XDestroyWindowEvent xdestroywindow;
XUnmapEvent xunmap;
XMapEvent xmap;
XMapRequestEvent xmaprequest;
XReparentEvent xreparent;
XConfigureEvent xconfigure;
XGravityEvent xgravity;
XResizeRequestEvent xresizerequest;
XConfigureRequestEvent xconfigurerequest;
XCirculateEvent xcirculate;
XCirculateRequestEvent xcirculaterequest;
XPropertyEvent xproperty;
XSelectionClearEvent xselectionclear;
XSelectionRequestEvent xselectionrequest;
XSelectionEvent xselection;
XColormapEvent xcolormap;
XClientMessageEvent xclient;
XMappingEvent xmapping;
XErrorEvent xerror;
XKeymapEvent xkeymap;
c_long [24] pad;
}
struct XAnyEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
}
struct XErrorEvent {
c_int type;
Display * display;
XID resourceid;
c_ulong serial;
char error_code;
char request_code;
char minor_code;
}
struct XMappingEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
c_int request;
c_int first_keycode;
c_int count;
}
union N19XClientMessageEvent4__65E {
char [20] b;
short [10] s;
c_long [5] l;
}
struct XClientMessageEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
Atom message_type;
c_int format;
N19XClientMessageEvent4__65E data;
}
struct XColormapEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
Colormap colormap;
Bool c_new;
c_int state;
}
struct XSelectionEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window requestor;
Atom selection;
Atom target;
Atom property;
Time time;
}
struct XSelectionRequestEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window owner;
Window requestor;
Atom selection;
Atom target;
Atom property;
Time time;
}
struct XSelectionClearEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
Atom selection;
Time time;
}
struct XPropertyEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
Atom atom;
Time time;
c_int state;
}
struct XCirculateRequestEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window parent;
Window window;
c_int place;
}
struct XCirculateEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window event;
Window window;
c_int place;
}
struct XConfigureRequestEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window parent;
Window window;
c_int x;
c_int y;
c_int width;
c_int height;
c_int border_width;
Window above;
c_int detail;
c_ulong value_mask;
}
struct XResizeRequestEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
c_int width;
c_int height;
}
struct XGravityEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window event;
Window window;
c_int x;
c_int y;
}
struct XConfigureEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window event;
Window window;
c_int x;
c_int y;
c_int width;
c_int height;
c_int border_width;
Window above;
Bool override_redirect;
}
struct XReparentEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window event;
Window window;
Window parent;
c_int x;
c_int y;
Bool override_redirect;
}
struct XMapRequestEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window parent;
Window window;
}
struct XMapEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window event;
Window window;
Bool override_redirect;
}
struct XUnmapEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window event;
Window window;
Bool from_configure;
}
struct XDestroyWindowEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window event;
Window window;
}
struct XCreateWindowEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window parent;
Window window;
c_int x;
c_int y;
c_int width;
c_int height;
c_int border_width;
Bool override_redirect;
}
struct XVisibilityEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
c_int state;
}
struct XNoExposeEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Drawable drawable;
c_int major_code;
c_int minor_code;
}
struct XGraphicsExposeEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Drawable drawable;
c_int x;
c_int y;
c_int width;
c_int height;
c_int count;
c_int major_code;
c_int minor_code;
}
struct XExposeEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
c_int x;
c_int y;
c_int width;
c_int height;
c_int count;
}
struct XKeymapEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
char [32] key_vector;
}
struct XFocusChangeEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
c_int mode;
c_int detail;
}
struct XCrossingEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
Window root;
Window subwindow;
Time time;
c_int x;
c_int y;
c_int x_root;
c_int y_root;
c_int mode;
c_int detail;
Bool same_screen;
Bool focus;
c_uint state;
}
struct XMotionEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
Window root;
Window subwindow;
Time time;
c_int x;
c_int y;
c_int x_root;
c_int y_root;
c_uint state;
char is_hint;
Bool same_screen;
}
struct XButtonEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
Window root;
Window subwindow;
Time time;
c_int x;
c_int y;
c_int x_root;
c_int y_root;
c_uint state;
c_uint button;
Bool same_screen;
}
struct XKeyEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
Window root;
Window subwindow;
Time time;
c_int x;
c_int y;
c_int x_root;
c_int y_root;
c_uint state;
c_uint keycode;
Bool same_screen;
}
struct XModifierKeymap {
c_int max_keypermod;
KeyCode * modifiermap;
}
struct XTimeCoord {
Time time;
short x;
short y;
}
struct XKeyboardState {
c_int key_click_percent;
c_int bell_percent;
c_uint bell_pitch;
c_uint bell_duration;
c_ulong led_mask;
c_int global_auto_repeat;
char [32] auto_repeats;
}
struct XKeyboardControl {
c_int key_click_percent;
c_int bell_percent;
c_int bell_pitch;
c_int bell_duration;
c_int led;
c_int led_mode;
c_int key;
c_int auto_repeat_mode;
}
struct XArc {
short x;
short y;
ushort width;
ushort height;
short angle1;
short angle2;
}
struct XRectangle {
short x;
short y;
ushort width;
ushort height;
}
struct XPoint {
short x;
short y;
}
struct XSegment {
short x1;
short y1;
short x2;
short y2;
}
struct XColor {
c_ulong pixel;
ushort red;
ushort green;
ushort blue;
char flags;
char pad;
}
struct XWindowChanges {
c_int x;
c_int y;
c_int width;
c_int height;
c_int border_width;
Window sibling;
c_int stack_mode;
}
struct funcs {
_BCD_func__2099 create_image;
_BCD_func__2100 destroy_image;
_BCD_func__2101 get_pixel;
_BCD_func__2102 put_pixel;
_BCD_func__2103 sub_image;
_BCD_func__2104 add_pixel;
}
struct _XImage {
c_int width;
c_int height;
c_int xoffset;
c_int format;
char * data;
c_int byte_order;
c_int bitmap_unit;
c_int bitmap_bit_order;
c_int bitmap_pad;
c_int depth;
c_int bytes_per_line;
c_int bits_per_pixel;
c_ulong red_mask;
c_ulong green_mask;
c_ulong blue_mask;
XPointer obdata;
funcs f;
}
struct XServerInterpretedAddress {
c_int typelength;
c_int valuelength;
char * type;
char * value;
}
struct XHostAddress {
c_int family;
c_int length;
char * address;
}
struct XWindowAttributes {
c_int x;
c_int y;
c_int width;
c_int height;
c_int border_width;
c_int depth;
Visual * visual;
Window root;
c_int c_class;
c_int bit_gravity;
c_int win_gravity;
c_int backing_store;
c_ulong backing_planes;
c_ulong backing_pixel;
Bool save_under;
Colormap colormap;
Bool map_installed;
c_int map_state;
c_long all_event_masks;
c_long your_event_mask;
c_long do_not_propagate_mask;
Bool override_redirect;
Screen * screen;
}
struct XSetWindowAttributes {
Pixmap background_pixmap;
c_ulong background_pixel;
Pixmap border_pixmap;
c_ulong border_pixel;
c_int bit_gravity;
c_int win_gravity;
c_int backing_store;
c_ulong backing_planes;
c_ulong backing_pixel;
Bool save_under;
c_long event_mask;
c_long do_not_propagate_mask;
Bool override_redirect;
Colormap colormap;
Cursor cursor;
}
struct ScreenFormat {
_XExtData * ext_data;
c_int depth;
c_int bits_per_pixel;
c_int scanline_pad;
}
struct Screen {
_XExtData * ext_data;
_XDisplay * display;
Window root;
c_int width;
c_int height;
c_int mwidth;
c_int mheight;
c_int ndepths;
Depth * depths;
c_int root_depth;
Visual * root_visual;
GC default_gc;
Colormap cmap;
c_ulong white_pixel;
c_ulong black_pixel;
c_int max_maps;
c_int min_maps;
c_int backing_store;
Bool save_unders;
c_long root_input_mask;
}
struct Depth {
c_int depth;
c_int nvisuals;
Visual * visuals;
}
struct Visual {
_XExtData * ext_data;
VisualID visualid;
c_int c_class;
c_ulong red_mask;
c_ulong green_mask;
c_ulong blue_mask;
c_int bits_per_rgb;
c_int map_entries;
}
struct XGCValues {
c_int function_;
c_ulong plane_mask;
c_ulong foreground;
c_ulong background;
c_int line_width;
c_int line_style;
c_int cap_style;
c_int join_style;
c_int fill_style;
c_int fill_rule;
c_int arc_mode;
Pixmap tile;
Pixmap stipple;
c_int ts_x_origin;
c_int ts_y_origin;
Font font;
c_int subwindow_mode;
Bool graphics_exposures;
c_int clip_x_origin;
c_int clip_y_origin;
Pixmap clip_mask;
c_int dash_offset;
char dashes;
}
struct XPixmapFormatValues {
c_int depth;
c_int bits_per_pixel;
c_int scanline_pad;
}
struct XExtCodes {
c_int extension;
c_int major_opcode;
c_int first_event;
c_int first_error;
}
struct _XExtData {
c_int number;
_XExtData * next;
_BCD_func__2075 free_private;
XPointer private_data;
}
// TODO 64-bit
version(DYNLINK){
mixin(gshared!(
"extern(C) c_int function(char*, wchar) _Xwctomb;
extern(C) c_int function(wchar*, char*, c_int) _Xmbtowc;
extern(C) void function(char*, c_int, char*, c_int) XSetAuthorization;
extern(C) void function(Display*, XConnectionWatchProc, XPointer) XRemoveConnectionWatch;
extern(C) Status function(Display*, XConnectionWatchProc, XPointer) XAddConnectionWatch;
extern(C) void function(Display*, c_int) XProcessInternalConnection;
extern(C) Status function(Display*, c_int**, c_int*) XInternalConnectionNumbers;
extern(C) Bool function(Display*, _XrmHashBucketRec*, char*, char*, XIDProc, XPointer) XUnregisterIMInstantiateCallback;
extern(C) Bool function(Display*, _XrmHashBucketRec*, char*, char*, XIDProc, XPointer) XRegisterIMInstantiateCallback;
extern(C) XVaNestedList function(c_int, ...) XVaCreateNestedList;
extern(C) c_int function(XIC, XKeyPressedEvent*, char*, c_int, KeySym*, Status*) Xutf8LookupString;
extern(C) c_int function(XIC, XKeyPressedEvent*, wchar*, c_int, KeySym*, Status*) XwcLookupString;
extern(C) c_int function(XIC, XKeyPressedEvent*, char*, c_int, KeySym*, Status*) XmbLookupString;
extern(C) Bool function(XEvent*, Window) XFilterEvent;
extern(C) XIM function(XIC) XIMOfIC;
extern(C) char* function(XIC, ...) XGetICValues;
extern(C) char* function(XIC, ...) XSetICValues;
extern(C) char* function(XIC) Xutf8ResetIC;
extern(C) char* function(XIC) XmbResetIC;
extern(C) wchar* function(XIC) XwcResetIC;
extern(C) void function(XIC) XUnsetICFocus;
extern(C) void function(XIC) XSetICFocus;
extern(C) void function(XIC) XDestroyIC;
extern(C) XIC function(XIM, ...) XCreateIC;
extern(C) char* function(XIM) XLocaleOfIM;
extern(C) Display* function(XIM) XDisplayOfIM;
extern(C) char* function(XIM, ...) XSetIMValues;
extern(C) char* function(XIM, ...) XGetIMValues;
extern(C) Status function(XIM) XCloseIM;
extern(C) XIM function(Display*, _XrmHashBucketRec*, char*, char*) XOpenIM;
extern(C) void function(Display*, Drawable, XFontSet, GC, c_int, c_int, const char*, c_int) Xutf8DrawImageString;
extern(C) void function(Display*, Drawable, XFontSet, GC, c_int, c_int, const wchar*, c_int) XwcDrawImageString;
extern(C) void function(Display*, Drawable, XFontSet, GC, c_int, c_int, const char*, c_int) XmbDrawImageString;
extern(C) void function(Display*, Drawable, XFontSet, GC, c_int, c_int, const char*, c_int) Xutf8DrawString;
extern(C) void function(Display*, Drawable, XFontSet, GC, c_int, c_int, const wchar*, c_int) XwcDrawString;
extern(C) void function(Display*, Drawable, XFontSet, GC, c_int, c_int, const char*, c_int) XmbDrawString;
extern(C) void function(Display*, Drawable, GC, c_int, c_int, XmbTextItem*, c_int) Xutf8DrawText;
extern(C) void function(Display*, Drawable, GC, c_int, c_int, XwcTextItem*, c_int) XwcDrawText;
extern(C) void function(Display*, Drawable, GC, c_int, c_int, XmbTextItem*, c_int) XmbDrawText;
extern(C) Status function(XFontSet, const char*, c_int, XRectangle*, XRectangle*, c_int, c_int*, XRectangle*, XRectangle*) Xutf8TextPerCharExtents;
extern(C) Status function(XFontSet, const wchar*, c_int, XRectangle*, XRectangle*, c_int, c_int*, XRectangle*, XRectangle*) XwcTextPerCharExtents;
extern(C) Status function(XFontSet, const char*, c_int, XRectangle*, XRectangle*, c_int, c_int*, XRectangle*, XRectangle*) XmbTextPerCharExtents;
extern(C) c_int function(XFontSet, const char*, c_int, XRectangle*, XRectangle*) Xutf8TextExtents;
extern(C) c_int function(XFontSet, const wchar*, c_int, XRectangle*, XRectangle*) XwcTextExtents;
extern(C) c_int function(XFontSet, const char*, c_int, XRectangle*, XRectangle*) XmbTextExtents;
extern(C) c_int function(XFontSet, const char*, c_int) Xutf8TextEscapement;
extern(C) c_int function(XFontSet, const wchar*, c_int) XwcTextEscapement;
extern(C) c_int function(XFontSet, const char*, c_int) XmbTextEscapement;
extern(C) XFontSetExtents* function(XFontSet) XExtentsOfFontSet;
extern(C) Bool function(XFontSet) XContextualDrawing;
extern(C) Bool function(XFontSet) XDirectionalDependentDrawing;
extern(C) Bool function(XFontSet) XContextDependentDrawing;
extern(C) char* function(XFontSet) XLocaleOfFontSet;
extern(C) char* function(XFontSet) XBaseFontNameListOfFontSet;
extern(C) c_int function(XFontSet, XFontStruct***, char***) XFontsOfFontSet;
extern(C) void function(Display*, XFontSet) XFreeFontSet;
extern(C) XFontSet function(Display*, const char*, char***, c_int*, char**) XCreateFontSet;
extern(C) char* function(XOC, ...) XGetOCValues;
extern(C) char* function(XOC, ...) XSetOCValues;
extern(C) XOM function(XOC) XOMOfOC;
extern(C) void function(XOC) XDestroyOC;
extern(C) XOC function(XOM, ...) XCreateOC;
extern(C) char* function(XOM) XLocaleOfOM;
extern(C) Display* function(XOM) XDisplayOfOM;
extern(C) char* function(XOM, ...) XGetOMValues;
extern(C) char* function(XOM, ...) XSetOMValues;
extern(C) Status function(XOM) XCloseOM;
extern(C) XOM function(Display*, _XrmHashBucketRec*, const char*, const char*) XOpenOM;
extern(C) char* function(const char*) XSetLocaleModifiers;
extern(C) Bool XSupportsLocale();
extern(C) c_int function(Display*, const char*, Pixmap, c_uint, c_uint, c_int, c_int) XWriteBitmapFile;
extern(C) c_int function(Display*, Window, c_long, XEvent*) XWindowEvent;
extern(C) c_int function(Screen*) XWidthOfScreen;
extern(C) c_int function(Screen*) XWidthMMOfScreen;
extern(C) c_int function(Display*, Window, Window, c_int, c_int, c_uint, c_uint, c_int, c_int) XWarpPointer;
extern(C) c_int function(Display*) XVendorRelease;
extern(C) c_int function(Display*, Window) XUnmapWindow;
extern(C) c_int function(Display*, Window) XUnmapSubwindows;
extern(C) c_int function(Display*, Font) XUnloadFont;
extern(C) c_int function(Display*, Colormap) XUninstallColormap;
extern(C) c_int function(Display*) XUngrabServer;
extern(C) c_int function(Display*, Time) XUngrabPointer;
extern(C) c_int function(Display*, Time) XUngrabKeyboard;
extern(C) c_int function(Display*, c_int, c_uint, Window) XUngrabKey;
extern(C) c_int function(Display*, c_uint, c_uint, Window) XUngrabButton;
extern(C) c_int function(Display*, Window) XUndefineCursor;
extern(C) Bool function(Display*, Window, Window, c_int, c_int, c_int*, c_int*, Window*) XTranslateCoordinates;
extern(C) c_int function(XFontStruct*, const XChar2b*, c_int) XTextWidth16;
extern(C) c_int function(XFontStruct*, const char*, c_int) XTextWidth;
extern(C) c_int function(XFontStruct*, const XChar2b*, c_int, c_int*, c_int*, c_int*, XCharStruct*) XTextExtents16;
extern(C) c_int function(XFontStruct*, const char*, c_int, c_int*, c_int*, c_int*, XCharStruct*) XTextExtents;
extern(C) c_int function(Display*, Bool) XSync;
extern(C) c_int function(Display*, Colormap, const char*, c_ulong, c_int) XStoreNamedColor;
extern(C) c_int function(Display*, Window, const char*) XStoreName;
extern(C) c_int function(Display*, Colormap, XColor*, c_int) XStoreColors;
extern(C) c_int function(Display*, Colormap, XColor*) XStoreColor;
extern(C) c_int function(Display*, const char*, c_int) XStoreBytes;
extern(C) c_int function(Display*, const char*, c_int, c_int) XStoreBuffer;
extern(C) c_int function(Display*, Window, Colormap) XSetWindowColormap;
extern(C) c_int function(Display*, Window, c_uint) XSetWindowBorderWidth;
extern(C) c_int function(Display*, Window, Pixmap) XSetWindowBorderPixmap;
extern(C) c_int function(Display*, Window, c_ulong) XSetWindowBorder;
extern(C) c_int function(Display*, Window, Pixmap) XSetWindowBackgroundPixmap;
extern(C) c_int function(Display*, Window, c_ulong) XSetWindowBackground;
extern(C) c_int function(Display*, GC, Pixmap) XSetTile;
extern(C) c_int function(Display*, GC, c_int, c_int) XSetTSOrigin;
extern(C) c_int function(Display*, GC, c_int) XSetSubwindowMode;
extern(C) c_int function(Display*, GC, Pixmap) XSetStipple;
extern(C) c_int function(Display*, GC, c_ulong, c_ulong, c_int, c_ulong) XSetState;
extern(C) c_int function(Display*, Atom, Window, Time) XSetSelectionOwner;
extern(C) c_int function(Display*, c_int, c_int, c_int, c_int) XSetScreenSaver;
extern(C) c_int function(Display*, const char*, c_int) XSetPointerMapping;
extern(C) c_int function(Display*, GC, c_ulong) XSetPlaneMask;
extern(C) c_int function(Display*, XModifierKeymap*) XSetModifierMapping;
extern(C) c_int function(Display*, GC, c_uint, c_int, c_int, c_int) XSetLineAttributes;
extern(C) c_int function(Display*, Window, c_int, Time) XSetInputFocus;
extern(C) c_int function(Display*, Window, const char*) XSetIconName;
extern(C) c_int function(Display*, GC, Bool) XSetGraphicsExposures;
extern(C) c_int function(Display*, GC, c_int) XSetFunction;
extern(C) c_int function(Display*, GC, c_ulong) XSetForeground;
extern(C) c_int function(Display*, char**, c_int) XSetFontPath;
extern(C) c_int function(Display*, GC, Font) XSetFont;
extern(C) c_int function(Display*, GC, c_int) XSetFillStyle;
extern(C) c_int function(Display*, GC, c_int) XSetFillRule;
extern(C) c_int function(Display*, GC, c_int, const char*, c_int) XSetDashes;
extern(C) c_int function(Display*, Window, char**, c_int) XSetCommand;
extern(C) c_int function(Display*, c_int) XSetCloseDownMode;
extern(C) c_int function(Display*, GC, c_int, c_int, XRectangle*, c_int, c_int) XSetClipRectangles;
extern(C) c_int function(Display*, GC, c_int, c_int) XSetClipOrigin;
extern(C) c_int function(Display*, GC, Pixmap) XSetClipMask;
extern(C) c_int function(Display*, GC, c_ulong) XSetBackground;
extern(C) c_int function(Display*, GC, c_int) XSetArcMode;
extern(C) c_int function(Display*, c_int) XSetAccessControl;
extern(C) Status function(Display*, Window, Bool, c_long, XEvent*) XSendEvent;
extern(C) c_int function(Display*, Window, c_long) XSelectInput;
extern(C) c_int function(Display*) XScreenCount;
extern(C) c_int function(Display*, Window, Atom*, c_int, c_int) XRotateWindowProperties;
extern(C) c_int function(Display*, c_int) XRotateBuffers;
extern(C) c_int function(Display*, Window*, c_int) XRestackWindows;
extern(C) c_int function(Display*, Window, c_uint, c_uint) XResizeWindow;
extern(C) c_int function(Display*) XResetScreenSaver;
extern(C) c_int function(Display*, Window, Window, c_int, c_int) XReparentWindow;
extern(C) c_int function(Display*, XHostAddress*, c_int) XRemoveHosts;
extern(C) c_int function(Display*, XHostAddress*) XRemoveHost;
extern(C) c_int function(Display*, Window) XRemoveFromSaveSet;
extern(C) c_int function(XMappingEvent*) XRefreshKeyboardMapping;
extern(C) c_int function(Display*, Cursor, XColor*, XColor*) XRecolorCursor;
extern(C) c_int function(Display*, KeySym, KeySym*, c_int, const char*, c_int) XRebindKeysym;
extern(C) c_int function(const char*, c_uint*, c_uint*, char**, c_int*, c_int*) XReadBitmapFileData;
extern(C) c_int function(Display*, Drawable, const char*, c_uint*, c_uint*, Pixmap*, c_int*, c_int*) XReadBitmapFile;
extern(C) c_int function(Display*, Window) XRaiseWindow;
extern(C) Status function(Display*, Window, Window*, Window*, Window**, c_uint*) XQueryTree;
extern(C) c_int function(Display*, XID, const XChar2b*, c_int, c_int*, c_int*, c_int*, XCharStruct*) XQueryTextExtents16;
extern(C) c_int function(Display*, XID, const char*, c_int, c_int*, c_int*, c_int*, XCharStruct*) XQueryTextExtents;
extern(C) Bool function(Display*, Window, Window*, Window*, c_int*, c_int*, c_int*, c_int*, c_uint*) XQueryPointer;
extern(C) c_int function(Display*, char [32]) XQueryKeymap;
extern(C) Bool function(Display*, const char*, c_int*, c_int*, c_int*) XQueryExtension;
extern(C) c_int function(Display*, Colormap, XColor*, c_int) XQueryColors;
extern(C) c_int function(Display*, Colormap, XColor*) XQueryColor;
extern(C) Status function(Display*, Drawable, c_uint, c_uint, c_uint*, c_uint*) XQueryBestTile;
extern(C) Status function(Display*, Drawable, c_uint, c_uint, c_uint*, c_uint*) XQueryBestStipple;
extern(C) Status function(Display*, c_int, Drawable, c_uint, c_uint, c_uint*, c_uint*) XQueryBestSize;
extern(C) Status function(Display*, Drawable, c_uint, c_uint, c_uint*, c_uint*) XQueryBestCursor;
extern(C) c_int function(Display*) XQLength;
extern(C) c_int function(Display*, Drawable, GC, XImage*, c_int, c_int, c_int, c_int, c_uint, c_uint) XPutImage;
extern(C) c_int function(Display*, XEvent*) XPutBackEvent;
extern(C) c_int function(Display*) XProtocolVersion;
extern(C) c_int function(Display*) XProtocolRevision;
extern(C) c_int function(Screen*) XPlanesOfScreen;
extern(C) c_int function(Display*) XPending;
extern(C) c_int function(Display*, XEvent*, _BCD_func__1795, XPointer) XPeekIfEvent;
extern(C) c_int function(Display*, XEvent*) XPeekEvent;
extern(C) c_int function(const char*, c_int*, c_int*, c_uint*, c_uint*) XParseGeometry;
extern(C) Status function(Display*, Colormap, const char*, XColor*) XParseColor;
extern(C) c_int function(Display*) XNoOp;
extern(C) c_int function(Display*, XEvent*) XNextEvent;
extern(C) c_int function(Display*, Window, c_int, c_int) XMoveWindow;
extern(C) c_int function(Display*, Window, c_int, c_int, c_uint, c_uint) XMoveResizeWindow;
extern(C) c_int function(Screen*) XMinCmapsOfScreen;
extern(C) c_int function(Screen*) XMaxCmapsOfScreen;
extern(C) c_int function(Display*, c_long, XEvent*) XMaskEvent;
extern(C) c_int function(Display*, Window) XMapWindow;
extern(C) c_int function(Display*, Window) XMapSubwindows;
extern(C) c_int function(Display*, Window) XMapRaised;
extern(C) c_int function(Display*, Window) XLowerWindow;
extern(C) Status function(Display*, Colormap, const char*, XColor*, XColor*) XLookupColor;
extern(C) c_int function(Display*, XID) XKillClient;
extern(C) KeyCode function(Display*, KeySym) XKeysymToKeycode;
extern(C) c_int function(Display*, Colormap) XInstallColormap;
extern(C) c_int function(Display*) XImageByteOrder;
extern(C) c_int function(Display*, XEvent*, _BCD_func__1795, XPointer) XIfEvent;
extern(C) c_int function(Screen*) XHeightOfScreen;
extern(C) c_int function(Screen*) XHeightMMOfScreen;
extern(C) c_int function(Display*) XGrabServer;
extern(C) c_int function(Display*, Window, Bool, c_uint, c_int, c_int, Window, Cursor, Time) XGrabPointer;
extern(C) c_int function(Display*, Window, Bool, c_int, c_int, Time) XGrabKeyboard;
extern(C) c_int function(Display*, c_int, c_uint, Window, Bool, c_int, c_int) XGrabKey;
extern(C) c_int function(Display*, c_uint, c_uint, Window, Bool, c_uint, c_int, c_int, Window, Cursor) XGrabButton;
extern(C) Status function(Display*, Window, XWindowAttributes*) XGetWindowAttributes;
extern(C) c_int function(Display*, Window, Atom, c_long, c_long, Bool, Atom, Atom*, c_int*, c_ulong*, c_ulong*, char**) XGetWindowProperty;
extern(C) Status function(Display*, Window, Window*) XGetTransientForHint;
extern(C) c_int function(Display*, c_int*, c_int*, c_int*, c_int*) XGetScreenSaver;
extern(C) c_int function(Display*, char*, c_int) XGetPointerMapping;
extern(C) c_int function(Display*, c_int*, c_int*, c_int*) XGetPointerControl;
extern(C) c_int function(Display*, XKeyboardState*) XGetKeyboardControl;
extern(C) c_int function(Display*, Window*, c_int*) XGetInputFocus;
extern(C) Status function(Display*, Window, char**) XGetIconName;
extern(C) Status function(Display*, Drawable, Window*, c_int*, c_int*, c_uint*, c_uint*, c_uint*, c_uint*) XGetGeometry;
extern(C) Status function(Display*, GC, c_ulong, XGCValues*) XGetGCValues;
extern(C) Bool function(XFontStruct*, Atom, c_ulong*) XGetFontProperty;
extern(C) c_int function(Display*, c_int, char*, c_int) XGetErrorText;
extern(C) c_int function(Display*, const char*, const char*, const char*, char*, c_int) XGetErrorDatabaseText;
extern(C) c_int function(Display*, c_int, const char*, const char*, c_uint, c_uint, c_uint, c_int, c_int, c_int*, c_int*, c_int*, c_int*) XGeometry;
extern(C) c_int function(Display*, Pixmap) XFreePixmap;
extern(C) c_int function(XModifierKeymap*) XFreeModifiermap;
extern(C) c_int function(Display*, GC) XFreeGC;
extern(C) c_int function(char**) XFreeFontPath;
extern(C) c_int function(char**) XFreeFontNames;
extern(C) c_int function(char**, XFontStruct*, c_int) XFreeFontInfo;
extern(C) c_int function(Display*, XFontStruct*) XFreeFont;
extern(C) c_int function(char**) XFreeExtensionList;
extern(C) c_int function(Display*, Cursor) XFreeCursor;
extern(C) c_int function(Display*, Colormap, c_ulong*, c_int, c_ulong) XFreeColors;
extern(C) c_int function(Display*, Colormap) XFreeColormap;
extern(C) c_int function(void*) XFree;
extern(C) c_int function(Display*, c_int) XForceScreenSaver;
extern(C) c_int function(Display*) XFlush;
extern(C) c_int function(Display*, Drawable, GC, XRectangle*, c_int) XFillRectangles;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, c_uint, c_uint) XFillRectangle;
extern(C) c_int function(Display*, Drawable, GC, XPoint*, c_int, c_int, c_int) XFillPolygon;
extern(C) c_int function(Display*, Drawable, GC, XArc*, c_int) XFillArcs;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, c_uint, c_uint, c_int, c_int) XFillArc;
extern(C) Status function(Display*, Window, char**) XFetchName;
extern(C) c_int function(Display*, c_int) XEventsQueued;
extern(C) c_int function(Display*) XEnableAccessControl;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, XTextItem16*, c_int) XDrawText16;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, XTextItem*, c_int) XDrawText;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, const XChar2b*, c_int) XDrawString16;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, const char*, c_int) XDrawString;
extern(C) c_int function(Display*, Drawable, GC, XSegment*, c_int) XDrawSegments;
extern(C) c_int function(Display*, Drawable, GC, XRectangle*, c_int) XDrawRectangles;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, c_uint, c_uint) XDrawRectangle;
extern(C) c_int function(Display*, Drawable, GC, XPoint*, c_int, c_int) XDrawPoints;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int) XDrawPoint;
extern(C) c_int function(Display*, Drawable, GC, XPoint*, c_int, c_int) XDrawLines;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, c_int, c_int) XDrawLine;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, const XChar2b*, c_int) XDrawImageString16;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, const char*, c_int) XDrawImageString;
extern(C) c_int function(Display*, Drawable, GC, XArc*, c_int) XDrawArcs;
extern(C) c_int function(Display*, Drawable, GC, c_int, c_int, c_uint, c_uint, c_int, c_int) XDrawArc;
extern(C) c_int function(Display*, c_int) XDisplayWidthMM;
extern(C) c_int function(Display*, c_int) XDisplayWidth;
extern(C) c_int function(Display*, c_int) XDisplayPlanes;
extern(C) c_int function(Display*, c_int*, c_int*) XDisplayKeycodes;
extern(C) c_int function(Display*, c_int) XDisplayHeightMM;
extern(C) c_int function(Display*, c_int) XDisplayHeight;
extern(C) c_int function(Display*, c_int) XDisplayCells;
extern(C) c_int function(Display*) XDisableAccessControl;
extern(C) Bool function(Screen*) XDoesSaveUnders;
extern(C) c_int function(Screen*) XDoesBackingStore;
extern(C) c_int function(Display*, Window) XDestroySubwindows;
extern(C) c_int function(Display*, Window) XDestroyWindow;
extern(C) c_int function(Display*, Window, Atom) XDeleteProperty;
extern(C) c_int function(Display*, Window, Cursor) XDefineCursor;
extern(C) c_int function(Display*) XDefaultScreen;
extern(C) c_int function(Screen*) XDefaultDepthOfScreen;
extern(C) c_int function(Display*, c_int) XDefaultDepth;
extern(C) c_int function(Display*, Drawable, Drawable, GC, c_int, c_int, c_uint, c_uint, c_int, c_int, c_ulong) XCopyPlane;
extern(C) c_int function(Display*, GC, c_ulong, GC) XCopyGC;
extern(C) c_int function(Display*, Drawable, Drawable, GC, c_int, c_int, c_uint, c_uint, c_int, c_int) XCopyArea;
extern(C) c_int function(Display*, Atom, Atom, Atom, Window, Time) XConvertSelection;
extern(C) c_int function(Display*) XConnectionNumber;
extern(C) c_int function(Display*, Window, c_uint, XWindowChanges*) XConfigureWindow;
extern(C) c_int function(Display*) XCloseDisplay;
extern(C) c_int function(Display*, Window) XClearWindow;
extern(C) c_int function(Display*, Window, c_int, c_int, c_uint, c_uint, Bool) XClearArea;
extern(C) c_int function(Display*, Window) XCirculateSubwindowsUp;
extern(C) c_int function(Display*, Window) XCirculateSubwindowsDown;
extern(C) c_int function(Display*, Window, c_int) XCirculateSubwindows;
extern(C) Bool function(Display*, Window, c_long, XEvent*) XCheckWindowEvent;
extern(C) Bool function(Display*, Window, c_int, XEvent*) XCheckTypedWindowEvent;
extern(C) Bool function(Display*, c_int, XEvent*) XCheckTypedEvent;
extern(C) Bool function(Display*, c_long, XEvent*) XCheckMaskEvent;
extern(C) Bool function(Display*, XEvent*, _BCD_func__1795, XPointer) XCheckIfEvent;
extern(C) c_int function(Display*, Window, c_ulong, XSetWindowAttributes*) XChangeWindowAttributes;
extern(C) c_int function(Display*, Window, c_int) XChangeSaveSet;
extern(C) c_int function(Display*, Window, Atom, Atom, c_int, c_int, const char*, c_int) XChangeProperty;
extern(C) c_int function(Display*, Bool, Bool, c_int, c_int, c_int) XChangePointerControl;
extern(C) c_int function(Display*, c_int, c_int, KeySym*, c_int) XChangeKeyboardMapping;
extern(C) c_int function(Display*, c_ulong, XKeyboardControl*) XChangeKeyboardControl;
extern(C) c_int function(Display*, GC, c_ulong, XGCValues*) XChangeGC;
extern(C) c_int function(Display*, c_uint, Cursor, Time) XChangeActivePointerGrab;
extern(C) c_int function(Screen*) XCellsOfScreen;
extern(C) c_int function(Display*) XBitmapUnit;
extern(C) c_int function(Display*) XBitmapPad;
extern(C) c_int function(Display*) XBitmapBitOrder;
extern(C) c_int function(Display*, c_int) XBell;
extern(C) c_int function(Display*) XAutoRepeatOn;
extern(C) c_int function(Display*) XAutoRepeatOff;
extern(C) c_int function(Display*, c_int, Time) XAllowEvents;
extern(C) Status function(Display*, Colormap, const char*, XColor*, XColor*) XAllocNamedColor;
extern(C) Status function(Display*, Colormap, Bool, c_ulong*, c_int, c_int, c_int, c_int, c_ulong*, c_ulong*, c_ulong*) XAllocColorPlanes;
extern(C) Status function(Display*, Colormap, Bool, c_long*, c_uint, c_long*, c_uint) XAllocColorCells;
extern(C) Status function(Display*, Colormap, XColor*) XAllocColor;
extern(C) c_int function(Display*, Window) XAddToSaveSet;
extern(C) c_int function(_XExtData**, XExtData*) XAddToExtensionList;
extern(C) c_int function(Display*, XHostAddress*, c_int) XAddHosts;
extern(C) c_int function(Display*, XHostAddress*) XAddHost;
extern(C) c_int function(Display*) XActivateScreenSaver;
extern(C) c_int function(Display*, Window, Window) XSetTransientForHint;
extern(C) void function(char**) XFreeStringList;
extern(C) Status function(Display*, Window, Window*, c_int) XSetWMColormapWindows;
extern(C) Status function(Display*, Window, Window**, c_int*) XGetWMColormapWindows;
extern(C) Status function(Display*, Window, char***, c_int*) XGetCommand;
extern(C) Status function(Display*, Window, c_int) XWithdrawWindow;
extern(C) Status function(Display*, Window, c_int) XIconifyWindow;
extern(C) Status function(Display*, Window, Atom*, c_int) XSetWMProtocols;
extern(C) Status function(Display*, Window, Atom**, c_int*) XGetWMProtocols;
extern(C) Status function(Display*, Window, c_int, c_uint, XWindowChanges*) XReconfigureWMWindow;
extern(C) c_int* function(Display*, c_int, c_int*) XListDepths;
extern(C) XPixmapFormatValues* function(Display*, c_int*) XListPixmapFormats;
extern(C) XIOErrorHandler function(XIOErrorHandler) XSetIOErrorHandler;
extern(C) XErrorHandler function(XErrorHandler) XSetErrorHandler;
extern(C) c_int function(Screen*) XScreenNumberOfScreen;
extern(C) c_long function(Screen*) XEventMaskOfScreen;
extern(C) Screen* function(Display*) XDefaultScreenOfDisplay;
extern(C) Screen* function(Display*, c_int) XScreenOfDisplay;
extern(C) Display* function(Screen*) XDisplayOfScreen;
extern(C) Colormap function(Screen*) XDefaultColormapOfScreen;
extern(C) Colormap function(Display*, c_int) XDefaultColormap;
extern(C) char* function(Display*) XDisplayString;
extern(C) char* function(Display*) XServerVendor;
extern(C) c_ulong function(Display*) XLastKnownRequestProcessed;
extern(C) c_ulong function(Display*) XNextRequest;
extern(C) c_ulong function(Screen*) XWhitePixelOfScreen;
extern(C) c_ulong function(Screen*) XBlackPixelOfScreen;
extern(C) c_ulong XAllPlanes();
extern(C) c_ulong function(Display*, c_int) XWhitePixel;
extern(C) c_ulong function(Display*, c_int) XBlackPixel;
extern(C) GC function(Screen*) XDefaultGCOfScreen;
extern(C) GC function(Display*, c_int) XDefaultGC;
extern(C) Visual* function(Screen*) XDefaultVisualOfScreen;
extern(C) Visual* function(Display*, c_int) XDefaultVisual;
extern(C) Window function(Screen*) XRootWindowOfScreen;
extern(C) Window function(Display*) XDefaultRootWindow;
extern(C) Window function(Display*, c_int) XRootWindow;
extern(C) XExtData** function(XEDataObject) XEHeadOfExtensionList;
extern(C) XExtData* function(XExtData**, c_int) XFindOnExtensionList;
extern(C) XExtCodes* function(Display*) XAddExtension;
extern(C) XExtCodes* function(Display*, const char*) XInitExtension;
extern(C) void function(Display*) XUnlockDisplay;
extern(C) void function(Display*) XLockDisplay;
extern(C) Status XInitThreads();
extern(C) VisualID function(Visual*) XVisualIDFromVisual;
extern(C) c_ulong function(Display*) XDisplayMotionBufferSize;
extern(C) char* function(Screen*) XScreenResourceString;
extern(C) char* function(Display*) XResourceManagerString;
extern(C) c_int function(Display*) XExtendedMaxRequestSize;
extern(C) c_long function(Display*) XMaxRequestSize;
extern(C) KeySym function(const char*) XStringToKeysym;
extern(C) KeySym* function(Display*, KeyCode, c_int, c_int*) XGetKeyboardMapping;
extern(C) KeySym function(XKeyEvent*, c_int) XLookupKeysym;
extern(C) KeySym function(Display*, KeyCode, c_int) XKeycodeToKeysym;
extern(C) XHostAddress* function(Display*, c_int*, Bool*) XListHosts;
extern(C) Atom* function(Display*, Window, c_int*) XListProperties;
extern(C) char** function(Display*, c_int*) XListExtensions;
extern(C) char** function(Display*, c_int*) XGetFontPath;
extern(C) char** function(Display*, const char*, c_int, c_int*, XFontStruct**) XListFontsWithInfo;
extern(C) char** function(Display*, const char*, c_int, c_int*) XListFonts;
extern(C) Colormap* function(Display*, Window, c_int*) XListInstalledColormaps;
extern(C) Window function(Display*, Window, c_int, c_int, c_uint, c_uint, c_uint, c_int, c_uint, Visual*, c_ulong, XSetWindowAttributes*) XCreateWindow; 
extern(C) Window function(Display*, Atom) XGetSelectionOwner;
extern(C) Window function(Display*, Window, c_int, c_int, c_uint, c_uint, c_uint, c_ulong, c_ulong) XCreateSimpleWindow;
extern(C) Pixmap function(Display*, Drawable, char*, c_uint, c_uint, c_ulong, c_ulong, c_uint) XCreatePixmapFromBitmapData;
extern(C) Pixmap function(Display*, Drawable, const char*, c_uint, c_uint) XCreateBitmapFromData;
extern(C) Pixmap function(Display*, Drawable, c_uint, c_uint, c_uint) XCreatePixmap;
extern(C) void function(Display*, GC) XFlushGC;
extern(C) GContext function(GC) XGContextFromGC;
extern(C) GC function(Display*, Drawable, c_ulong, XGCValues*) XCreateGC;
extern(C) Font function(Display*, const char*) XLoadFont;
extern(C) Cursor function(Display*, c_uint) XCreateFontCursor;
extern(C) Cursor function(Display*, Font, Font, c_uint, c_uint, const XColor*, const XColor* ) XCreateGlyphCursor;
extern(C) Cursor function(Display*, Pixmap, Pixmap, XColor*, XColor*, c_uint, c_uint) XCreatePixmapCursor;
extern(C) Colormap function(Display*, Window, Visual*, c_int) XCreateColormap;
extern(C) Colormap function(Display*, Colormap) XCopyColormapAndFree;
extern(C) Status function(Display*, char**, c_int, Bool, Atom*) XInternAtoms;
extern(C) Atom function(Display*, const char*, Bool) XInternAtom;
extern(C) _BCD_func__894 function(Display*, _BCD_func__894) XSetAfterFunction;
extern(C) _BCD_func__894 function(Display*, Bool) XSynchronize;
extern(C) char* function(KeySym) XKeysymToString;
extern(C) char* function(const char*) XDisplayName;
extern(C) char* function(Display*, const char*, const char*) XGetDefault;
extern(C) Status function(Display*, Atom*, c_int, char**) XGetAtomNames;
extern(C) char* function(Display*, Atom) XGetAtomName;
extern(C) char* function(Display*, c_int*, c_int) XFetchBuffer;
extern(C) char* function(Display*, c_int*) XFetchBytes;
extern(C) void XrmInitialize();
extern(C) Display* function(const char*) XOpenDisplay;
extern(C) XImage* function(Display*, Drawable, c_int, c_int, c_uint, c_uint, c_ulong, c_int, XImage*, c_int, c_int) XGetSubImage;
extern(C) XImage* function(Display*, Drawable, c_int, c_int, c_uint, c_uint, c_ulong, c_int) XGetImage;
extern(C) Status function(XImage*) XInitImage;
extern(C) XImage* function(Display*, Visual*, c_uint, c_int, c_int, char*, c_uint, c_uint, c_int, c_int) XCreateImage;
extern(C) XModifierKeymap* function(c_int) XNewModifiermap;
extern(C) XModifierKeymap* function(XModifierKeymap*, KeyCode, c_int) XInsertModifiermapEntry;
extern(C) XModifierKeymap* function(Display*) XGetModifierMapping;
extern(C) XModifierKeymap* function(XModifierKeymap*, KeyCode, c_int) XDeleteModifiermapEntry;
extern(C) XTimeCoord* function(Display*, Window, Time, Time, c_int*) XGetMotionEvents;
extern(C) XFontStruct* function(Display*, XID) XQueryFont;
extern(C) XFontStruct* function(Display*, const char*) XLoadQueryFont;
extern(C) extern c_int _Xdebug;
extern(C) c_int function(char*, c_int) _Xmblen;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("_Xwctomb",  cast(void**)& _Xwctomb),
        Symbol("_Xmbtowc",  cast(void**)& _Xmbtowc),
        Symbol("XSetAuthorization",  cast(void**)& XSetAuthorization),
        Symbol("XRemoveConnectionWatch",  cast(void**)& XRemoveConnectionWatch),
        Symbol("XAddConnectionWatch",  cast(void**)& XAddConnectionWatch),
        Symbol("XProcessInternalConnection",  cast(void**)& XProcessInternalConnection),
        Symbol("XInternalConnectionNumbers",  cast(void**)& XInternalConnectionNumbers),
        Symbol("XUnregisterIMInstantiateCallback",  cast(void**)& XUnregisterIMInstantiateCallback),
        Symbol("XRegisterIMInstantiateCallback",  cast(void**)& XRegisterIMInstantiateCallback),
        Symbol("XVaCreateNestedList",  cast(void**)& XVaCreateNestedList),
        Symbol("Xutf8LookupString",  cast(void**)& Xutf8LookupString),
        Symbol("XwcLookupString",  cast(void**)& XwcLookupString),
        Symbol("XmbLookupString",  cast(void**)& XmbLookupString),
        Symbol("XFilterEvent",  cast(void**)& XFilterEvent),
        Symbol("XIMOfIC",  cast(void**)& XIMOfIC),
        Symbol("XGetICValues",  cast(void**)& XGetICValues),
        Symbol("XSetICValues",  cast(void**)& XSetICValues),
        Symbol("Xutf8ResetIC",  cast(void**)& Xutf8ResetIC),
        Symbol("XmbResetIC",  cast(void**)& XmbResetIC),
        Symbol("XwcResetIC",  cast(void**)& XwcResetIC),
        Symbol("XUnsetICFocus",  cast(void**)& XUnsetICFocus),
        Symbol("XSetICFocus",  cast(void**)& XSetICFocus),
        Symbol("XDestroyIC",  cast(void**)& XDestroyIC),
        Symbol("XCreateIC",  cast(void**)& XCreateIC),
        Symbol("XLocaleOfIM",  cast(void**)& XLocaleOfIM),
        Symbol("XDisplayOfIM",  cast(void**)& XDisplayOfIM),
        Symbol("XSetIMValues",  cast(void**)& XSetIMValues),
        Symbol("XGetIMValues",  cast(void**)& XGetIMValues),
        Symbol("XCloseIM",  cast(void**)& XCloseIM),
        Symbol("XOpenIM",  cast(void**)& XOpenIM),
        Symbol("Xutf8DrawImageString",  cast(void**)& Xutf8DrawImageString),
        Symbol("XwcDrawImageString",  cast(void**)& XwcDrawImageString),
        Symbol("XmbDrawImageString",  cast(void**)& XmbDrawImageString),
        Symbol("Xutf8DrawString",  cast(void**)& Xutf8DrawString),
        Symbol("XwcDrawString",  cast(void**)& XwcDrawString),
        Symbol("XmbDrawString",  cast(void**)& XmbDrawString),
        Symbol("Xutf8DrawText",  cast(void**)& Xutf8DrawText),
        Symbol("XwcDrawText",  cast(void**)& XwcDrawText),
        Symbol("XmbDrawText",  cast(void**)& XmbDrawText),
        Symbol("Xutf8TextPerCharExtents",  cast(void**)& Xutf8TextPerCharExtents),
        Symbol("XwcTextPerCharExtents",  cast(void**)& XwcTextPerCharExtents),
        Symbol("XmbTextPerCharExtents",  cast(void**)& XmbTextPerCharExtents),
        Symbol("Xutf8TextExtents",  cast(void**)& Xutf8TextExtents),
        Symbol("XwcTextExtents",  cast(void**)& XwcTextExtents),
        Symbol("XmbTextExtents",  cast(void**)& XmbTextExtents),
        Symbol("Xutf8TextEscapement",  cast(void**)& Xutf8TextEscapement),
        Symbol("XwcTextEscapement",  cast(void**)& XwcTextEscapement),
        Symbol("XmbTextEscapement",  cast(void**)& XmbTextEscapement),
        Symbol("XExtentsOfFontSet",  cast(void**)& XExtentsOfFontSet),
        Symbol("XContextualDrawing",  cast(void**)& XContextualDrawing),
        Symbol("XDirectionalDependentDrawing",  cast(void**)& XDirectionalDependentDrawing),
        Symbol("XContextDependentDrawing",  cast(void**)& XContextDependentDrawing),
        Symbol("XLocaleOfFontSet",  cast(void**)& XLocaleOfFontSet),
        Symbol("XBaseFontNameListOfFontSet",  cast(void**)& XBaseFontNameListOfFontSet),
        Symbol("XFontsOfFontSet",  cast(void**)& XFontsOfFontSet),
        Symbol("XFreeFontSet",  cast(void**)& XFreeFontSet),
        Symbol("XCreateFontSet",  cast(void**)& XCreateFontSet),
        Symbol("XGetOCValues",  cast(void**)& XGetOCValues),
        Symbol("XSetOCValues",  cast(void**)& XSetOCValues),
        Symbol("XOMOfOC",  cast(void**)& XOMOfOC),
        Symbol("XDestroyOC",  cast(void**)& XDestroyOC),
        Symbol("XCreateOC",  cast(void**)& XCreateOC),
        Symbol("XLocaleOfOM",  cast(void**)& XLocaleOfOM),
        Symbol("XDisplayOfOM",  cast(void**)& XDisplayOfOM),
        Symbol("XGetOMValues",  cast(void**)& XGetOMValues),
        Symbol("XSetOMValues",  cast(void**)& XSetOMValues),
        Symbol("XCloseOM",  cast(void**)& XCloseOM),
        Symbol("XOpenOM",  cast(void**)& XOpenOM),
        Symbol("XSetLocaleModifiers",  cast(void**)& XSetLocaleModifiers),
        Symbol("XSupportsLocale",  cast(void**)& XSupportsLocale),
        Symbol("XWriteBitmapFile",  cast(void**)& XWriteBitmapFile),
        Symbol("XWindowEvent",  cast(void**)& XWindowEvent),
        Symbol("XWidthOfScreen",  cast(void**)& XWidthOfScreen),
        Symbol("XWidthMMOfScreen",  cast(void**)& XWidthMMOfScreen),
        Symbol("XWarpPointer",  cast(void**)& XWarpPointer),
        Symbol("XVendorRelease",  cast(void**)& XVendorRelease),
        Symbol("XUnmapWindow",  cast(void**)& XUnmapWindow),
        Symbol("XUnmapSubwindows",  cast(void**)& XUnmapSubwindows),
        Symbol("XUnloadFont",  cast(void**)& XUnloadFont),
        Symbol("XUninstallColormap",  cast(void**)& XUninstallColormap),
        Symbol("XUngrabServer",  cast(void**)& XUngrabServer),
        Symbol("XUngrabPointer",  cast(void**)& XUngrabPointer),
        Symbol("XUngrabKeyboard",  cast(void**)& XUngrabKeyboard),
        Symbol("XUngrabKey",  cast(void**)& XUngrabKey),
        Symbol("XUngrabButton",  cast(void**)& XUngrabButton),
        Symbol("XUndefineCursor",  cast(void**)& XUndefineCursor),
        Symbol("XTranslateCoordinates",  cast(void**)& XTranslateCoordinates),
        Symbol("XTextWidth16",  cast(void**)& XTextWidth16),
        Symbol("XTextWidth",  cast(void**)& XTextWidth),
        Symbol("XTextExtents16",  cast(void**)& XTextExtents16),
        Symbol("XTextExtents",  cast(void**)& XTextExtents),
        Symbol("XSync",  cast(void**)& XSync),
        Symbol("XStoreNamedColor",  cast(void**)& XStoreNamedColor),
        Symbol("XStoreName",  cast(void**)& XStoreName),
        Symbol("XStoreColors",  cast(void**)& XStoreColors),
        Symbol("XStoreColor",  cast(void**)& XStoreColor),
        Symbol("XStoreBytes",  cast(void**)& XStoreBytes),
        Symbol("XStoreBuffer",  cast(void**)& XStoreBuffer),
        Symbol("XSetWindowColormap",  cast(void**)& XSetWindowColormap),
        Symbol("XSetWindowBorderWidth",  cast(void**)& XSetWindowBorderWidth),
        Symbol("XSetWindowBorderPixmap",  cast(void**)& XSetWindowBorderPixmap),
        Symbol("XSetWindowBorder",  cast(void**)& XSetWindowBorder),
        Symbol("XSetWindowBackgroundPixmap",  cast(void**)& XSetWindowBackgroundPixmap),
        Symbol("XSetWindowBackground",  cast(void**)& XSetWindowBackground),
        Symbol("XSetTile",  cast(void**)& XSetTile),
        Symbol("XSetTSOrigin",  cast(void**)& XSetTSOrigin),
        Symbol("XSetSubwindowMode",  cast(void**)& XSetSubwindowMode),
        Symbol("XSetStipple",  cast(void**)& XSetStipple),
        Symbol("XSetState",  cast(void**)& XSetState),
        Symbol("XSetSelectionOwner",  cast(void**)& XSetSelectionOwner),
        Symbol("XSetScreenSaver",  cast(void**)& XSetScreenSaver),
        Symbol("XSetPointerMapping",  cast(void**)& XSetPointerMapping),
        Symbol("XSetPlaneMask",  cast(void**)& XSetPlaneMask),
        Symbol("XSetModifierMapping",  cast(void**)& XSetModifierMapping),
        Symbol("XSetLineAttributes",  cast(void**)& XSetLineAttributes),
        Symbol("XSetInputFocus",  cast(void**)& XSetInputFocus),
        Symbol("XSetIconName",  cast(void**)& XSetIconName),
        Symbol("XSetGraphicsExposures",  cast(void**)& XSetGraphicsExposures),
        Symbol("XSetFunction",  cast(void**)& XSetFunction),
        Symbol("XSetForeground",  cast(void**)& XSetForeground),
        Symbol("XSetFontPath",  cast(void**)& XSetFontPath),
        Symbol("XSetFont",  cast(void**)& XSetFont),
        Symbol("XSetFillStyle",  cast(void**)& XSetFillStyle),
        Symbol("XSetFillRule",  cast(void**)& XSetFillRule),
        Symbol("XSetDashes",  cast(void**)& XSetDashes),
        Symbol("XSetCommand",  cast(void**)& XSetCommand),
        Symbol("XSetCloseDownMode",  cast(void**)& XSetCloseDownMode),
        Symbol("XSetClipRectangles",  cast(void**)& XSetClipRectangles),
        Symbol("XSetClipOrigin",  cast(void**)& XSetClipOrigin),
        Symbol("XSetClipMask",  cast(void**)& XSetClipMask),
        Symbol("XSetBackground",  cast(void**)& XSetBackground),
        Symbol("XSetArcMode",  cast(void**)& XSetArcMode),
        Symbol("XSetAccessControl",  cast(void**)& XSetAccessControl),
        Symbol("XSendEvent",  cast(void**)& XSendEvent),
        Symbol("XSelectInput",  cast(void**)& XSelectInput),
        Symbol("XScreenCount",  cast(void**)& XScreenCount),
        Symbol("XRotateWindowProperties",  cast(void**)& XRotateWindowProperties),
        Symbol("XRotateBuffers",  cast(void**)& XRotateBuffers),
        Symbol("XRestackWindows",  cast(void**)& XRestackWindows),
        Symbol("XResizeWindow",  cast(void**)& XResizeWindow),
        Symbol("XResetScreenSaver",  cast(void**)& XResetScreenSaver),
        Symbol("XReparentWindow",  cast(void**)& XReparentWindow),
        Symbol("XRemoveHosts",  cast(void**)& XRemoveHosts),
        Symbol("XRemoveHost",  cast(void**)& XRemoveHost),
        Symbol("XRemoveFromSaveSet",  cast(void**)& XRemoveFromSaveSet),
        Symbol("XRefreshKeyboardMapping",  cast(void**)& XRefreshKeyboardMapping),
        Symbol("XRecolorCursor",  cast(void**)& XRecolorCursor),
        Symbol("XRebindKeysym",  cast(void**)& XRebindKeysym),
        Symbol("XReadBitmapFileData",  cast(void**)& XReadBitmapFileData),
        Symbol("XReadBitmapFile",  cast(void**)& XReadBitmapFile),
        Symbol("XRaiseWindow",  cast(void**)& XRaiseWindow),
        Symbol("XQueryTree",  cast(void**)& XQueryTree),
        Symbol("XQueryTextExtents16",  cast(void**)& XQueryTextExtents16),
        Symbol("XQueryTextExtents",  cast(void**)& XQueryTextExtents),
        Symbol("XQueryPointer",  cast(void**)& XQueryPointer),
        Symbol("XQueryKeymap",  cast(void**)& XQueryKeymap),
        Symbol("XQueryExtension",  cast(void**)& XQueryExtension),
        Symbol("XQueryColors",  cast(void**)& XQueryColors),
        Symbol("XQueryColor",  cast(void**)& XQueryColor),
        Symbol("XQueryBestTile",  cast(void**)& XQueryBestTile),
        Symbol("XQueryBestStipple",  cast(void**)& XQueryBestStipple),
        Symbol("XQueryBestSize",  cast(void**)& XQueryBestSize),
        Symbol("XQueryBestCursor",  cast(void**)& XQueryBestCursor),
        Symbol("XQLength",  cast(void**)& XQLength),
        Symbol("XPutImage",  cast(void**)& XPutImage),
        Symbol("XPutBackEvent",  cast(void**)& XPutBackEvent),
        Symbol("XProtocolVersion",  cast(void**)& XProtocolVersion),
        Symbol("XProtocolRevision",  cast(void**)& XProtocolRevision),
        Symbol("XPlanesOfScreen",  cast(void**)& XPlanesOfScreen),
        Symbol("XPending",  cast(void**)& XPending),
        Symbol("XPeekIfEvent",  cast(void**)& XPeekIfEvent),
        Symbol("XPeekEvent",  cast(void**)& XPeekEvent),
        Symbol("XParseGeometry",  cast(void**)& XParseGeometry),
        Symbol("XParseColor",  cast(void**)& XParseColor),
        Symbol("XNoOp",  cast(void**)& XNoOp),
        Symbol("XNextEvent",  cast(void**)& XNextEvent),
        Symbol("XMoveWindow",  cast(void**)& XMoveWindow),
        Symbol("XMoveResizeWindow",  cast(void**)& XMoveResizeWindow),
        Symbol("XMinCmapsOfScreen",  cast(void**)& XMinCmapsOfScreen),
        Symbol("XMaxCmapsOfScreen",  cast(void**)& XMaxCmapsOfScreen),
        Symbol("XMaskEvent",  cast(void**)& XMaskEvent),
        Symbol("XMapWindow",  cast(void**)& XMapWindow),
        Symbol("XMapSubwindows",  cast(void**)& XMapSubwindows),
        Symbol("XMapRaised",  cast(void**)& XMapRaised),
        Symbol("XLowerWindow",  cast(void**)& XLowerWindow),
        Symbol("XLookupColor",  cast(void**)& XLookupColor),
        Symbol("XKillClient",  cast(void**)& XKillClient),
        Symbol("XKeysymToKeycode",  cast(void**)& XKeysymToKeycode),
        Symbol("XInstallColormap",  cast(void**)& XInstallColormap),
        Symbol("XImageByteOrder",  cast(void**)& XImageByteOrder),
        Symbol("XIfEvent",  cast(void**)& XIfEvent),
        Symbol("XHeightOfScreen",  cast(void**)& XHeightOfScreen),
        Symbol("XHeightMMOfScreen",  cast(void**)& XHeightMMOfScreen),
        Symbol("XGrabServer",  cast(void**)& XGrabServer),
        Symbol("XGrabPointer",  cast(void**)& XGrabPointer),
        Symbol("XGrabKeyboard",  cast(void**)& XGrabKeyboard),
        Symbol("XGrabKey",  cast(void**)& XGrabKey),
        Symbol("XGrabButton",  cast(void**)& XGrabButton),
        Symbol("XGetWindowAttributes",  cast(void**)& XGetWindowAttributes),
        Symbol("XGetWindowProperty",  cast(void**)& XGetWindowProperty),
        Symbol("XGetTransientForHint",  cast(void**)& XGetTransientForHint),
        Symbol("XGetScreenSaver",  cast(void**)& XGetScreenSaver),
        Symbol("XGetPointerMapping",  cast(void**)& XGetPointerMapping),
        Symbol("XGetPointerControl",  cast(void**)& XGetPointerControl),
        Symbol("XGetKeyboardControl",  cast(void**)& XGetKeyboardControl),
        Symbol("XGetInputFocus",  cast(void**)& XGetInputFocus),
        Symbol("XGetIconName",  cast(void**)& XGetIconName),
        Symbol("XGetGeometry",  cast(void**)& XGetGeometry),
        Symbol("XGetGCValues",  cast(void**)& XGetGCValues),
        Symbol("XGetFontProperty",  cast(void**)& XGetFontProperty),
        Symbol("XGetErrorText",  cast(void**)& XGetErrorText),
        Symbol("XGetErrorDatabaseText",  cast(void**)& XGetErrorDatabaseText),
        Symbol("XGeometry",  cast(void**)& XGeometry),
        Symbol("XFreePixmap",  cast(void**)& XFreePixmap),
        Symbol("XFreeModifiermap",  cast(void**)& XFreeModifiermap),
        Symbol("XFreeGC",  cast(void**)& XFreeGC),
        Symbol("XFreeFontPath",  cast(void**)& XFreeFontPath),
        Symbol("XFreeFontNames",  cast(void**)& XFreeFontNames),
        Symbol("XFreeFontInfo",  cast(void**)& XFreeFontInfo),
        Symbol("XFreeFont",  cast(void**)& XFreeFont),
        Symbol("XFreeExtensionList",  cast(void**)& XFreeExtensionList),
        Symbol("XFreeCursor",  cast(void**)& XFreeCursor),
        Symbol("XFreeColors",  cast(void**)& XFreeColors),
        Symbol("XFreeColormap",  cast(void**)& XFreeColormap),
        Symbol("XFree",  cast(void**)& XFree),
        Symbol("XForceScreenSaver",  cast(void**)& XForceScreenSaver),
        Symbol("XFlush",  cast(void**)& XFlush),
        Symbol("XFillRectangles",  cast(void**)& XFillRectangles),
        Symbol("XFillRectangle",  cast(void**)& XFillRectangle),
        Symbol("XFillPolygon",  cast(void**)& XFillPolygon),
        Symbol("XFillArcs",  cast(void**)& XFillArcs),
        Symbol("XFillArc",  cast(void**)& XFillArc),
        Symbol("XFetchName",  cast(void**)& XFetchName),
        Symbol("XEventsQueued",  cast(void**)& XEventsQueued),
        Symbol("XEnableAccessControl",  cast(void**)& XEnableAccessControl),
        Symbol("XDrawText16",  cast(void**)& XDrawText16),
        Symbol("XDrawText",  cast(void**)& XDrawText),
        Symbol("XDrawString16",  cast(void**)& XDrawString16),
        Symbol("XDrawString",  cast(void**)& XDrawString),
        Symbol("XDrawSegments",  cast(void**)& XDrawSegments),
        Symbol("XDrawRectangles",  cast(void**)& XDrawRectangles),
        Symbol("XDrawRectangle",  cast(void**)& XDrawRectangle),
        Symbol("XDrawPoints",  cast(void**)& XDrawPoints),
        Symbol("XDrawPoint",  cast(void**)& XDrawPoint),
        Symbol("XDrawLines",  cast(void**)& XDrawLines),
        Symbol("XDrawLine",  cast(void**)& XDrawLine),
        Symbol("XDrawImageString16",  cast(void**)& XDrawImageString16),
        Symbol("XDrawImageString",  cast(void**)& XDrawImageString),
        Symbol("XDrawArcs",  cast(void**)& XDrawArcs),
        Symbol("XDrawArc",  cast(void**)& XDrawArc),
        Symbol("XDisplayWidthMM",  cast(void**)& XDisplayWidthMM),
        Symbol("XDisplayWidth",  cast(void**)& XDisplayWidth),
        Symbol("XDisplayPlanes",  cast(void**)& XDisplayPlanes),
        Symbol("XDisplayKeycodes",  cast(void**)& XDisplayKeycodes),
        Symbol("XDisplayHeightMM",  cast(void**)& XDisplayHeightMM),
        Symbol("XDisplayHeight",  cast(void**)& XDisplayHeight),
        Symbol("XDisplayCells",  cast(void**)& XDisplayCells),
        Symbol("XDisableAccessControl",  cast(void**)& XDisableAccessControl),
        Symbol("XDoesSaveUnders",  cast(void**)& XDoesSaveUnders),
        Symbol("XDoesBackingStore",  cast(void**)& XDoesBackingStore),
        Symbol("XDestroySubwindows",  cast(void**)& XDestroySubwindows),
        Symbol("XDestroyWindow",  cast(void**)& XDestroyWindow),
        Symbol("XDeleteProperty",  cast(void**)& XDeleteProperty),
        Symbol("XDefineCursor",  cast(void**)& XDefineCursor),
        Symbol("XDefaultScreen",  cast(void**)& XDefaultScreen),
        Symbol("XDefaultDepthOfScreen",  cast(void**)& XDefaultDepthOfScreen),
        Symbol("XDefaultDepth",  cast(void**)& XDefaultDepth),
        Symbol("XCopyPlane",  cast(void**)& XCopyPlane),
        Symbol("XCopyGC",  cast(void**)& XCopyGC),
        Symbol("XCopyArea",  cast(void**)& XCopyArea),
        Symbol("XConvertSelection",  cast(void**)& XConvertSelection),
        Symbol("XConnectionNumber",  cast(void**)& XConnectionNumber),
        Symbol("XConfigureWindow",  cast(void**)& XConfigureWindow),
        Symbol("XCloseDisplay",  cast(void**)& XCloseDisplay),
        Symbol("XClearWindow",  cast(void**)& XClearWindow),
        Symbol("XClearArea",  cast(void**)& XClearArea),
        Symbol("XCirculateSubwindowsUp",  cast(void**)& XCirculateSubwindowsUp),
        Symbol("XCirculateSubwindowsDown",  cast(void**)& XCirculateSubwindowsDown),
        Symbol("XCirculateSubwindows",  cast(void**)& XCirculateSubwindows),
        Symbol("XCheckWindowEvent",  cast(void**)& XCheckWindowEvent),
        Symbol("XCheckTypedWindowEvent",  cast(void**)& XCheckTypedWindowEvent),
        Symbol("XCheckTypedEvent",  cast(void**)& XCheckTypedEvent),
        Symbol("XCheckMaskEvent",  cast(void**)& XCheckMaskEvent),
        Symbol("XCheckIfEvent",  cast(void**)& XCheckIfEvent),
        Symbol("XChangeWindowAttributes",  cast(void**)& XChangeWindowAttributes),
        Symbol("XChangeSaveSet",  cast(void**)& XChangeSaveSet),
        Symbol("XChangeProperty",  cast(void**)& XChangeProperty),
        Symbol("XChangePointerControl",  cast(void**)& XChangePointerControl),
        Symbol("XChangeKeyboardMapping",  cast(void**)& XChangeKeyboardMapping),
        Symbol("XChangeKeyboardControl",  cast(void**)& XChangeKeyboardControl),
        Symbol("XChangeGC",  cast(void**)& XChangeGC),
        Symbol("XChangeActivePointerGrab",  cast(void**)& XChangeActivePointerGrab),
        Symbol("XCellsOfScreen",  cast(void**)& XCellsOfScreen),
        Symbol("XBitmapUnit",  cast(void**)& XBitmapUnit),
        Symbol("XBitmapPad",  cast(void**)& XBitmapPad),
        Symbol("XBitmapBitOrder",  cast(void**)& XBitmapBitOrder),
        Symbol("XBell",  cast(void**)& XBell),
        Symbol("XAutoRepeatOn",  cast(void**)& XAutoRepeatOn),
        Symbol("XAutoRepeatOff",  cast(void**)& XAutoRepeatOff),
        Symbol("XAllowEvents",  cast(void**)& XAllowEvents),
        Symbol("XAllocNamedColor",  cast(void**)& XAllocNamedColor),
        Symbol("XAllocColorPlanes",  cast(void**)& XAllocColorPlanes),
        Symbol("XAllocColorCells",  cast(void**)& XAllocColorCells),
        Symbol("XAllocColor",  cast(void**)& XAllocColor),
        Symbol("XAddToSaveSet",  cast(void**)& XAddToSaveSet),
        Symbol("XAddToExtensionList",  cast(void**)& XAddToExtensionList),
        Symbol("XAddHosts",  cast(void**)& XAddHosts),
        Symbol("XAddHost",  cast(void**)& XAddHost),
        Symbol("XActivateScreenSaver",  cast(void**)& XActivateScreenSaver),
        Symbol("XSetTransientForHint",  cast(void**)& XSetTransientForHint),
        Symbol("XFreeStringList",  cast(void**)& XFreeStringList),
        Symbol("XSetWMColormapWindows",  cast(void**)& XSetWMColormapWindows),
        Symbol("XGetWMColormapWindows",  cast(void**)& XGetWMColormapWindows),
        Symbol("XGetCommand",  cast(void**)& XGetCommand),
        Symbol("XWithdrawWindow",  cast(void**)& XWithdrawWindow),
        Symbol("XIconifyWindow",  cast(void**)& XIconifyWindow),
        Symbol("XSetWMProtocols",  cast(void**)& XSetWMProtocols),
        Symbol("XGetWMProtocols",  cast(void**)& XGetWMProtocols),
        Symbol("XReconfigureWMWindow",  cast(void**)& XReconfigureWMWindow),
        Symbol("XListDepths",  cast(void**)& XListDepths),
        Symbol("XListPixmapFormats",  cast(void**)& XListPixmapFormats),
        Symbol("XSetIOErrorHandler",  cast(void**)& XSetIOErrorHandler),
        Symbol("XSetErrorHandler",  cast(void**)& XSetErrorHandler),
        Symbol("XScreenNumberOfScreen",  cast(void**)& XScreenNumberOfScreen),
        Symbol("XEventMaskOfScreen",  cast(void**)& XEventMaskOfScreen),
        Symbol("XDefaultScreenOfDisplay",  cast(void**)& XDefaultScreenOfDisplay),
        Symbol("XScreenOfDisplay",  cast(void**)& XScreenOfDisplay),
        Symbol("XDisplayOfScreen",  cast(void**)& XDisplayOfScreen),
        Symbol("XDefaultColormapOfScreen",  cast(void**)& XDefaultColormapOfScreen),
        Symbol("XDefaultColormap",  cast(void**)& XDefaultColormap),
        Symbol("XDisplayString",  cast(void**)& XDisplayString),
        Symbol("XServerVendor",  cast(void**)& XServerVendor),
        Symbol("XLastKnownRequestProcessed",  cast(void**)& XLastKnownRequestProcessed),
        Symbol("XNextRequest",  cast(void**)& XNextRequest),
        Symbol("XWhitePixelOfScreen",  cast(void**)& XWhitePixelOfScreen),
        Symbol("XBlackPixelOfScreen",  cast(void**)& XBlackPixelOfScreen),
        Symbol("XAllPlanes",  cast(void**)& XAllPlanes),
        Symbol("XWhitePixel",  cast(void**)& XWhitePixel),
        Symbol("XBlackPixel",  cast(void**)& XBlackPixel),
        Symbol("XDefaultGCOfScreen",  cast(void**)& XDefaultGCOfScreen),
        Symbol("XDefaultGC",  cast(void**)& XDefaultGC),
        Symbol("XDefaultVisualOfScreen",  cast(void**)& XDefaultVisualOfScreen),
        Symbol("XDefaultVisual",  cast(void**)& XDefaultVisual),
        Symbol("XRootWindowOfScreen",  cast(void**)& XRootWindowOfScreen),
        Symbol("XDefaultRootWindow",  cast(void**)& XDefaultRootWindow),
        Symbol("XRootWindow",  cast(void**)& XRootWindow),
        Symbol("XEHeadOfExtensionList",  cast(void**)& XEHeadOfExtensionList),
        Symbol("XFindOnExtensionList",  cast(void**)& XFindOnExtensionList),
        Symbol("XAddExtension",  cast(void**)& XAddExtension),
        Symbol("XInitExtension",  cast(void**)& XInitExtension),
        Symbol("XUnlockDisplay",  cast(void**)& XUnlockDisplay),
        Symbol("XLockDisplay",  cast(void**)& XLockDisplay),
        Symbol("XInitThreads",  cast(void**)& XInitThreads),
        Symbol("XVisualIDFromVisual",  cast(void**)& XVisualIDFromVisual),
        Symbol("XDisplayMotionBufferSize",  cast(void**)& XDisplayMotionBufferSize),
        Symbol("XScreenResourceString",  cast(void**)& XScreenResourceString),
        Symbol("XResourceManagerString",  cast(void**)& XResourceManagerString),
        Symbol("XExtendedMaxRequestSize",  cast(void**)& XExtendedMaxRequestSize),
        Symbol("XMaxRequestSize",  cast(void**)& XMaxRequestSize),
        Symbol("XStringToKeysym",  cast(void**)& XStringToKeysym),
        Symbol("XGetKeyboardMapping",  cast(void**)& XGetKeyboardMapping),
        Symbol("XLookupKeysym",  cast(void**)& XLookupKeysym),
        Symbol("XKeycodeToKeysym",  cast(void**)& XKeycodeToKeysym),
        Symbol("XListHosts",  cast(void**)& XListHosts),
        Symbol("XListProperties",  cast(void**)& XListProperties),
        Symbol("XListExtensions",  cast(void**)& XListExtensions),
        Symbol("XGetFontPath",  cast(void**)& XGetFontPath),
        Symbol("XListFontsWithInfo",  cast(void**)& XListFontsWithInfo),
        Symbol("XListFonts",  cast(void**)& XListFonts),
        Symbol("XListInstalledColormaps",  cast(void**)& XListInstalledColormaps),
        Symbol("XCreateWindow",  cast(void**)& XCreateWindow),
        Symbol("XGetSelectionOwner",  cast(void**)& XGetSelectionOwner),
        Symbol("XCreateSimpleWindow",  cast(void**)& XCreateSimpleWindow),
        Symbol("XCreatePixmapFromBitmapData",  cast(void**)& XCreatePixmapFromBitmapData),
        Symbol("XCreateBitmapFromData",  cast(void**)& XCreateBitmapFromData),
        Symbol("XCreatePixmap",  cast(void**)& XCreatePixmap),
        Symbol("XFlushGC",  cast(void**)& XFlushGC),
        Symbol("XGContextFromGC",  cast(void**)& XGContextFromGC),
        Symbol("XCreateGC",  cast(void**)& XCreateGC),
        Symbol("XLoadFont",  cast(void**)& XLoadFont),
        Symbol("XCreateFontCursor",  cast(void**)& XCreateFontCursor),
        Symbol("XCreateGlyphCursor",  cast(void**)& XCreateGlyphCursor),
        Symbol("XCreatePixmapCursor",  cast(void**)& XCreatePixmapCursor),
        Symbol("XCreateColormap",  cast(void**)& XCreateColormap),
        Symbol("XCopyColormapAndFree",  cast(void**)& XCopyColormapAndFree),
        Symbol("XInternAtoms",  cast(void**)& XInternAtoms),
        Symbol("XInternAtom",  cast(void**)& XInternAtom),
        Symbol("XSetAfterFunction",  cast(void**)& XSetAfterFunction),
        Symbol("XSynchronize",  cast(void**)& XSynchronize),
        Symbol("XKeysymToString",  cast(void**)& XKeysymToString),
        Symbol("XDisplayName",  cast(void**)& XDisplayName),
        Symbol("XGetDefault",  cast(void**)& XGetDefault),
        Symbol("XGetAtomNames",  cast(void**)& XGetAtomNames),
        Symbol("XGetAtomName",  cast(void**)& XGetAtomName),
        Symbol("XFetchBuffer",  cast(void**)& XFetchBuffer),
        Symbol("XFetchBytes",  cast(void**)& XFetchBytes),
        Symbol("XrmInitialize",  cast(void**)& XrmInitialize),
        Symbol("XOpenDisplay",  cast(void**)& XOpenDisplay),
        Symbol("XGetSubImage",  cast(void**)& XGetSubImage),
        Symbol("XGetImage",  cast(void**)& XGetImage),
        Symbol("XInitImage",  cast(void**)& XInitImage),
        Symbol("XCreateImage",  cast(void**)& XCreateImage),
        Symbol("XNewModifiermap",  cast(void**)& XNewModifiermap),
        Symbol("XInsertModifiermapEntry",  cast(void**)& XInsertModifiermapEntry),
        Symbol("XGetModifierMapping",  cast(void**)& XGetModifierMapping),
        Symbol("XDeleteModifiermapEntry",  cast(void**)& XDeleteModifiermapEntry),
        Symbol("XGetMotionEvents",  cast(void**)& XGetMotionEvents),
        Symbol("XQueryFont",  cast(void**)& XQueryFont),
        Symbol("XLoadQueryFont",  cast(void**)& XLoadQueryFont),
        Symbol("_Xdebug",  cast(void**)& _Xdebug),
        Symbol("_Xmblen",  cast(void**)& _Xmblen)
    ];
}

} else { // version(DYNLINK)
extern(C) c_int _Xwctomb(char*, wchar);
extern(C) c_int _Xmbtowc(wchar*, char*, c_int);
extern(C) void XSetAuthorization(char*, c_int, char*, c_int);
extern(C) void XRemoveConnectionWatch(Display*, XConnectionWatchProc, XPointer);
extern(C) Status XAddConnectionWatch(Display*, XConnectionWatchProc, XPointer);
extern(C) void XProcessInternalConnection(Display*, c_int);
extern(C) Status XInternalConnectionNumbers(Display*, c_int**, c_int*);
extern(C) Bool XUnregisterIMInstantiateCallback(Display*, _XrmHashBucketRec*, char*, char*, XIDProc, XPointer);
extern(C) Bool XRegisterIMInstantiateCallback(Display*, _XrmHashBucketRec*, char*, char*, XIDProc, XPointer);
extern(C) XVaNestedList XVaCreateNestedList(c_int, ...);
extern(C) c_int Xutf8LookupString(XIC, XKeyPressedEvent*, char*, c_int, KeySym*, Status*);
extern(C) c_int XwcLookupString(XIC, XKeyPressedEvent*, wchar*, c_int, KeySym*, Status*);
extern(C) c_int XmbLookupString(XIC, XKeyPressedEvent*, char*, c_int, KeySym*, Status*);
extern(C) Bool XFilterEvent(XEvent*, Window);
extern(C) XIM XIMOfIC(XIC);
extern(C) char* XGetICValues(XIC, ...);
extern(C) char* XSetICValues(XIC, ...);
extern(C) char* Xutf8ResetIC(XIC);
extern(C) char* XmbResetIC(XIC);
extern(C) wchar* XwcResetIC(XIC);
extern(C) void XUnsetICFocus(XIC);
extern(C) void XSetICFocus(XIC);
extern(C) void XDestroyIC(XIC);
extern(C) XIC XCreateIC(XIM, ...);
extern(C) char* XLocaleOfIM(XIM);
extern(C) Display* XDisplayOfIM(XIM);
extern(C) char* XSetIMValues(XIM, ...);
extern(C) char* XGetIMValues(XIM, ...);
extern(C) Status XCloseIM(XIM);
extern(C) XIM XOpenIM(Display*, _XrmHashBucketRec*, char*, char*);
extern(C) void Xutf8DrawImageString(Display*, Drawable, XFontSet, GC, c_int, c_int, const char*, c_int);
extern(C) void XwcDrawImageString(Display*, Drawable, XFontSet, GC, c_int, c_int, const wchar*, c_int);
extern(C) void XmbDrawImageString(Display*, Drawable, XFontSet, GC, c_int, c_int, const char*, c_int);
extern(C) void Xutf8DrawString(Display*, Drawable, XFontSet, GC, c_int, c_int, const char*, c_int);
extern(C) void XwcDrawString(Display*, Drawable, XFontSet, GC, c_int, c_int, const wchar*, c_int);
extern(C) void XmbDrawString(Display*, Drawable, XFontSet, GC, c_int, c_int, const char*, c_int);
extern(C) void Xutf8DrawText(Display*, Drawable, GC, c_int, c_int, XmbTextItem*, c_int);
extern(C) void XwcDrawText(Display*, Drawable, GC, c_int, c_int, XwcTextItem*, c_int);
extern(C) void XmbDrawText(Display*, Drawable, GC, c_int, c_int, XmbTextItem*, c_int);
extern(C) Status Xutf8TextPerCharExtents(XFontSet, const char*, c_int, XRectangle*, XRectangle*, c_int, c_int*, XRectangle*, XRectangle*);
extern(C) Status XwcTextPerCharExtents(XFontSet, const wchar*, c_int, XRectangle*, XRectangle*, c_int, c_int*, XRectangle*, XRectangle*);
extern(C) Status XmbTextPerCharExtents(XFontSet, const char*, c_int, XRectangle*, XRectangle*, c_int, c_int*, XRectangle*, XRectangle*);
extern(C) c_int Xutf8TextExtents(XFontSet, const char*, c_int, XRectangle*, XRectangle*);
extern(C) c_int XwcTextExtents(XFontSet, const wchar*, c_int, XRectangle*, XRectangle*);
extern(C) c_int XmbTextExtents(XFontSet, const char*, c_int, XRectangle*, XRectangle*);
extern(C) c_int Xutf8TextEscapement(XFontSet, const char*, c_int);
extern(C) c_int XwcTextEscapement(XFontSet, const wchar*, c_int);
extern(C) c_int XmbTextEscapement(XFontSet, const char*, c_int);
extern(C) XFontSetExtents* XExtentsOfFontSet(XFontSet);
extern(C) Bool XContextualDrawing(XFontSet);
extern(C) Bool XDirectionalDependentDrawing(XFontSet);
extern(C) Bool XContextDependentDrawing(XFontSet);
extern(C) char* XLocaleOfFontSet(XFontSet);
extern(C) char* XBaseFontNameListOfFontSet(XFontSet);
extern(C) c_int XFontsOfFontSet(XFontSet, XFontStruct***, char***);
extern(C) void XFreeFontSet(Display*, XFontSet);
extern(C) XFontSet XCreateFontSet(Display*, const char*, char***, c_int*, char**);
extern(C) char* XGetOCValues(XOC, ...);
extern(C) char* XSetOCValues(XOC, ...);
extern(C) XOM XOMOfOC(XOC);
extern(C) void XDestroyOC(XOC);
extern(C) XOC XCreateOC(XOM, ...);
extern(C) char* XLocaleOfOM(XOM);
extern(C) Display* XDisplayOfOM(XOM);
extern(C) char* XGetOMValues(XOM, ...);
extern(C) char* XSetOMValues(XOM, ...);
extern(C) Status XCloseOM(XOM);
extern(C) XOM XOpenOM(Display*, _XrmHashBucketRec*, const char*, const char*);
extern(C) char* XSetLocaleModifiers(const char*);
extern(C) Bool XSupportsLocale();
extern(C) c_int XWriteBitmapFile(Display*, const char*, Pixmap, c_uint, c_uint, c_int, c_int);
extern(C) c_int XWindowEvent(Display*, Window, c_long, XEvent*);
extern(C) c_int XWidthOfScreen(Screen*);
extern(C) c_int XWidthMMOfScreen(Screen*);
extern(C) c_int XWarpPointer(Display*, Window, Window, c_int, c_int, c_uint, c_uint, c_int, c_int);
extern(C) c_int XVendorRelease(Display*);
extern(C) c_int XUnmapWindow(Display*, Window);
extern(C) c_int XUnmapSubwindows(Display*, Window);
extern(C) c_int XUnloadFont(Display*, Font);
extern(C) c_int XUninstallColormap(Display*, Colormap);
extern(C) c_int XUngrabServer(Display*);
extern(C) c_int XUngrabPointer(Display*, Time);
extern(C) c_int XUngrabKeyboard(Display*, Time);
extern(C) c_int XUngrabKey(Display*, c_int, c_uint, Window);
extern(C) c_int XUngrabButton(Display*, c_uint, c_uint, Window);
extern(C) c_int XUndefineCursor(Display*, Window);
extern(C) Bool XTranslateCoordinates(Display*, Window, Window, c_int, c_int, c_int*, c_int*, Window*);
extern(C) c_int XTextWidth16(XFontStruct*, const XChar2b*, c_int);
extern(C) c_int XTextWidth(XFontStruct*, const char*, c_int);
extern(C) c_int XTextExtents16(XFontStruct*, const XChar2b*, c_int, c_int*, c_int*, c_int*, XCharStruct*);
extern(C) c_int XTextExtents(XFontStruct*, const char*, c_int, c_int*, c_int*, c_int*, XCharStruct*);
extern(C) c_int XSync(Display*, Bool);
extern(C) c_int XStoreNamedColor(Display*, Colormap, const char*, c_ulong, c_int);
extern(C) c_int XStoreName(Display*, Window, const char*);
extern(C) c_int XStoreColors(Display*, Colormap, XColor*, c_int);
extern(C) c_int XStoreColor(Display*, Colormap, XColor*);
extern(C) c_int XStoreBytes(Display*, const char*, c_int);
extern(C) c_int XStoreBuffer(Display*, const char*, c_int, c_int);
extern(C) c_int XSetWindowColormap(Display*, Window, Colormap);
extern(C) c_int XSetWindowBorderWidth(Display*, Window, c_uint);
extern(C) c_int XSetWindowBorderPixmap(Display*, Window, Pixmap);
extern(C) c_int XSetWindowBorder(Display*, Window, c_ulong);
extern(C) c_int XSetWindowBackgroundPixmap(Display*, Window, Pixmap);
extern(C) c_int XSetWindowBackground(Display*, Window, c_ulong);
extern(C) c_int XSetTile(Display*, GC, Pixmap);
extern(C) c_int XSetTSOrigin(Display*, GC, c_int, c_int);
extern(C) c_int XSetSubwindowMode(Display*, GC, c_int);
extern(C) c_int XSetStipple(Display*, GC, Pixmap);
extern(C) c_int XSetState(Display*, GC, c_ulong, c_ulong, c_int, c_ulong);
extern(C) c_int XSetSelectionOwner(Display*, Atom, Window, Time);
extern(C) c_int XSetScreenSaver(Display*, c_int, c_int, c_int, c_int);
extern(C) c_int XSetPointerMapping(Display*, const char*, c_int);
extern(C) c_int XSetPlaneMask(Display*, GC, c_ulong);
extern(C) c_int XSetModifierMapping(Display*, XModifierKeymap*);
extern(C) c_int XSetLineAttributes(Display*, GC, c_uint, c_int, c_int, c_int);
extern(C) c_int XSetInputFocus(Display*, Window, c_int, Time);
extern(C) c_int XSetIconName(Display*, Window, const char*);
extern(C) c_int XSetGraphicsExposures(Display*, GC, Bool);
extern(C) c_int XSetFunction(Display*, GC, c_int);
extern(C) c_int XSetForeground(Display*, GC, c_ulong);
extern(C) c_int XSetFontPath(Display*, char**, c_int);
extern(C) c_int XSetFont(Display*, GC, Font);
extern(C) c_int XSetFillStyle(Display*, GC, c_int);
extern(C) c_int XSetFillRule(Display*, GC, c_int);
extern(C) c_int XSetDashes(Display*, GC, c_int, const char*, c_int);
extern(C) c_int XSetCommand(Display*, Window, char**, c_int);
extern(C) c_int XSetCloseDownMode(Display*, c_int);
extern(C) c_int XSetClipRectangles(Display*, GC, c_int, c_int, XRectangle*, c_int, c_int);
extern(C) c_int XSetClipOrigin(Display*, GC, c_int, c_int);
extern(C) c_int XSetClipMask(Display*, GC, Pixmap);
extern(C) c_int XSetBackground(Display*, GC, c_ulong);
extern(C) c_int XSetArcMode(Display*, GC, c_int);
extern(C) c_int XSetAccessControl(Display*, c_int);
extern(C) Status XSendEvent(Display*, Window, Bool, c_long, XEvent*);
extern(C) c_int XSelectInput(Display*, Window, c_long);
extern(C) c_int XScreenCount(Display*);
extern(C) c_int XRotateWindowProperties(Display*, Window, Atom*, c_int, c_int);
extern(C) c_int XRotateBuffers(Display*, c_int);
extern(C) c_int XRestackWindows(Display*, Window*, c_int);
extern(C) c_int XResizeWindow(Display*, Window, c_uint, c_uint);
extern(C) c_int XResetScreenSaver(Display*);
extern(C) c_int XReparentWindow(Display*, Window, Window, c_int, c_int);
extern(C) c_int XRemoveHosts(Display*, XHostAddress*, c_int);
extern(C) c_int XRemoveHost(Display*, XHostAddress*);
extern(C) c_int XRemoveFromSaveSet(Display*, Window);
extern(C) c_int XRefreshKeyboardMapping(XMappingEvent*);
extern(C) c_int XRecolorCursor(Display*, Cursor, XColor*, XColor*);
extern(C) c_int XRebindKeysym(Display*, KeySym, KeySym*, c_int, const char*, c_int);
extern(C) c_int XReadBitmapFileData(const char*, c_uint*, c_uint*, char**, c_int*, c_int*);
extern(C) c_int XReadBitmapFile(Display*, Drawable, const char*, c_uint*, c_uint*, Pixmap*, c_int*, c_int*);
extern(C) c_int XRaiseWindow(Display*, Window);
extern(C) Status XQueryTree(Display*, Window, Window*, Window*, Window**, c_uint*);
extern(C) c_int XQueryTextExtents16(Display*, XID, const XChar2b*, c_int, c_int*, c_int*, c_int*, XCharStruct*);
extern(C) c_int XQueryTextExtents(Display*, XID, const char*, c_int, c_int*, c_int*, c_int*, XCharStruct*);
extern(C) Bool XQueryPointer(Display*, Window, Window*, Window*, c_int*, c_int*, c_int*, c_int*, c_uint*);
extern(C) c_int XQueryKeymap(Display*, char [32]);
extern(C) Bool XQueryExtension(Display*, const char*, c_int*, c_int*, c_int*);
extern(C) c_int XQueryColors(Display*, Colormap, XColor*, c_int);
extern(C) c_int XQueryColor(Display*, Colormap, XColor*);
extern(C) Status XQueryBestTile(Display*, Drawable, c_uint, c_uint, c_uint*, c_uint*);
extern(C) Status XQueryBestStipple(Display*, Drawable, c_uint, c_uint, c_uint*, c_uint*);
extern(C) Status XQueryBestSize(Display*, c_int, Drawable, c_uint, c_uint, c_uint*, c_uint*);
extern(C) Status XQueryBestCursor(Display*, Drawable, c_uint, c_uint, c_uint*, c_uint*);
extern(C) c_int XQLength(Display*);
extern(C) c_int XPutImage(Display*, Drawable, GC, XImage*, c_int, c_int, c_int, c_int, c_uint, c_uint);
extern(C) c_int XPutBackEvent(Display*, XEvent*);
extern(C) c_int XProtocolVersion(Display*);
extern(C) c_int XProtocolRevision(Display*);
extern(C) c_int XPlanesOfScreen(Screen*);
extern(C) c_int XPending(Display*);
extern(C) c_int XPeekIfEvent(Display*, XEvent*, _BCD_func__1795, XPointer);
extern(C) c_int XPeekEvent(Display*, XEvent*);
extern(C) c_int XParseGeometry(const char*, c_int*, c_int*, c_uint*, c_uint*);
extern(C) Status XParseColor(Display*, Colormap, const char*, XColor*);
extern(C) c_int XNoOp(Display*);
extern(C) c_int XNextEvent(Display*, XEvent*);
extern(C) c_int XMoveWindow(Display*, Window, c_int, c_int);
extern(C) c_int XMoveResizeWindow(Display*, Window, c_int, c_int, c_uint, c_uint);
extern(C) c_int XMinCmapsOfScreen(Screen*);
extern(C) c_int XMaxCmapsOfScreen(Screen*);
extern(C) c_int XMaskEvent(Display*, c_long, XEvent*);
extern(C) c_int XMapWindow(Display*, Window);
extern(C) c_int XMapSubwindows(Display*, Window);
extern(C) c_int XMapRaised(Display*, Window);
extern(C) c_int XLowerWindow(Display*, Window);
extern(C) Status XLookupColor(Display*, Colormap, const char*, XColor*, XColor*);
extern(C) c_int XKillClient(Display*, XID);
extern(C) KeyCode XKeysymToKeycode(Display*, KeySym);
extern(C) c_int XInstallColormap(Display*, Colormap);
extern(C) c_int XImageByteOrder(Display*);
extern(C) c_int XIfEvent(Display*, XEvent*, _BCD_func__1795, XPointer);
extern(C) c_int XHeightOfScreen(Screen*);
extern(C) c_int XHeightMMOfScreen(Screen*);
extern(C) c_int XGrabServer(Display*);
extern(C) c_int XGrabPointer(Display*, Window, Bool, c_uint, c_int, c_int, Window, Cursor, Time);
extern(C) c_int XGrabKeyboard(Display*, Window, Bool, c_int, c_int, Time);
extern(C) c_int XGrabKey(Display*, c_int, c_uint, Window, Bool, c_int, c_int);
extern(C) c_int XGrabButton(Display*, c_uint, c_uint, Window, Bool, c_uint, c_int, c_int, Window, Cursor);
extern(C) Status XGetWindowAttributes(Display*, Window, XWindowAttributes*);
extern(C) c_int XGetWindowProperty(Display*, Window, Atom, c_long, c_long, Bool, Atom, Atom*, c_int*, c_ulong*, c_ulong*, char**);
extern(C) Status XGetTransientForHint(Display*, Window, Window*);
extern(C) c_int XGetScreenSaver(Display*, c_int*, c_int*, c_int*, c_int*);
extern(C) c_int XGetPointerMapping(Display*, char*, c_int);
extern(C) c_int XGetPointerControl(Display*, c_int*, c_int*, c_int*);
extern(C) c_int XGetKeyboardControl(Display*, XKeyboardState*);
extern(C) c_int XGetInputFocus(Display*, Window*, c_int*);
extern(C) Status XGetIconName(Display*, Window, char**);
extern(C) Status XGetGeometry(Display*, Drawable, Window*, c_int*, c_int*, c_uint*, c_uint*, c_uint*, c_uint*);
extern(C) Status XGetGCValues(Display*, GC, c_ulong, XGCValues*);
extern(C) Bool XGetFontProperty(XFontStruct*, Atom, c_ulong*);
extern(C) c_int XGetErrorText(Display*, c_int, char*, c_int);
extern(C) c_int XGetErrorDatabaseText(Display*, const char*, const char*, const char*, char*, c_int);
extern(C) c_int XGeometry(Display*, c_int, const char*, const char*, c_uint, c_uint, c_uint, c_int, c_int, c_int*, c_int*, c_int*, c_int*);
extern(C) c_int XFreePixmap(Display*, Pixmap);
extern(C) c_int XFreeModifiermap(XModifierKeymap*);
extern(C) c_int XFreeGC(Display*, GC);
extern(C) c_int XFreeFontPath(char**);
extern(C) c_int XFreeFontNames(char**);
extern(C) c_int XFreeFontInfo(char**, XFontStruct*, c_int);
extern(C) c_int XFreeFont(Display*, XFontStruct*);
extern(C) c_int XFreeExtensionList(char**);
extern(C) c_int XFreeCursor(Display*, Cursor);
extern(C) c_int XFreeColors(Display*, Colormap, c_ulong*, c_int, c_ulong);
extern(C) c_int XFreeColormap(Display*, Colormap);
extern(C) c_int XFree(void*);
extern(C) c_int XForceScreenSaver(Display*, c_int);
extern(C) c_int XFlush(Display*);
extern(C) c_int XFillRectangles(Display*, Drawable, GC, XRectangle*, c_int);
extern(C) c_int XFillRectangle(Display*, Drawable, GC, c_int, c_int, c_uint, c_uint);
extern(C) c_int XFillPolygon(Display*, Drawable, GC, XPoint*, c_int, c_int, c_int);
extern(C) c_int XFillArcs(Display*, Drawable, GC, XArc*, c_int);
extern(C) c_int XFillArc(Display*, Drawable, GC, c_int, c_int, c_uint, c_uint, c_int, c_int);
extern(C) Status XFetchName(Display*, Window, char**);
extern(C) c_int XEventsQueued(Display*, c_int);
extern(C) c_int XEnableAccessControl(Display*);
extern(C) c_int XDrawText16(Display*, Drawable, GC, c_int, c_int, XTextItem16*, c_int);
extern(C) c_int XDrawText(Display*, Drawable, GC, c_int, c_int, XTextItem*, c_int);
extern(C) c_int XDrawString16(Display*, Drawable, GC, c_int, c_int, const XChar2b*, c_int);
extern(C) c_int XDrawString(Display*, Drawable, GC, c_int, c_int, const char*, c_int);
extern(C) c_int XDrawSegments(Display*, Drawable, GC, XSegment*, c_int);
extern(C) c_int XDrawRectangles(Display*, Drawable, GC, XRectangle*, c_int);
extern(C) c_int XDrawRectangle(Display*, Drawable, GC, c_int, c_int, c_uint, c_uint);
extern(C) c_int XDrawPoints(Display*, Drawable, GC, XPoint*, c_int, c_int);
extern(C) c_int XDrawPoint(Display*, Drawable, GC, c_int, c_int);
extern(C) c_int XDrawLines(Display*, Drawable, GC, XPoint*, c_int, c_int);
extern(C) c_int XDrawLine(Display*, Drawable, GC, c_int, c_int, c_int, c_int);
extern(C) c_int XDrawImageString16(Display*, Drawable, GC, c_int, c_int, const XChar2b*, c_int);
extern(C) c_int XDrawImageString(Display*, Drawable, GC, c_int, c_int, const char*, c_int);
extern(C) c_int XDrawArcs(Display*, Drawable, GC, XArc*, c_int);
extern(C) c_int XDrawArc(Display*, Drawable, GC, c_int, c_int, c_uint, c_uint, c_int, c_int);
extern(C) c_int XDisplayWidthMM(Display*, c_int);
extern(C) c_int XDisplayWidth(Display*, c_int);
extern(C) c_int XDisplayPlanes(Display*, c_int);
extern(C) c_int XDisplayKeycodes(Display*, c_int*, c_int*);
extern(C) c_int XDisplayHeightMM(Display*, c_int);
extern(C) c_int XDisplayHeight(Display*, c_int);
extern(C) c_int XDisplayCells(Display*, c_int);
extern(C) c_int XDisableAccessControl(Display*);
extern(C) Bool XDoesSaveUnders(Screen*);
extern(C) c_int XDoesBackingStore(Screen*);
extern(C) c_int XDestroySubwindows(Display*, Window);
extern(C) c_int XDestroyWindow(Display*, Window);
extern(C) c_int XDeleteProperty(Display*, Window, Atom);
extern(C) c_int XDefineCursor(Display*, Window, Cursor);
extern(C) c_int XDefaultScreen(Display*);
extern(C) c_int XDefaultDepthOfScreen(Screen*);
extern(C) c_int XDefaultDepth(Display*, c_int);
extern(C) c_int XCopyPlane(Display*, Drawable, Drawable, GC, c_int, c_int, c_uint, c_uint, c_int, c_int, c_ulong);
extern(C) c_int XCopyGC(Display*, GC, c_ulong, GC);
extern(C) c_int XCopyArea(Display*, Drawable, Drawable, GC, c_int, c_int, c_uint, c_uint, c_int, c_int);
extern(C) c_int XConvertSelection(Display*, Atom, Atom, Atom, Window, Time);
extern(C) c_int XConnectionNumber(Display*);
extern(C) c_int XConfigureWindow(Display*, Window, c_uint, XWindowChanges*);
extern(C) c_int XCloseDisplay(Display*);
extern(C) c_int XClearWindow(Display*, Window);
extern(C) c_int XClearArea(Display*, Window, c_int, c_int, c_uint, c_uint, Bool);
extern(C) c_int XCirculateSubwindowsUp(Display*, Window);
extern(C) c_int XCirculateSubwindowsDown(Display*, Window);
extern(C) c_int XCirculateSubwindows(Display*, Window, c_int);
extern(C) Bool XCheckWindowEvent(Display*, Window, c_long, XEvent*);
extern(C) Bool XCheckTypedWindowEvent(Display*, Window, c_int, XEvent*);
extern(C) Bool XCheckTypedEvent(Display*, c_int, XEvent*);
extern(C) Bool XCheckMaskEvent(Display*, c_long, XEvent*);
extern(C) Bool XCheckIfEvent(Display*, XEvent*, _BCD_func__1795, XPointer);
extern(C) c_int XChangeWindowAttributes(Display*, Window, c_ulong, XSetWindowAttributes*);
extern(C) c_int XChangeSaveSet(Display*, Window, c_int);
extern(C) c_int XChangeProperty(Display*, Window, Atom, Atom, c_int, c_int, const char*, c_int);
extern(C) c_int XChangePointerControl(Display*, Bool, Bool, c_int, c_int, c_int);
extern(C) c_int XChangeKeyboardMapping(Display*, c_int, c_int, KeySym*, c_int);
extern(C) c_int XChangeKeyboardControl(Display*, c_ulong, XKeyboardControl*);
extern(C) c_int XChangeGC(Display*, GC, c_ulong, XGCValues*);
extern(C) c_int XChangeActivePointerGrab(Display*, c_uint, Cursor, Time);
extern(C) c_int XCellsOfScreen(Screen*);
extern(C) c_int XBitmapUnit(Display*);
extern(C) c_int XBitmapPad(Display*);
extern(C) c_int XBitmapBitOrder(Display*);
extern(C) c_int XBell(Display*, c_int);
extern(C) c_int XAutoRepeatOn(Display*);
extern(C) c_int XAutoRepeatOff(Display*);
extern(C) c_int XAllowEvents(Display*, c_int, Time);
extern(C) Status XAllocNamedColor(Display*, Colormap, const char*, XColor*, XColor*);
extern(C) Status XAllocColorPlanes(Display*, Colormap, Bool, c_ulong*, c_int, c_int, c_int, c_int, c_ulong*, c_ulong*, c_ulong*);
extern(C) Status XAllocColorCells(Display*, Colormap, Bool, c_long*, c_uint, c_long*, c_uint);
extern(C) Status XAllocColor(Display*, Colormap, XColor*);
extern(C) c_int XAddToSaveSet(Display*, Window);
extern(C) c_int XAddToExtensionList(_XExtData**, XExtData*);
extern(C) c_int XAddHosts(Display*, XHostAddress*, c_int);
extern(C) c_int XAddHost(Display*, XHostAddress*);
extern(C) c_int XActivateScreenSaver(Display*);
extern(C) c_int XSetTransientForHint(Display*, Window, Window);
extern(C) void XFreeStringList(char**);
extern(C) Status XSetWMColormapWindows(Display*, Window, Window*, c_int);
extern(C) Status XGetWMColormapWindows(Display*, Window, Window**, c_int*);
extern(C) Status XGetCommand(Display*, Window, char***, c_int*);
extern(C) Status XWithdrawWindow(Display*, Window, c_int);
extern(C) Status XIconifyWindow(Display*, Window, c_int);
extern(C) Status XSetWMProtocols(Display*, Window, Atom*, c_int);
extern(C) Status XGetWMProtocols(Display*, Window, Atom**, c_int*);
extern(C) Status XReconfigureWMWindow(Display*, Window, c_int, c_uint, XWindowChanges*);
extern(C) c_int* XListDepths(Display*, c_int, c_int*);
extern(C) XPixmapFormatValues* XListPixmapFormats(Display*, c_int*);
extern(C) XIOErrorHandler XSetIOErrorHandler(XIOErrorHandler);
extern(C) XErrorHandler XSetErrorHandler(XErrorHandler);
extern(C) c_int XScreenNumberOfScreen(Screen*);
extern(C) c_long XEventMaskOfScreen(Screen*);
extern(C) Screen* XDefaultScreenOfDisplay(Display*);
extern(C) Screen* XScreenOfDisplay(Display*, c_int);
extern(C) Display* XDisplayOfScreen(Screen*);
extern(C) Colormap XDefaultColormapOfScreen(Screen*);
extern(C) Colormap XDefaultColormap(Display*, c_int);
extern(C) char* XDisplayString(Display*);
extern(C) char* XServerVendor(Display*);
extern(C) c_ulong XLastKnownRequestProcessed(Display*);
extern(C) c_ulong XNextRequest(Display*);
extern(C) c_ulong XWhitePixelOfScreen(Screen*);
extern(C) c_ulong XBlackPixelOfScreen(Screen*);
extern(C) c_ulong XAllPlanes();
extern(C) c_ulong XWhitePixel(Display*, c_int);
extern(C) c_ulong XBlackPixel(Display*, c_int);
extern(C) GC XDefaultGCOfScreen(Screen*);
extern(C) GC XDefaultGC(Display*, c_int);
extern(C) Visual* XDefaultVisualOfScreen(Screen*);
extern(C) Visual* XDefaultVisual(Display*, c_int);
extern(C) Window XRootWindowOfScreen(Screen*);
extern(C) Window XDefaultRootWindow(Display*);
extern(C) Window XRootWindow(Display*, c_int);
extern(C) XExtData** XEHeadOfExtensionList(XEDataObject);
extern(C) XExtData* XFindOnExtensionList(XExtData**, c_int);
extern(C) XExtCodes* XAddExtension(Display*);
extern(C) XExtCodes* XInitExtension(Display*, const char*);
extern(C) void XUnlockDisplay(Display*);
extern(C) void XLockDisplay(Display*);
extern(C) Status XInitThreads();
extern(C) VisualID XVisualIDFromVisual(Visual*);
extern(C) c_ulong XDisplayMotionBufferSize(Display*);
extern(C) char* XScreenResourceString(Screen*);
extern(C) char* XResourceManagerString(Display*);
extern(C) c_int XExtendedMaxRequestSize(Display*);
extern(C) c_long XMaxRequestSize(Display*);
extern(C) KeySym XStringToKeysym(const char*);
extern(C) KeySym* XGetKeyboardMapping(Display*, KeyCode, c_int, c_int*);
extern(C) KeySym XLookupKeysym(XKeyEvent*, c_int);
extern(C) KeySym XKeycodeToKeysym(Display*, KeyCode, c_int);
extern(C) XHostAddress* XListHosts(Display*, c_int*, Bool*);
extern(C) Atom* XListProperties(Display*, Window, c_int*);
extern(C) char** XListExtensions(Display*, c_int*);
extern(C) char** XGetFontPath(Display*, c_int*);
extern(C) char** XListFontsWithInfo(Display*, const char*, c_int, c_int*, XFontStruct**);
extern(C) char** XListFonts(Display*, const char*, c_int, c_int*);
extern(C) Colormap* XListInstalledColormaps(Display*, Window, c_int*);
extern(C) Window XCreateWindow(Display*, Window, c_int, c_int, c_uint, c_uint, c_uint, c_int, c_uint, Visual*, c_ulong, XSetWindowAttributes*); 
extern(C) Window XGetSelectionOwner(Display*, Atom);
extern(C) Window XCreateSimpleWindow(Display*, Window, c_int, c_int, c_uint, c_uint, c_uint, c_ulong, c_ulong);
extern(C) Pixmap XCreatePixmapFromBitmapData(Display*, Drawable, char*, c_uint, c_uint, c_ulong, c_ulong, c_uint);
extern(C) Pixmap XCreateBitmapFromData(Display*, Drawable, const char*, c_uint, c_uint);
extern(C) Pixmap XCreatePixmap(Display*, Drawable, c_uint, c_uint, c_uint);
extern(C) void XFlushGC(Display*, GC);
extern(C) GContext XGContextFromGC(GC);
extern(C) GC XCreateGC(Display*, Drawable, c_ulong, XGCValues*);
extern(C) Font XLoadFont(Display*, const char*);
extern(C) Cursor XCreateFontCursor(Display*, c_uint);
extern(C) Cursor XCreateGlyphCursor(Display*, Font, Font, c_uint, c_uint, const XColor*, const XColor* );
extern(C) Cursor XCreatePixmapCursor(Display*, Pixmap, Pixmap, XColor*, XColor*, c_uint, c_uint);
extern(C) Colormap XCreateColormap(Display*, Window, Visual*, c_int);
extern(C) Colormap XCopyColormapAndFree(Display*, Colormap);
extern(C) Status XInternAtoms(Display*, char**, c_int, Bool, Atom*);
extern(C) Atom XInternAtom(Display*, const char*, Bool);
extern(C) _BCD_func__894 XSetAfterFunction(Display*, _BCD_func__894);
extern(C) _BCD_func__894 XSynchronize(Display*, Bool);
extern(C) char* XKeysymToString(KeySym);
extern(C) char* XDisplayName(const char*);
extern(C) char* XGetDefault(Display*, const char*, const char*);
extern(C) Status XGetAtomNames(Display*, Atom*, c_int, char**);
extern(C) char* XGetAtomName(Display*, Atom);
extern(C) char* XFetchBuffer(Display*, c_int*, c_int);
extern(C) char* XFetchBytes(Display*, c_int*);
extern(C) void XrmInitialize();
extern(C) Display* XOpenDisplay(const char*);
extern(C) XImage* XGetSubImage(Display*, Drawable, c_int, c_int, c_uint, c_uint, c_ulong, c_int, XImage*, c_int, c_int);
extern(C) XImage* XGetImage(Display*, Drawable, c_int, c_int, c_uint, c_uint, c_ulong, c_int);
extern(C) Status XInitImage(XImage*);
extern(C) XImage* XCreateImage(Display*, Visual*, c_uint, c_int, c_int, char*, c_uint, c_uint, c_int, c_int);
extern(C) XModifierKeymap* XNewModifiermap(c_int);
extern(C) XModifierKeymap* XInsertModifiermapEntry(XModifierKeymap*, KeyCode, c_int);
extern(C) XModifierKeymap* XGetModifierMapping(Display*);
extern(C) XModifierKeymap* XDeleteModifiermapEntry(XModifierKeymap*, KeyCode, c_int);
extern(C) XTimeCoord* XGetMotionEvents(Display*, Window, Time, Time, c_int*);
extern(C) XFontStruct* XQueryFont(Display*, XID);
extern(C) XFontStruct* XLoadQueryFont(Display*, const char*);
extern(C) extern c_int _Xdebug;
extern(C) c_int _Xmblen(char*, c_int);
} // version(DYNLINK)

