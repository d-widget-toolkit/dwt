/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.gdk;

import java.lang.all;
public import org.eclipse.swt.internal.c.pango;
public import org.eclipse.swt.internal.c.cairo;
public import org.eclipse.swt.internal.c.glib_object;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):

const gint GDK_CURRENT_TIME = 0;
const gint GDK_PARENT_RELATIVE = 1;
const gint GDK_PIXBUF_FEATURES_H = 1;
const String GDK_PIXBUF_VERSION = "2.12.0";
const gint GDK_MAX_TIMECOORD_AXES = 128;
alias _GdkWindowObjectClass GdkWindowObjectClass;
alias _GdkDrawableClass GdkDrawableClass;
alias _GdkWindowObject GdkWindowObject;
alias _GdkDrawable GdkDrawable;
alias _GdkColor GdkColor;
alias _GdkDrawable GdkPixmap;
alias void GdkRegion;
enum GdkWindowState {
GDK_WINDOW_STATE_WITHDRAWN=1,
GDK_WINDOW_STATE_ICONIFIED=2,
GDK_WINDOW_STATE_MAXIMIZED=4,
GDK_WINDOW_STATE_STICKY=8,
GDK_WINDOW_STATE_FULLSCREEN=16,
GDK_WINDOW_STATE_ABOVE=32,
GDK_WINDOW_STATE_BELOW=64,
}
enum GdkEventMask {
GDK_EXPOSURE_MASK=2,
GDK_POINTER_MOTION_MASK=4,
GDK_POINTER_MOTION_HINT_MASK=8,
GDK_BUTTON_MOTION_MASK=16,
GDK_BUTTON1_MOTION_MASK=32,
GDK_BUTTON2_MOTION_MASK=64,
GDK_BUTTON3_MOTION_MASK=128,
GDK_BUTTON_PRESS_MASK=256,
GDK_BUTTON_RELEASE_MASK=512,
GDK_KEY_PRESS_MASK=1024,
GDK_KEY_RELEASE_MASK=2048,
GDK_ENTER_NOTIFY_MASK=4096,
GDK_LEAVE_NOTIFY_MASK=8192,
GDK_FOCUS_CHANGE_MASK=16384,
GDK_STRUCTURE_MASK=32768,
GDK_PROPERTY_CHANGE_MASK=65536,
GDK_VISIBILITY_NOTIFY_MASK=131072,
GDK_PROXIMITY_IN_MASK=262144,
GDK_PROXIMITY_OUT_MASK=524288,
GDK_SUBSTRUCTURE_MASK=1048576,
GDK_SCROLL_MASK=2097152,
GDK_ALL_EVENTS_MASK=4194302,
}
enum GdkWindowEdge {
GDK_WINDOW_EDGE_NORTH_WEST=0,
GDK_WINDOW_EDGE_NORTH=1,
GDK_WINDOW_EDGE_NORTH_EAST=2,
GDK_WINDOW_EDGE_WEST=3,
GDK_WINDOW_EDGE_EAST=4,
GDK_WINDOW_EDGE_SOUTH_WEST=5,
GDK_WINDOW_EDGE_SOUTH=6,
GDK_WINDOW_EDGE_SOUTH_EAST=7,
}
enum GdkGravity {
GDK_GRAVITY_NORTH_WEST=1,
GDK_GRAVITY_NORTH=2,
GDK_GRAVITY_NORTH_EAST=3,
GDK_GRAVITY_WEST=4,
GDK_GRAVITY_CENTER=5,
GDK_GRAVITY_EAST=6,
GDK_GRAVITY_SOUTH_WEST=7,
GDK_GRAVITY_SOUTH=8,
GDK_GRAVITY_SOUTH_EAST=9,
GDK_GRAVITY_STATIC=10,
}
enum GdkWMFunction {
GDK_FUNC_ALL=1,
GDK_FUNC_RESIZE=2,
GDK_FUNC_MOVE=4,
GDK_FUNC_MINIMIZE=8,
GDK_FUNC_MAXIMIZE=16,
GDK_FUNC_CLOSE=32,
}
enum GdkWMDecoration {
GDK_DECOR_ALL=1,
GDK_DECOR_BORDER=2,
GDK_DECOR_RESIZEH=4,
GDK_DECOR_TITLE=8,
GDK_DECOR_MENU=16,
GDK_DECOR_MINIMIZE=32,
GDK_DECOR_MAXIMIZE=64,
}
enum GdkWindowTypeHint {
GDK_WINDOW_TYPE_HINT_NORMAL=0,
GDK_WINDOW_TYPE_HINT_DIALOG=1,
GDK_WINDOW_TYPE_HINT_MENU=2,
GDK_WINDOW_TYPE_HINT_TOOLBAR=3,
GDK_WINDOW_TYPE_HINT_SPLASHSCREEN=4,
GDK_WINDOW_TYPE_HINT_UTILITY=5,
GDK_WINDOW_TYPE_HINT_DOCK=6,
GDK_WINDOW_TYPE_HINT_DESKTOP=7,
GDK_WINDOW_TYPE_HINT_DROPDOWN_MENU=8,
GDK_WINDOW_TYPE_HINT_POPUP_MENU=9,
GDK_WINDOW_TYPE_HINT_TOOLTIP=10,
GDK_WINDOW_TYPE_HINT_NOTIFICATION=11,
GDK_WINDOW_TYPE_HINT_COMBO=12,
GDK_WINDOW_TYPE_HINT_DND=13,
}
enum GdkWindowHints {
GDK_HINT_POS=1,
GDK_HINT_MIN_SIZE=2,
GDK_HINT_MAX_SIZE=4,
GDK_HINT_BASE_SIZE=8,
GDK_HINT_ASPECT=16,
GDK_HINT_RESIZE_INC=32,
GDK_HINT_WIN_GRAVITY=64,
GDK_HINT_USER_POS=128,
GDK_HINT_USER_SIZE=256,
}
enum GdkWindowAttributesType {
GDK_WA_TITLE=2,
GDK_WA_X=4,
GDK_WA_Y=8,
GDK_WA_CURSOR=16,
GDK_WA_COLORMAP=32,
GDK_WA_VISUAL=64,
GDK_WA_WMCLASS=128,
GDK_WA_NOREDIR=256,
GDK_WA_TYPE_HINT=512,
}
enum GdkWindowType {
GDK_WINDOW_ROOT=0,
GDK_WINDOW_TOPLEVEL=1,
GDK_WINDOW_CHILD=2,
GDK_WINDOW_DIALOG=3,
GDK_WINDOW_TEMP=4,
GDK_WINDOW_FOREIGN=5,
}
enum GdkWindowClass {
GDK_INPUT_OUTPUT=0,
GDK_INPUT_ONLY=1,
}
alias _GdkPointerHooks GdkPointerHooks;
alias _GdkDrawable GdkWindow;
enum GdkModifierType {
GDK_SHIFT_MASK=1,
GDK_LOCK_MASK=2,
GDK_CONTROL_MASK=4,
GDK_MOD1_MASK=8,
GDK_MOD2_MASK=16,
GDK_MOD3_MASK=32,
GDK_MOD4_MASK=64,
GDK_MOD5_MASK=128,
GDK_BUTTON1_MASK=256,
GDK_BUTTON2_MASK=512,
GDK_BUTTON3_MASK=1024,
GDK_BUTTON4_MASK=2048,
GDK_BUTTON5_MASK=4096,
GDK_SUPER_MASK=67108864,
GDK_HYPER_MASK=134217728,
GDK_META_MASK=268435456,
GDK_RELEASE_MASK=1073741824,
GDK_MODIFIER_MASK=1543512063,
}
alias _GdkDrawable * function(_GdkDrawable *, gint *, gint *, gint *) _BCD_func__6478;
alias _GdkScreen GdkScreen;
alias _GdkDrawable * function(_GdkScreen *, gint *, gint *) _BCD_func__6479;
alias _GdkWindowAttr GdkWindowAttr;
alias _GdkVisual GdkVisual;
alias _GdkColormap GdkColormap;
alias _GdkCursor GdkCursor;
alias _GdkGeometry GdkGeometry;
enum GdkVisualType {
GDK_VISUAL_STATIC_GRAY=0,
GDK_VISUAL_GRAYSCALE=1,
GDK_VISUAL_STATIC_COLOR=2,
GDK_VISUAL_PSEUDO_COLOR=3,
GDK_VISUAL_TRUE_COLOR=4,
GDK_VISUAL_DIRECT_COLOR=5,
}
alias void GdkVisualClass;
alias void * GdkAtom;
alias void * GdkSelectionType;
alias void * GdkTarget;
alias void * GdkSelection;
alias _GdkScreenClass GdkScreenClass;
alias void function(_GdkScreen *) _BCD_func__6483;
alias _GdkSpan GdkSpan;
alias void function(_GdkSpan *, void *) _BCD_func__4157;
alias _BCD_func__4157 GdkSpanFunc;
enum GdkOverlapType {
GDK_OVERLAP_RECTANGLE_IN=0,
GDK_OVERLAP_RECTANGLE_OUT=1,
GDK_OVERLAP_RECTANGLE_PART=2,
}
enum GdkFillRule {
GDK_EVEN_ODD_RULE=0,
GDK_WINDING_RULE=1,
}
enum GdkPropMode {
GDK_PROP_MODE_REPLACE=0,
GDK_PROP_MODE_PREPEND=1,
GDK_PROP_MODE_APPEND=2,
}
alias _GdkPixmapObjectClass GdkPixmapObjectClass;
alias _GdkPixmapObject GdkPixmapObject;
alias _GdkPangoAttrEmbossColor GdkPangoAttrEmbossColor;
alias _GdkPangoAttrEmbossed GdkPangoAttrEmbossed;
alias _GdkPangoAttrStipple GdkPangoAttrStipple;
alias _GdkDrawable GdkBitmap;
alias void GdkPangoRendererPrivate;
alias _GdkPangoRendererClass GdkPangoRendererClass;
alias _GdkPangoRenderer GdkPangoRenderer;
alias _GdkDisplayManagerClass GdkDisplayManagerClass;
alias void GdkDisplayManager;
alias _GdkDisplay GdkDisplay;
alias void function(void *, _GdkDisplay *) _BCD_func__6492;
alias _GdkKeymapClass GdkKeymapClass;
alias _GdkKeymap GdkKeymap;
alias void function(_GdkKeymap *) _BCD_func__6494;
alias _GdkKeymapKey GdkKeymapKey;
alias _GdkImageClass GdkImageClass;
enum GdkImageType {
GDK_IMAGE_NORMAL=0,
GDK_IMAGE_SHARED=1,
GDK_IMAGE_FASTEST=2,
}
enum GdkFontType {
GDK_FONT_FONT=0,
GDK_FONT_FONTSET=1,
}
alias _GdkTrapezoid GdkTrapezoid;
alias _GdkGC GdkGC;
alias _GdkGCValues GdkGCValues;
enum GdkGCValuesMask {
GDK_GC_FOREGROUND=1,
GDK_GC_BACKGROUND=2,
GDK_GC_FONT=4,
GDK_GC_FUNCTION=8,
GDK_GC_FILL=16,
GDK_GC_TILE=32,
GDK_GC_STIPPLE=64,
GDK_GC_CLIP_MASK=128,
GDK_GC_SUBWINDOW=256,
GDK_GC_TS_X_ORIGIN=512,
GDK_GC_TS_Y_ORIGIN=1024,
GDK_GC_CLIP_X_ORIGIN=2048,
GDK_GC_CLIP_Y_ORIGIN=4096,
GDK_GC_EXPOSURES=8192,
GDK_GC_LINE_WIDTH=16384,
GDK_GC_LINE_STYLE=32768,
GDK_GC_CAP_STYLE=65536,
GDK_GC_JOIN_STYLE=131072,
}
alias _GdkGC * function(_GdkDrawable *, _GdkGCValues *, gint) _BCD_func__6500;
alias void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint) _BCD_func__6501;
alias void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, gint, gint) _BCD_func__6502;
alias _GdkPoint GdkPoint;
alias void function(_GdkDrawable *, _GdkGC *, gint, _GdkPoint *, gint) _BCD_func__6503;
alias _GdkFont GdkFont;
alias void function(_GdkDrawable *, _GdkFont *, _GdkGC *, gint, gint, char *, gint) _BCD_func__6504;
alias guint GdkWChar;
alias void function(_GdkDrawable *, _GdkFont *, _GdkGC *, gint, gint, guint *, gint) _BCD_func__6505;
alias void function(_GdkDrawable *, _GdkGC *, _GdkDrawable *, gint, gint, gint, gint, gint, gint) _BCD_func__6506;
alias void function(_GdkDrawable *, _GdkGC *, _GdkPoint *, gint) _BCD_func__6507;
alias _GdkSegment GdkSegment;
alias void function(_GdkDrawable *, _GdkGC *, _GdkSegment *, gint) _BCD_func__6508;
alias void function(_GdkDrawable *, _GdkGC *, void *, gint, gint, _PangoGlyphString *) _BCD_func__6509;
alias _GdkImage GdkImage;
alias void function(_GdkDrawable *, _GdkGC *, _GdkImage *, gint, gint, gint, gint, gint, gint) _BCD_func__6510;
alias gint function(_GdkDrawable *) _BCD_func__6511;
alias void function(_GdkDrawable *, gint *, gint *) _BCD_func__6512;
alias void function(_GdkDrawable *, _GdkColormap *) _BCD_func__6513;
alias _GdkColormap * function(_GdkDrawable *) _BCD_func__6514;
alias _GdkVisual * function(_GdkDrawable *) _BCD_func__6515;
alias _GdkScreen * function(_GdkDrawable *) _BCD_func__6516;
alias _GdkImage * function(_GdkDrawable *, gint, gint, gint, gint) _BCD_func__6517;
alias void * function(_GdkDrawable *) _BCD_func__6518;
alias _GdkDrawable * function(_GdkDrawable *, gint, gint, gint, gint, gint *, gint *) _BCD_func__6519;
alias void GdkPixbuf;
enum GdkRgbDither {
GDK_RGB_DITHER_NONE=0,
GDK_RGB_DITHER_NORMAL=1,
GDK_RGB_DITHER_MAX=2,
}
alias void function(_GdkDrawable *, _GdkGC *, void *, gint, gint, gint, gint, gint, gint, gint, gint, gint) _BCD_func__6520;
alias _GdkImage * function(_GdkDrawable *, _GdkImage *, gint, gint, gint, gint, gint, gint) _BCD_func__6521;
alias void function(_GdkDrawable *, _GdkGC *, _PangoMatrix *, void *, gint, gint, _PangoGlyphString *) _BCD_func__6522;
alias void function(_GdkDrawable *, _GdkGC *, _GdkTrapezoid *, gint) _BCD_func__6523;
alias void * function(_GdkDrawable *) _BCD_func__6524;
alias void function() _BCD_func__5298;
enum GdkSubwindowMode {
GDK_CLIP_BY_CHILDREN=0,
GDK_INCLUDE_INFERIORS=1,
}
enum GdkLineStyle {
GDK_LINE_SOLID=0,
GDK_LINE_ON_OFF_DASH=1,
GDK_LINE_DOUBLE_DASH=2,
}
enum GdkJoinStyle {
GDK_JOIN_MITER=0,
GDK_JOIN_ROUND=1,
GDK_JOIN_BEVEL=2,
}
enum GdkFunction {
GDK_COPY=0,
GDK_INVERT=1,
GDK_XOR=2,
GDK_CLEAR=3,
GDK_AND=4,
GDK_AND_REVERSE=5,
GDK_AND_INVERT=6,
GDK_NOOP=7,
GDK_OR=8,
GDK_EQUIV=9,
GDK_OR_REVERSE=10,
GDK_COPY_INVERT=11,
GDK_OR_INVERT=12,
GDK_NAND=13,
GDK_NOR=14,
GDK_SET=15,
}
enum GdkFill {
GDK_SOLID=0,
GDK_TILED=1,
GDK_STIPPLED=2,
GDK_OPAQUE_STIPPLED=3,
}
enum GdkCapStyle {
GDK_CAP_NOT_LAST=0,
GDK_CAP_BUTT=1,
GDK_CAP_ROUND=2,
GDK_CAP_PROJECTING=3,
}
alias _GdkGCClass GdkGCClass;
alias void function(_GdkGC *, _GdkGCValues *) _BCD_func__6526;
alias void function(_GdkGC *, _GdkGCValues *, gint) _BCD_func__6527;
alias void function(_GdkGC *, gint, char *, gint) _BCD_func__6528;
alias _GdkDisplayPointerHooks GdkDisplayPointerHooks;
alias void function(_GdkDisplay *, _GdkScreen * *, gint *, gint *, gint *) _BCD_func__6531;
alias _GdkDrawable * function(_GdkDisplay *, _GdkDrawable *, gint *, gint *, gint *) _BCD_func__6532;
alias _GdkDrawable * function(_GdkDisplay *, gint *, gint *) _BCD_func__6533;
alias _GdkDisplayClass GdkDisplayClass;
alias char * function(_GdkDisplay *) _BCD_func__6535;
alias gint function(_GdkDisplay *) _BCD_func__6536;
alias _GdkScreen * function(_GdkDisplay *, gint) _BCD_func__6537;
alias _GdkScreen * function(_GdkDisplay *) _BCD_func__6538;
alias void function(_GdkDisplay *, gint) _BCD_func__6539;
enum GdkOwnerChange {
GDK_OWNER_CHANGE_NEW_OWNER=0,
GDK_OWNER_CHANGE_DESTROY=1,
GDK_OWNER_CHANGE_CLOSE=2,
}
enum GdkSettingAction {
GDK_SETTING_ACTION_NEW=0,
GDK_SETTING_ACTION_CHANGED=1,
GDK_SETTING_ACTION_DELETED=2,
}
enum GdkPropertyState {
GDK_PROPERTY_NEW_VALUE=0,
GDK_PROPERTY_DELETE=1,
}
enum GdkCrossingMode {
GDK_CROSSING_NORMAL=0,
GDK_CROSSING_GRAB=1,
GDK_CROSSING_UNGRAB=2,
}
enum GdkNotifyType {
GDK_NOTIFY_ANCESTOR=0,
GDK_NOTIFY_VIRTUAL=1,
GDK_NOTIFY_INFERIOR=2,
GDK_NOTIFY_NONLINEAR=3,
GDK_NOTIFY_NONLINEAR_VIRTUAL=4,
GDK_NOTIFY_UNKNOWN=5,
}
enum GdkScrollDirection {
GDK_SCROLL_UP=0,
GDK_SCROLL_DOWN=1,
GDK_SCROLL_LEFT=2,
GDK_SCROLL_RIGHT=3,
}
enum GdkVisibilityState {
GDK_VISIBILITY_UNOBSCURED=0,
GDK_VISIBILITY_PARTIAL=1,
GDK_VISIBILITY_FULLY_OBSCURED=2,
}
enum GdkEventType {
GDK_NOTHING=-1,
GDK_DELETE=0,
GDK_DESTROY=1,
GDK_EXPOSE=2,
GDK_MOTION_NOTIFY=3,
GDK_BUTTON_PRESS=4,
GDK_2BUTTON_PRESS=5,
GDK_3BUTTON_PRESS=6,
GDK_BUTTON_RELEASE=7,
GDK_KEY_PRESS=8,
GDK_KEY_RELEASE=9,
GDK_ENTER_NOTIFY=10,
GDK_LEAVE_NOTIFY=11,
GDK_FOCUS_CHANGE=12,
GDK_CONFIGURE=13,
GDK_MAP=14,
GDK_UNMAP=15,
GDK_PROPERTY_NOTIFY=16,
GDK_SELECTION_CLEAR=17,
GDK_SELECTION_REQUEST=18,
GDK_SELECTION_NOTIFY=19,
GDK_PROXIMITY_IN=20,
GDK_PROXIMITY_OUT=21,
GDK_DRAG_ENTER=22,
GDK_DRAG_LEAVE=23,
GDK_DRAG_MOTION=24,
GDK_DRAG_STATUS=25,
GDK_DROP_START=26,
GDK_DROP_FINISHED=27,
GDK_CLIENT_EVENT=28,
GDK_VISIBILITY_NOTIFY=29,
GDK_NO_EXPOSE=30,
GDK_SCROLL=31,
GDK_WINDOW_STATE=32,
GDK_SETTING=33,
GDK_OWNER_CHANGE=34,
GDK_GRAB_BROKEN=35,
}
enum GdkFilterReturn {
GDK_FILTER_CONTINUE=0,
GDK_FILTER_TRANSLATE=1,
GDK_FILTER_REMOVE=2,
}
alias void GdkXEvent;
alias _GdkEvent GdkEvent;
alias gint function(void *, _GdkEvent *, void *) _BCD_func__4335;
alias _BCD_func__4335 GdkFilterFunc;
alias void function(_GdkEvent *, void *) _BCD_func__4336;
alias _BCD_func__4336 GdkEventFunc;
alias _GdkEventAny GdkEventAny;
alias _GdkEventExpose GdkEventExpose;
alias _GdkEventNoExpose GdkEventNoExpose;
alias _GdkEventVisibility GdkEventVisibility;
alias _GdkEventMotion GdkEventMotion;
alias _GdkEventButton GdkEventButton;
alias _GdkEventScroll GdkEventScroll;
alias _GdkEventKey GdkEventKey;
alias _GdkEventCrossing GdkEventCrossing;
alias _GdkEventFocus GdkEventFocus;
alias _GdkEventConfigure GdkEventConfigure;
alias _GdkEventProperty GdkEventProperty;
alias _GdkEventSelection GdkEventSelection;
alias _GdkEventOwnerChange GdkEventOwnerChange;
alias _GdkEventProximity GdkEventProximity;
alias _GdkEventClient GdkEventClient;
alias _GdkEventDND GdkEventDND;
alias _GdkEventWindowState GdkEventWindowState;
alias _GdkEventSetting GdkEventSetting;
alias _GdkEventGrabBroken GdkEventGrabBroken;
alias _GdkDragContext GdkDragContext;
alias _GdkDevice GdkDevice;
alias void* GdkNativeWindow;
alias _GdkRectangle GdkRectangle;
enum GdkAxisUse {
GDK_AXIS_IGNORE=0,
GDK_AXIS_X=1,
GDK_AXIS_Y=2,
GDK_AXIS_PRESSURE=3,
GDK_AXIS_XTILT=4,
GDK_AXIS_YTILT=5,
GDK_AXIS_WHEEL=6,
GDK_AXIS_LAST=7,
}
enum GdkInputMode {
GDK_MODE_DISABLED=0,
GDK_MODE_SCREEN=1,
GDK_MODE_WINDOW=2,
}
enum GdkInputSource {
GDK_SOURCE_MOUSE=0,
GDK_SOURCE_PEN=1,
GDK_SOURCE_ERASER=2,
GDK_SOURCE_CURSOR=3,
}
enum GdkExtensionMode {
GDK_EXTENSION_EVENTS_NONE=0,
GDK_EXTENSION_EVENTS_ALL=1,
GDK_EXTENSION_EVENTS_CURSOR=2,
}
alias _GdkTimeCoord GdkTimeCoord;
alias void GdkDeviceClass;
alias _GdkDeviceAxis GdkDeviceAxis;
alias _GdkDeviceKey GdkDeviceKey;
alias _GdkDragContextClass GdkDragContextClass;
enum GdkDragProtocol {
GDK_DRAG_PROTO_MOTIF=0,
GDK_DRAG_PROTO_XDND=1,
GDK_DRAG_PROTO_ROOTWIN=2,
GDK_DRAG_PROTO_NONE=3,
GDK_DRAG_PROTO_WIN32_DROPFILES=4,
GDK_DRAG_PROTO_OLE2=5,
GDK_DRAG_PROTO_LOCAL=6,
}
enum GdkDragAction {
GDK_ACTION_DEFAULT=1,
GDK_ACTION_COPY=2,
GDK_ACTION_MOVE=4,
GDK_ACTION_LINK=8,
GDK_ACTION_PRIVATE=16,
GDK_ACTION_ASK=32,
}
enum GdkCursorType {
GDK_X_CURSOR=0,
GDK_ARROW=2,
GDK_BASED_ARROW_DOWN=4,
GDK_BASED_ARROW_UP=6,
GDK_BOAT=8,
GDK_BOGOSITY=10,
GDK_BOTTOM_LEFT_CORNER=12,
GDK_BOTTOM_RIGHT_CORNER=14,
GDK_BOTTOM_SIDE=16,
GDK_BOTTOM_TEE=18,
GDK_BOX_SPIRAL=20,
GDK_CENTER_PTR=22,
GDK_CIRCLE=24,
GDK_CLOCK=26,
GDK_COFFEE_MUG=28,
GDK_CROSS=30,
GDK_CROSS_REVERSE=32,
GDK_CROSSHAIR=34,
GDK_DIAMOND_CROSS=36,
GDK_DOT=38,
GDK_DOTBOX=40,
GDK_DOUBLE_ARROW=42,
GDK_DRAFT_LARGE=44,
GDK_DRAFT_SMALL=46,
GDK_DRAPED_BOX=48,
GDK_EXCHANGE=50,
GDK_FLEUR=52,
GDK_GOBBLER=54,
GDK_GUMBY=56,
GDK_HAND1=58,
GDK_HAND2=60,
GDK_HEART=62,
GDK_ICON=64,
GDK_IRON_CROSS=66,
GDK_LEFT_PTR=68,
GDK_LEFT_SIDE=70,
GDK_LEFT_TEE=72,
GDK_LEFTBUTTON=74,
GDK_LL_ANGLE=76,
GDK_LR_ANGLE=78,
GDK_MAN=80,
GDK_MIDDLEBUTTON=82,
GDK_MOUSE=84,
GDK_PENCIL=86,
GDK_PIRATE=88,
GDK_PLUS=90,
GDK_QUESTION_ARROW=92,
GDK_RIGHT_PTR=94,
GDK_RIGHT_SIDE=96,
GDK_RIGHT_TEE=98,
GDK_RIGHTBUTTON=100,
GDK_RTL_LOGO=102,
GDK_SAILBOAT=104,
GDK_SB_DOWN_ARROW=106,
GDK_SB_H_DOUBLE_ARROW=108,
GDK_SB_LEFT_ARROW=110,
GDK_SB_RIGHT_ARROW=112,
GDK_SB_UP_ARROW=114,
GDK_SB_V_DOUBLE_ARROW=116,
GDK_SHUTTLE=118,
GDK_SIZING=120,
GDK_SPIDER=122,
GDK_SPRAYCAN=124,
GDK_STAR=126,
GDK_TARGET=128,
GDK_TCROSS=130,
GDK_TOP_LEFT_ARROW=132,
GDK_TOP_LEFT_CORNER=134,
GDK_TOP_RIGHT_CORNER=136,
GDK_TOP_SIDE=138,
GDK_TOP_TEE=140,
GDK_TREK=142,
GDK_UL_ANGLE=144,
GDK_UMBRELLA=146,
GDK_UR_ANGLE=148,
GDK_WATCH=150,
GDK_XTERM=152,
GDK_LAST_CURSOR=153,
GDK_CURSOR_IS_PIXMAP=-1,
}
alias _GdkPixbufLoaderClass GdkPixbufLoaderClass;
alias _GdkPixbufLoader GdkPixbufLoader;
alias void function(_GdkPixbufLoader *, gint, gint) _BCD_func__6572;
alias void function(_GdkPixbufLoader *) _BCD_func__6573;
alias void function(_GdkPixbufLoader *, gint, gint, gint, gint) _BCD_func__6574;
alias void GdkPixbufFormat;
alias void GdkPixbufSimpleAnimClass;
alias void GdkPixbufSimpleAnim;
alias void GdkPixbufAnimationIter;
alias void GdkPixbufAnimation;
enum GdkPixbufRotation {
GDK_PIXBUF_ROTATE_NONE=0,
GDK_PIXBUF_ROTATE_COUNTERCLOCKWISE=90,
GDK_PIXBUF_ROTATE_UPSIDEDOWN=180,
GDK_PIXBUF_ROTATE_CLOCKWISE=270,
}
enum GdkInterpType {
GDK_INTERP_NEAREST=0,
GDK_INTERP_TILES=1,
GDK_INTERP_BILINEAR=2,
GDK_INTERP_HYPER=3,
}
alias gint function(char *, gsize, _GError * *, void *) _BCD_func__4618;
alias _BCD_func__4618 GdkPixbufSaveFunc;
enum GdkPixbufError {
GDK_PIXBUF_ERROR_CORRUPT_IMAGE=0,
GDK_PIXBUF_ERROR_INSUFFICIENT_MEMORY=1,
GDK_PIXBUF_ERROR_BAD_OPTION=2,
GDK_PIXBUF_ERROR_UNKNOWN_TYPE=3,
GDK_PIXBUF_ERROR_UNSUPPORTED_OPERATION=4,
GDK_PIXBUF_ERROR_FAILED=5,
}
alias void function(char *, void *) _BCD_func__4621;
alias _BCD_func__4621 GdkPixbufDestroyNotify;
enum GdkColorspace {
GDK_COLORSPACE_RGB=0,
}
enum GdkPixbufAlphaMode {
GDK_PIXBUF_ALPHA_BILEVEL=0,
GDK_PIXBUF_ALPHA_FULL=1,
}
alias _GdkRgbCmap GdkRgbCmap;
alias _GdkColormapClass GdkColormapClass;
alias void function(void *) _BCD_func__4634;
alias _BCD_func__4634 GdkDestroyNotify;
enum GdkInputCondition {
GDK_INPUT_READ=1,
GDK_INPUT_WRITE=2,
GDK_INPUT_EXCEPTION=4,
}
alias void function(void *, gint, gint) _BCD_func__4635;
alias _BCD_func__4635 GdkInputFunction;
enum GdkGrabStatus {
GDK_GRAB_SUCCESS=0,
GDK_GRAB_ALREADY_GRABBED=1,
GDK_GRAB_INVALID_TIME=2,
GDK_GRAB_NOT_VIEWABLE=3,
GDK_GRAB_FROZEN=4,
}
enum GdkStatus {
GDK_OK=0,
GDK_ERROR=-1,
GDK_ERROR_PARAM=-2,
GDK_ERROR_FILE=-3,
GDK_ERROR_MEM=-4,
}
enum GdkByteOrder {
GDK_LSB_FIRST=0,
GDK_MSB_FIRST=1,
}
alias gint function(void *) _BCD_func__5647;
alias gint function(_GdkDrawable *, void *) _BCD_func__6008;
alias void function(void *, _PangoAttrShape *, gint, void *) _BCD_func__4593;
alias void function(void *) _BCD_func__4610;
alias char * function(void *) _BCD_func__4611;
alias gint function(void *) _BCD_func__1140;
alias gint function(void *, long *, gint) _BCD_func__1142;
alias gint function(void *, char *, guint) _BCD_func__1144;
alias gint function(void *, char *, guint) _BCD_func__1146;
alias gint function(void * *, char *) _BCD_func__4808;
alias gint function(char *, char * * *, guint *) _BCD_func__4809;
alias gint function(void *, char *, char *, char *, char *) _BCD_func__4810;
alias gint function(__gconv_step *, __gconv_step_data *, void *, char *, char * *, char *, char * *, guint *) _BCD_func__4811;
alias void function(__gconv_step *) _BCD_func__4812;
alias gint function(__gconv_step *) _BCD_func__4813;
alias guint function(__gconv_step *, char) _BCD_func__4814;
alias gint function(__gconv_step *, __gconv_step_data *, char * *, char *, char * *, guint *, gint, gint) _BCD_func__4815;
alias gint function(void *, void *, void *) _BCD_func__4965;
alias void * function(void *) _BCD_func__4989;
alias gint function(_PangoAttribute *, void *) _BCD_func__4990;
alias void function(void *, guint, guint, _GInterfaceInfo *) _BCD_func__5093;
alias void function(void *, guint, _GTypeInfo *, _GTypeValueTable *) _BCD_func__5094;
alias void function(void *) _BCD_func__5095;
alias void function(void *, _GObject *, gint) _BCD_func__5243;
alias void function(void *, _GObject *) _BCD_func__5247;
alias void function(_GObject *) _BCD_func__5248;
alias void function(_GObject *, guint, _GValue *, _GParamSpec *) _BCD_func__5249;
alias void function(_GObject *, guint, _GValue *, _GParamSpec *) _BCD_func__5250;
alias gint function(_GSignalInvocationHint *, _GValue *, _GValue *, void *) _BCD_func__5276;
alias gint function(_GSignalInvocationHint *, guint, _GValue *, void *) _BCD_func__5277;
alias void function(_GClosure *, _GValue *, guint, _GValue *, void *, void *) _BCD_func__5278;
alias void function(void *, _GClosure *) _BCD_func__5297;
alias void function(_GValue *, _GValue *) _BCD_func__5355;
alias void * function(void *) _BCD_func__5383;
alias void function(void *, void *) _BCD_func__5387;
alias gint function(void *, _GTypeClass *) _BCD_func__5388;
alias void function(_GTypeInstance *, void *) _BCD_func__5389;
alias gint function(void *, void *, void *) _BCD_func__5443;
alias gint function(void *, void *, void *) _BCD_func__5457;
alias void function(_GScanner *, char *, gint) _BCD_func__5460;
alias gint function(void *, _GString *, void *) _BCD_func__5532;
alias void function(void *, void *, void *, _GError * *) _BCD_func__5549;
alias gint function(void *, void *, void *, _GError * *) _BCD_func__5550;
alias gint function(char *, char *, void *, _GError * *) _BCD_func__5551;
alias void * function(void *, void *) _BCD_func__5562;
alias void function(_GNode *, void *) _BCD_func__5563;
alias gint function(_GNode *, void *) _BCD_func__5564;
alias void function(char *) _BCD_func__5572;
alias void function(char *, gint, char *, void *) _BCD_func__5574;
alias gint function(_GIOChannel *, gint, void *) _BCD_func__5589;
alias gint function(_GPollFD *, guint, gint) _BCD_func__5640;
alias void function(gint, gint, void *) _BCD_func__5646;
alias void function(_GHookList *, _GHook *) _BCD_func__5682;
alias gint function(_GHook *, void *) _BCD_func__5683;
alias void function(_GHook *, void *) _BCD_func__5684;
alias gint function(_GHook *, _GHook *) _BCD_func__5685;
alias void function(guint, void *, void *) _BCD_func__5719;
alias gint function(char *, char *, guint) _BCD_func__5722;
alias char * function(void *) _BCD_func__5723;
alias char * function(char *, void *) _BCD_func__5908;
alias void function(void *, void *, void *) _BCD_func__5909;
alias guint function(void *) _BCD_func__5910;
alias gint function(void *, void *) _BCD_func__5911;
alias gint function(void *, void *, void *) _BCD_func__5912;
alias gint function(void *, void *) _BCD_func__5913;
alias gint function(void *, char *, guint) _BCD_func__5985;
alias gint function(void *, char *, guint) _BCD_func__5986;
struct _GdkWindowObjectClass {
_GdkDrawableClass parent_class;
}
struct _GdkWindowObject {
_GdkDrawable parent_instance;
_GdkDrawable * impl;
_GdkWindowObject * parent;
void * user_data;
gint x;
gint y;
gint extension_events;
_GList * filters;
_GList * children;
_GdkColor bg_color;
_GdkDrawable * bg_pixmap;
_GSList * paint_stack;
void * update_area;
guint update_freeze_count;
char window_type;
char depth;
char resize_count;
gint state;
guint bitfield0;
// guint guffaw_gravity // bits 0 .. 1
// guint input_only // bits 1 .. 2
// guint modal_hint // bits 2 .. 3
// guint composited // bits 3 .. 4
// guint destroyed // bits 4 .. 6
// guint accept_focus // bits 6 .. 7
// guint focus_on_map // bits 7 .. 8
// guint shaped // bits 8 .. 9
gint event_mask;
guint update_and_descendants_freeze_count;
}
struct _GdkPointerHooks {
_BCD_func__6478 get_pointer;
_BCD_func__6479 window_at_pointer;
}
struct _GdkWindowAttr {
char * title;
gint event_mask;
gint x;
gint y;
gint width;
gint height;
gint wclass;
_GdkVisual * visual;
_GdkColormap * colormap;
gint window_type;
_GdkCursor * cursor;
char * wmclass_name;
char * wmclass_class;
gint override_redirect;
gint type_hint;
}
struct _GdkGeometry {
gint min_width;
gint min_height;
gint max_width;
gint max_height;
gint base_width;
gint base_height;
gint width_inc;
gint height_inc;
double min_aspect;
double max_aspect;
gint win_gravity;
}
struct _GdkScreenClass {
_GObjectClass parent_class;
_BCD_func__6483 size_changed;
_BCD_func__6483 composited_changed;
}
struct _GdkPixmapObjectClass {
_GdkDrawableClass parent_class;
}
struct _GdkPixmapObject {
_GdkDrawable parent_instance;
_GdkDrawable * impl;
gint depth;
}
struct _GdkPangoAttrEmbossColor {
_PangoAttribute attr;
_PangoColor color;
}
struct _GdkPangoAttrEmbossed {
_PangoAttribute attr;
gint embossed;
}
struct _GdkPangoAttrStipple {
_PangoAttribute attr;
_GdkDrawable * stipple;
}
struct _GdkPangoRendererClass {
_PangoRendererClass parent_class;
}
struct _GdkPangoRenderer {
_PangoRenderer parent_instance;
void * priv;
}
struct _GdkDisplayManagerClass {
_GObjectClass parent_class;
_BCD_func__6492 display_opened;
}
struct _GdkKeymapClass {
_GObjectClass parent_class;
_BCD_func__6494 direction_changed;
_BCD_func__6494 keys_changed;
}
struct _GdkKeymap {
_GObject parent_instance;
_GdkDisplay * display;
}
struct _GdkKeymapKey {
guint keycode;
gint group;
gint level;
}
struct _GdkImageClass {
_GObjectClass parent_class;
}
struct _GdkTrapezoid {
double y1;
double x11;
double x21;
double y2;
double x12;
double x22;
}
struct _GdkDrawableClass {
_GObjectClass parent_class;
_BCD_func__6500 create_gc;
_BCD_func__6501 draw_rectangle;
_BCD_func__6502 draw_arc;
_BCD_func__6503 draw_polygon;
_BCD_func__6504 draw_text;
_BCD_func__6505 draw_text_wc;
_BCD_func__6506 draw_drawable;
_BCD_func__6507 draw_points;
_BCD_func__6508 draw_segments;
_BCD_func__6507 draw_lines;
_BCD_func__6509 draw_glyphs;
_BCD_func__6510 draw_image;
_BCD_func__6511 get_depth;
_BCD_func__6512 get_size;
_BCD_func__6513 set_colormap;
_BCD_func__6514 get_colormap;
_BCD_func__6515 get_visual;
_BCD_func__6516 get_screen;
_BCD_func__6517 get_image;
_BCD_func__6518 get_clip_region;
_BCD_func__6518 get_visible_region;
_BCD_func__6519 get_composite_drawable;
_BCD_func__6520 draw_pixbuf;
_BCD_func__6521 _copy_to_image;
_BCD_func__6522 draw_glyphs_transformed;
_BCD_func__6523 draw_trapezoids;
_BCD_func__6524 ref_cairo_surface;
_BCD_func__5298 _gdk_reserved4;
_BCD_func__5298 _gdk_reserved5;
_BCD_func__5298 _gdk_reserved6;
_BCD_func__5298 _gdk_reserved7;
_BCD_func__5298 _gdk_reserved9;
_BCD_func__5298 _gdk_reserved10;
_BCD_func__5298 _gdk_reserved11;
_BCD_func__5298 _gdk_reserved12;
_BCD_func__5298 _gdk_reserved13;
_BCD_func__5298 _gdk_reserved14;
_BCD_func__5298 _gdk_reserved15;
_BCD_func__5298 _gdk_reserved16;
}
struct _GdkGCClass {
_GObjectClass parent_class;
_BCD_func__6526 get_values;
_BCD_func__6527 set_values;
_BCD_func__6528 set_dashes;
_BCD_func__5298 _gdk_reserved1;
_BCD_func__5298 _gdk_reserved2;
_BCD_func__5298 _gdk_reserved3;
_BCD_func__5298 _gdk_reserved4;
}
struct _GdkGCValues {
_GdkColor foreground;
_GdkColor background;
_GdkFont * font;
gint function_;
gint fill;
_GdkDrawable * tile;
_GdkDrawable * stipple;
_GdkDrawable * clip_mask;
gint subwindow_mode;
gint ts_x_origin;
gint ts_y_origin;
gint clip_x_origin;
gint clip_y_origin;
gint graphics_exposures;
gint line_width;
gint line_style;
gint cap_style;
gint join_style;
}
struct _GdkDisplayPointerHooks {
_BCD_func__6531 get_pointer;
_BCD_func__6532 window_get_pointer;
_BCD_func__6533 window_at_pointer;
}
struct _GdkDisplayClass {
_GObjectClass parent_class;
_BCD_func__6535 get_display_name;
_BCD_func__6536 get_n_screens;
_BCD_func__6537 get_screen;
_BCD_func__6538 get_default_screen;
_BCD_func__6539 closed;
}
union _GdkEvent {
gint type;
_GdkEventAny any;
_GdkEventExpose expose;
_GdkEventNoExpose no_expose;
_GdkEventVisibility visibility;
_GdkEventMotion motion;
_GdkEventButton button;
_GdkEventScroll scroll;
_GdkEventKey key;
_GdkEventCrossing crossing;
_GdkEventFocus focus_change;
_GdkEventConfigure configure;
_GdkEventProperty property;
_GdkEventSelection selection;
_GdkEventOwnerChange owner_change;
_GdkEventProximity proximity;
_GdkEventClient client;
_GdkEventDND dnd;
_GdkEventWindowState window_state;
_GdkEventSetting setting;
_GdkEventGrabBroken grab_broken;
}
struct _GdkEventGrabBroken {
gint type;
_GdkDrawable * window;
char send_event;
gint keyboard;
gint implicit;
_GdkDrawable * grab_window;
}
struct _GdkEventSetting {
gint type;
_GdkDrawable * window;
char send_event;
gint action;
char * name;
}
struct _GdkEventWindowState {
gint type;
_GdkDrawable * window;
char send_event;
gint changed_mask;
gint new_window_state;
}
struct _GdkEventDND {
gint type;
_GdkDrawable * window;
char send_event;
_GdkDragContext * context;
guint32 time;
short x_root;
short y_root;
}
union N15_GdkEventClient5__115E {
char [20] b;
short [10] s;
gint [5] l;
}
struct _GdkEventClient {
gint type;
_GdkDrawable * window;
char send_event;
void * message_type;
ushort data_format;
N15_GdkEventClient5__115E data;
}
struct _GdkEventProximity {
gint type;
_GdkDrawable * window;
char send_event;
guint32 time;
_GdkDevice * device;
}
struct _GdkEventOwnerChange {
gint type;
_GdkDrawable * window;
char send_event;
guint owner;
gint reason;
void * selection;
guint32 time;
guint32 selection_time;
}
struct _GdkEventSelection {
gint type;
_GdkDrawable * window;
char send_event;
void * selection;
void * target;
void * property;
guint32 time;
guint requestor;
}
struct _GdkEventProperty {
gint type;
_GdkDrawable * window;
char send_event;
void * atom;
guint32 time;
guint state;
}
struct _GdkEventConfigure {
gint type;
_GdkDrawable * window;
char send_event;
gint x;
gint y;
gint width;
gint height;
}
struct _GdkEventCrossing {
gint type;
_GdkDrawable * window;
char send_event;
_GdkDrawable * subwindow;
guint32 time;
double x;
double y;
double x_root;
double y_root;
gint mode;
gint detail;
gint focus;
guint state;
}
struct _GdkEventFocus {
gint type;
_GdkDrawable * window;
char send_event;
short in_;
}
struct _GdkEventKey {
gint type;
_GdkDrawable * window;
char send_event;
guint32 time;
guint state;
guint keyval;
gint length;
char * string;
ushort hardware_keycode;
char group;
ubyte bitfield0;
// guint is_modifier // bits 0 .. 1
}
struct _GdkEventScroll {
gint type;
_GdkDrawable * window;
char send_event;
guint32 time;
double x;
double y;
guint state;
gint direction;
_GdkDevice * device;
double x_root;
double y_root;
}
struct _GdkEventButton {
gint type;
_GdkDrawable * window;
char send_event;
guint32 time;
double x;
double y;
double * axes;
guint state;
guint button;
_GdkDevice * device;
double x_root;
double y_root;
}
struct _GdkEventMotion {
gint type;
_GdkDrawable * window;
char send_event;
guint32 time;
double x;
double y;
double * axes;
guint state;
short is_hint;
_GdkDevice * device;
double x_root;
double y_root;
}
struct _GdkEventVisibility {
gint type;
_GdkDrawable * window;
char send_event;
gint state;
}
struct _GdkEventNoExpose {
gint type;
_GdkDrawable * window;
char send_event;
}
struct _GdkEventExpose {
gint type;
_GdkDrawable * window;
char send_event;
_GdkRectangle area;
void * region;
gint count;
}
struct _GdkEventAny {
gint type;
_GdkDrawable * window;
char send_event;
}
struct _GdkTimeCoord {
guint32 time;
double [128] axes;
}
struct _GdkDevice {
_GObject parent_instance;
char * name;
gint source;
gint mode;
gint has_cursor;
gint num_axes;
_GdkDeviceAxis * axes;
gint num_keys;
_GdkDeviceKey * keys;
}
struct _GdkDeviceAxis {
gint use;
double min;
double max;
}
struct _GdkDeviceKey {
guint keyval;
gint modifiers;
}
struct _GdkDragContextClass {
_GObjectClass parent_class;
}
struct _GdkDragContext {
_GObject parent_instance;
gint protocol;
gint is_source;
_GdkDrawable * source_window;
_GdkDrawable * dest_window;
_GList * targets;
gint actions;
gint suggested_action;
gint action;
guint32 start_time;
void * windowing_data;
}
struct _GdkPixbufLoaderClass {
_GObjectClass parent_class;
_BCD_func__6572 size_prepared;
_BCD_func__6573 area_prepared;
_BCD_func__6574 area_updated;
_BCD_func__6573 closed;
}
struct _GdkPixbufLoader {
_GObject parent_instance;
void * priv;
}
struct _GdkRgbCmap {
guint [256] colors;
gint n_colors;
_GSList * info_list;
}
struct _GdkColormapClass {
_GObjectClass parent_class;
}
struct _GdkScreen {
_GObject parent_instance;
guint bitfield0;
// guint closed // bits 0 .. 1
_GdkGC * [32] normal_gcs;
_GdkGC * [32] exposure_gcs;
void * font_options;
double resolution;
}
struct _GdkDisplay {
_GObject parent_instance;
_GList * queued_events;
_GList * queued_tail;
guint32 [2] button_click_time;
_GdkDrawable * [2] button_window;
gint [2] button_number;
guint double_click_time;
_GdkDevice * core_pointer;
_GdkDisplayPointerHooks * pointer_hooks;
guint bitfield0;
// guint closed // bits 0 .. 1
guint double_click_distance;
gint [2] button_x;
gint [2] button_y;
}
struct _GdkDrawable {
_GObject parent_instance;
}
struct _GdkVisual {
_GObject parent_instance;
gint type;
gint depth;
gint byte_order;
gint colormap_size;
gint bits_per_rgb;
guint32 red_mask;
gint red_shift;
gint red_prec;
guint32 green_mask;
gint green_shift;
gint green_prec;
guint32 blue_mask;
gint blue_shift;
gint blue_prec;
}
struct _GdkImage {
_GObject parent_instance;
gint type;
_GdkVisual * visual;
gint byte_order;
gint width;
gint height;
ushort depth;
ushort bpp;
ushort bpl;
ushort bits_per_pixel;
void * mem;
_GdkColormap * colormap;
void * windowing_data;
}
struct _GdkGC {
_GObject parent_instance;
gint clip_x_origin;
gint clip_y_origin;
gint ts_x_origin;
gint ts_y_origin;
_GdkColormap * colormap;
}
struct _GdkFont {
gint type;
gint ascent;
gint descent;
}
struct _GdkCursor {
gint type;
guint ref_count;
}
struct _GdkColormap {
_GObject parent_instance;
gint size;
_GdkColor * colors;
_GdkVisual * visual;
void * windowing_data;
}
struct _GdkColor {
guint32 pixel;
ushort red;
ushort green;
ushort blue;
}
struct _GdkSpan {
gint x;
gint y;
gint width;
}
struct _GdkSegment {
gint x1;
gint y1;
gint x2;
gint y2;
}
struct _GdkRectangle {
gint x;
gint y;
gint width;
gint height;
}
struct _GdkPoint {
gint x;
gint y;
}
version(DYNLINK){
mixin(gshared!(
"extern (C) guint function(guint, _BCD_func__5647, void *)gdk_threads_add_timeout;
extern (C) guint function(gint, guint, _BCD_func__5647, void *, _BCD_func__4634)gdk_threads_add_timeout_full;
extern (C) guint function(_BCD_func__5647, void *)gdk_threads_add_idle;
extern (C) guint function(gint, _BCD_func__5647, void *, _BCD_func__4634)gdk_threads_add_idle_full;
extern (C) void function(_BCD_func__5298, _BCD_func__5298)gdk_threads_set_lock_functions;
extern (C) void function()gdk_threads_init;
extern (C) void function()gdk_threads_leave;
extern (C) void function()gdk_threads_enter;
extern (C) extern _BCD_func__5298* gdk_threads_unlock;
extern (C) extern _BCD_func__5298* gdk_threads_lock;
extern (C) extern void ** gdk_threads_mutex;
extern (C) void function(char *)gdk_notify_startup_complete_with_id;
extern (C) void function()gdk_notify_startup_complete;
extern (C) gint function(_GdkDisplay *, _GdkEvent *, guint)gdk_event_send_client_message_for_display;
extern (C) void function(_GdkEvent *)gdk_event_send_clientmessage_toall;
extern (C) gint function(_GdkEvent *, guint)gdk_event_send_client_message;
extern (C) gint function(guint *, char *, gint)gdk_mbstowcs;
extern (C) char * function(guint *)gdk_wcstombs;
extern (C) GType function()gdk_rectangle_get_type;
extern (C) void function(_GdkRectangle *, _GdkRectangle *, _GdkRectangle *)gdk_rectangle_union;
extern (C) gint function(_GdkRectangle *, _GdkRectangle *, _GdkRectangle *)gdk_rectangle_intersect;
extern (C) void function(guint)gdk_set_double_click_time;
extern (C) void function()gdk_flush;
extern (C) void function()gdk_beep;
extern (C) gint function()gdk_screen_height_mm;
extern (C) gint function()gdk_screen_width_mm;
extern (C) gint function()gdk_screen_height;
extern (C) gint function()gdk_screen_width;
extern (C) gint function()gdk_pointer_is_grabbed;
extern (C) void function(guint32)gdk_keyboard_ungrab;
extern (C) void function(guint32)gdk_pointer_ungrab;
extern (C) gint function(_GdkDisplay *, _GdkDrawable * *, gint *)gdk_keyboard_grab_info_libgtk_only;
extern (C) gint function(_GdkDisplay *, _GdkDrawable * *, gint *)gdk_pointer_grab_info_libgtk_only;
extern (C) gint function(_GdkDrawable *, gint, guint32)gdk_keyboard_grab;
extern (C) gint function(_GdkDrawable *, gint, gint, _GdkDrawable *, _GdkCursor *, guint32)gdk_pointer_grab;
extern (C) void function(gint)gdk_input_remove;
extern (C) gint function(gint, gint, _BCD_func__4635, void *)gdk_input_add;
extern (C) gint function(gint, gint, _BCD_func__4635, void *, _BCD_func__4634)gdk_input_add_full;
extern (C) char * function()gdk_get_display_arg_name;
extern (C) char * function()gdk_get_display;
extern (C) gint function()gdk_get_use_xshm;
extern (C) void function(gint)gdk_set_use_xshm;
extern (C) gint function()gdk_error_trap_pop;
extern (C) void function()gdk_error_trap_push;
extern (C) void function(char *)gdk_set_program_class;
extern (C) char * function()gdk_get_program_class;
extern (C) char * function()gdk_set_locale;
extern (C) void function(gint)gdk_exit;
extern (C) void function()gdk_pre_parse_libgtk_only;
extern (C) void function(void *)gdk_add_option_entries_libgtk_only;
extern (C) gint function(gint *, char * * *)gdk_init_check;
extern (C) void function(gint *, char * * *)gdk_init;
extern (C) void function(gint *, char * * *)gdk_parse_args;
extern (C) _GdkDrawable * function()gdk_get_default_root_window;
extern (C) _GdkPointerHooks * function(_GdkPointerHooks *)gdk_set_pointer_hooks;
extern (C) void function(_GdkDrawable *)gdk_window_configure_finished;
extern (C) void function(_GdkDrawable *)gdk_window_enable_synchronized_configure;
extern (C) void function(_GdkDrawable *, _GdkDrawable * *, gint *, gint *)gdk_window_get_internal_paint_info;
extern (C) void function(_GdkGeometry *, guint, gint, gint, gint *, gint *)gdk_window_constrain_size;
extern (C) void function(gint)gdk_window_set_debug_updates;
extern (C) void function(_GdkDrawable *, gint)gdk_window_process_updates;
extern (C) void function()gdk_window_process_all_updates;
extern (C) void function(_GdkDrawable *)gdk_window_thaw_toplevel_updates_libgtk_only;
extern (C) void function(_GdkDrawable *)gdk_window_freeze_toplevel_updates_libgtk_only;
extern (C) void function(_GdkDrawable *)gdk_window_thaw_updates;
extern (C) void function(_GdkDrawable *)gdk_window_freeze_updates;
extern (C) void * function(_GdkDrawable *)gdk_window_get_update_area;
extern (C) void function(_GdkDrawable *, void *, _BCD_func__6008, void *)gdk_window_invalidate_maybe_recurse;
extern (C) void function(_GdkDrawable *, void *, gint)gdk_window_invalidate_region;
extern (C) void function(_GdkDrawable *, _GdkRectangle *, gint)gdk_window_invalidate_rect;
extern (C) void function(_GdkDrawable *, gint, gint, gint, guint32)gdk_window_begin_move_drag;
extern (C) void function(_GdkDrawable *, gint, gint, gint, gint, guint32)gdk_window_begin_resize_drag;
extern (C) void function(_GdkDrawable *)gdk_window_register_dnd;
extern (C) void function(_GdkDrawable *, double)gdk_window_set_opacity;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_keep_below;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_keep_above;
extern (C) void function(_GdkDrawable *)gdk_window_unfullscreen;
extern (C) void function(_GdkDrawable *)gdk_window_fullscreen;
extern (C) void function(_GdkDrawable *)gdk_window_unmaximize;
extern (C) void function(_GdkDrawable *)gdk_window_maximize;
extern (C) void function(_GdkDrawable *)gdk_window_unstick;
extern (C) void function(_GdkDrawable *)gdk_window_stick;
extern (C) void function(_GdkDrawable *)gdk_window_deiconify;
extern (C) void function(_GdkDrawable *)gdk_window_iconify;
extern (C) void function(_GdkDrawable *)gdk_window_beep;
extern (C) _GList * function()gdk_window_get_toplevels;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_functions;
extern (C) gint function(_GdkDrawable *, gint *)gdk_window_get_decorations;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_decorations;
extern (C) _GdkDrawable * function(_GdkDrawable *)gdk_window_get_group;
extern (C) void function(_GdkDrawable *, _GdkDrawable *)gdk_window_set_group;
extern (C) void function(_GdkDrawable *, char *)gdk_window_set_icon_name;
extern (C) void function(_GdkDrawable *, _GdkDrawable *, _GdkDrawable *, _GdkDrawable *)gdk_window_set_icon;
extern (C) void function(_GdkDrawable *, _GList *)gdk_window_set_icon_list;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_events;
extern (C) gint function(_GdkDrawable *)gdk_window_get_events;
extern (C) _GList * function(_GdkDrawable *)gdk_window_peek_children;
extern (C) _GList * function(_GdkDrawable *)gdk_window_get_children;
extern (C) _GdkDrawable * function(_GdkDrawable *)gdk_window_get_toplevel;
extern (C) _GdkDrawable * function(_GdkDrawable *)gdk_window_get_parent;
extern (C) _GdkDrawable * function(_GdkDrawable *, gint *, gint *, gint *)gdk_window_get_pointer;
extern (C) void function(_GdkDrawable *, _GdkRectangle *)gdk_window_get_frame_extents;
extern (C) void function(_GdkDrawable *, gint *, gint *)gdk_window_get_root_origin;
extern (C) gint function(_GdkDrawable *, gint *, gint *)gdk_window_get_deskrelative_origin;
extern (C) gint function(_GdkDrawable *, gint *, gint *)gdk_window_get_origin;
extern (C) void function(_GdkDrawable *, gint *, gint *)gdk_window_get_position;
extern (C) void function(_GdkDrawable *, gint *, gint *, gint *, gint *, gint *)gdk_window_get_geometry;
extern (C) void function(_GdkDrawable *, void * *)gdk_window_get_user_data;
extern (C) void function(_GdkDrawable *, _GdkCursor *)gdk_window_set_cursor;
extern (C) void function(_GdkDrawable *, _GdkDrawable *, gint)gdk_window_set_back_pixmap;
extern (C) void function(_GdkDrawable *, _GdkColor *)gdk_window_set_background;
extern (C) void function(_GdkDrawable *, _GdkDrawable *)gdk_window_set_transient_for;
extern (C) void function(_GdkDrawable *, char *)gdk_window_set_startup_id;
extern (C) void function(_GdkDrawable *, char *)gdk_window_set_role;
extern (C) void function(_GdkDrawable *, char *)gdk_window_set_title;
extern (C) void function(_GdkDrawable *)gdk_window_end_paint;
extern (C) void function(_GdkDrawable *, void *)gdk_window_begin_paint_region;
extern (C) void function(_GdkDrawable *, _GdkRectangle *)gdk_window_begin_paint_rect;
extern (C) void function(char *)gdk_set_sm_client_id;
extern (C) void function(_GdkDrawable *, _GdkGeometry *, gint)gdk_window_set_geometry_hints;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_urgency_hint;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_skip_pager_hint;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_skip_taskbar_hint;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_modal_hint;
extern (C) gint function(_GdkDrawable *)gdk_window_get_type_hint;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_type_hint;
extern (C) void function(_GdkDrawable *, gint, gint, gint, gint, gint, gint, gint)gdk_window_set_hints;
extern (C) _GdkDrawable * function(_GdkDisplay *, guint)gdk_window_lookup_for_display;
extern (C) _GdkDrawable * function(_GdkDisplay *, guint)gdk_window_foreign_new_for_display;
extern (C) _GdkDrawable * function(GdkNativeWindow)gdk_window_lookup;
extern (C) _GdkDrawable * function(guint)gdk_window_foreign_new;
extern (C) gint function(_GdkDrawable *, gint)gdk_window_set_static_gravities;
extern (C) gint function(_GdkDrawable *)gdk_window_get_state;
extern (C) gint function(_GdkDrawable *)gdk_window_is_viewable;
extern (C) gint function(_GdkDrawable *)gdk_window_is_visible;
extern (C) void function(_GdkDrawable *)gdk_window_merge_child_input_shapes;
extern (C) void function(_GdkDrawable *)gdk_window_set_child_input_shapes;
extern (C) void function(_GdkDrawable *, void *, gint, gint)gdk_window_input_shape_combine_region;
extern (C) void function(_GdkDrawable *, _GdkDrawable *, gint, gint)gdk_window_input_shape_combine_mask;
extern (C) void function(_GdkDrawable *)gdk_window_merge_child_shapes;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_composited;
extern (C) void function(_GdkDrawable *)gdk_window_set_child_shapes;
extern (C) void function(_GdkDrawable *, void *, gint, gint)gdk_window_shape_combine_region;
extern (C) void function(_GdkDrawable *, _GdkDrawable *, gint, gint)gdk_window_shape_combine_mask;
extern (C) void function(_GdkDrawable *, void *, gint, gint)gdk_window_move_region;
extern (C) void function(_GdkDrawable *, gint, gint)gdk_window_scroll;
extern (C) void function(_GdkDrawable *, _BCD_func__4335, void *)gdk_window_remove_filter;
extern (C) void function(_GdkDrawable *, _BCD_func__4335, void *)gdk_window_add_filter;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_focus_on_map;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_accept_focus;
extern (C) void function(_GdkDrawable *, gint)gdk_window_set_override_redirect;
extern (C) void function(_GdkDrawable *, void *)gdk_window_set_user_data;
extern (C) void function(_GdkDrawable *, guint32)gdk_window_focus;
extern (C) void function(_GdkDrawable *)gdk_window_lower;
extern (C) void function(_GdkDrawable *)gdk_window_raise;
extern (C) void function(_GdkDrawable *, gint, gint, gint, gint)gdk_window_clear_area_e;
extern (C) void function(_GdkDrawable *, gint, gint, gint, gint)gdk_window_clear_area;
extern (C) void function(_GdkDrawable *)gdk_window_clear;
extern (C) void function(_GdkDrawable *, _GdkDrawable *, gint, gint)gdk_window_reparent;
extern (C) void function(_GdkDrawable *, gint, gint, gint, gint)gdk_window_move_resize;
extern (C) void function(_GdkDrawable *, gint, gint)gdk_window_resize;
extern (C) void function(_GdkDrawable *, gint, gint)gdk_window_move;
extern (C) void function(_GdkDrawable *)gdk_window_show_unraised;
extern (C) void function(_GdkDrawable *)gdk_window_withdraw;
extern (C) void function(_GdkDrawable *)gdk_window_hide;
extern (C) void function(_GdkDrawable *)gdk_window_show;
extern (C) _GdkDrawable * function(gint *, gint *)gdk_window_at_pointer;
extern (C) gint function(_GdkDrawable *)gdk_window_get_window_type;
extern (C) void function(_GdkDrawable *)gdk_window_destroy;
extern (C) _GdkDrawable * function(_GdkDrawable *, _GdkWindowAttr *, gint)gdk_window_new;
extern (C) guint function()gdk_window_object_get_type;
extern (C) _GdkScreen * function(_GdkVisual *)gdk_visual_get_screen;
extern (C) _GList * function()gdk_list_visuals;
extern (C) void function(gint * *, gint *)gdk_query_visual_types;
extern (C) void function(gint * *, gint *)gdk_query_depths;
extern (C) _GdkVisual * function(gint, gint)gdk_visual_get_best_with_both;
extern (C) _GdkVisual * function(gint)gdk_visual_get_best_with_type;
extern (C) _GdkVisual * function(gint)gdk_visual_get_best_with_depth;
extern (C) _GdkVisual * function()gdk_visual_get_best;
extern (C) _GdkVisual * function()gdk_visual_get_system;
extern (C) gint function()gdk_visual_get_best_type;
extern (C) gint function()gdk_visual_get_best_depth;
extern (C) GType function()gdk_visual_get_type;
extern (C) gint function(_GdkScreen *, char *, _GError * *)gdk_spawn_command_line_on_screen;
extern (C) gint function(_GdkScreen *, char *, char * *, char * *, gint, _BCD_func__4634, void *, gint *, gint *, gint *, gint *, _GError * *)gdk_spawn_on_screen_with_pipes;
extern (C) gint function(_GdkScreen *, char *, char * *, char * *, gint, _BCD_func__4634, void *, gint *, _GError * *)gdk_spawn_on_screen;
extern (C) void function(_GdkDisplay *, guint, void *, void *, void *, guint32)gdk_selection_send_notify_for_display;
extern (C) void function(guint, void *, void *, void *, guint32)gdk_selection_send_notify;
extern (C) gint function(_GdkDrawable *, char * *, void * *, gint *)gdk_selection_property_get;
extern (C) void function(_GdkDrawable *, void *, void *, guint32)gdk_selection_convert;
extern (C) _GdkDrawable * function(_GdkDisplay *, void *)gdk_selection_owner_get_for_display;
extern (C) gint function(_GdkDisplay *, _GdkDrawable *, void *, guint32, gint)gdk_selection_owner_set_for_display;
extern (C) _GdkDrawable * function(void *)gdk_selection_owner_get;
extern (C) gint function(_GdkDrawable *, void *, guint32, gint)gdk_selection_owner_set;
extern (C) _GList * function(_GdkScreen *)gdk_screen_get_window_stack;
extern (C) _GdkDrawable * function(_GdkScreen *)gdk_screen_get_active_window;
extern (C) double function(_GdkScreen *)gdk_screen_get_resolution;
extern (C) void function(_GdkScreen *, double)gdk_screen_set_resolution;
extern (C) void * function(_GdkScreen *)gdk_screen_get_font_options;
extern (C) void function(_GdkScreen *, void *)gdk_screen_set_font_options;
extern (C) gint function(_GdkScreen *, char *, _GValue *)gdk_screen_get_setting;
extern (C) _GdkScreen * function()gdk_screen_get_default;
extern (C) void function(_GdkScreen *, _GdkEvent *)gdk_screen_broadcast_client_message;
extern (C) gint function(_GdkScreen *, _GdkDrawable *)gdk_screen_get_monitor_at_window;
extern (C) gint function(_GdkScreen *, gint, gint)gdk_screen_get_monitor_at_point;
extern (C) void function(_GdkScreen *, gint, _GdkRectangle *)gdk_screen_get_monitor_geometry;
extern (C) gint function(_GdkScreen *)gdk_screen_get_n_monitors;
extern (C) char * function(_GdkScreen *)gdk_screen_make_display_name;
extern (C) _GList * function(_GdkScreen *)gdk_screen_get_toplevel_windows;
extern (C) _GList * function(_GdkScreen *)gdk_screen_list_visuals;
extern (C) gint function(_GdkScreen *)gdk_screen_get_height_mm;
extern (C) gint function(_GdkScreen *)gdk_screen_get_width_mm;
extern (C) gint function(_GdkScreen *)gdk_screen_get_height;
extern (C) gint function(_GdkScreen *)gdk_screen_get_width;
extern (C) gint function(_GdkScreen *)gdk_screen_get_number;
extern (C) _GdkDisplay * function(_GdkScreen *)gdk_screen_get_display;
extern (C) _GdkDrawable * function(_GdkScreen *)gdk_screen_get_root_window;
extern (C) gint function(_GdkScreen *)gdk_screen_is_composited;
extern (C) _GdkVisual * function(_GdkScreen *)gdk_screen_get_rgba_visual;
extern (C) _GdkColormap * function(_GdkScreen *)gdk_screen_get_rgba_colormap;
extern (C) _GdkVisual * function(_GdkScreen *)gdk_screen_get_rgb_visual;
extern (C) _GdkColormap * function(_GdkScreen *)gdk_screen_get_rgb_colormap;
extern (C) _GdkVisual * function(_GdkScreen *)gdk_screen_get_system_visual;
extern (C) _GdkColormap * function(_GdkScreen *)gdk_screen_get_system_colormap;
extern (C) void function(_GdkScreen *, _GdkColormap *)gdk_screen_set_default_colormap;
extern (C) _GdkColormap * function(_GdkScreen *)gdk_screen_get_default_colormap;
extern (C) GType function()gdk_screen_get_type;
extern (C) void function(void *, _GdkSpan *, gint, gint, _BCD_func__4157, void *)gdk_region_spans_intersect_foreach;
extern (C) void function(void *, void *)gdk_region_xor;
extern (C) void function(void *, void *)gdk_region_subtract;
extern (C) void function(void *, void *)gdk_region_union;
extern (C) void function(void *, void *)gdk_region_intersect;
extern (C) void function(void *, _GdkRectangle *)gdk_region_union_with_rect;
extern (C) void function(void *, gint, gint)gdk_region_shrink;
extern (C) void function(void *, gint, gint)gdk_region_offset;
extern (C) gint function(void *, _GdkRectangle *)gdk_region_rect_in;
extern (C) gint function(void *, gint, gint)gdk_region_point_in;
extern (C) gint function(void *, void *)gdk_region_equal;
extern (C) gint function(void *)gdk_region_empty;
extern (C) void function(void *, _GdkRectangle * *, gint *)gdk_region_get_rectangles;
extern (C) void function(void *, _GdkRectangle *)gdk_region_get_clipbox;
extern (C) void function(void *)gdk_region_destroy;
extern (C) void * function(_GdkRectangle *)gdk_region_rectangle;
extern (C) void * function(void *)gdk_region_copy;
extern (C) void * function(_GdkPoint *, gint, gint)gdk_region_polygon;
extern (C) void * function()gdk_region_new;
extern (C) void function(char *)gdk_free_compound_text;
extern (C) void function(char * *)gdk_free_text_list;
extern (C) gint function(_GdkDisplay *, char *, void * *, gint *, char * *, gint *)gdk_utf8_to_compound_text_for_display;
extern (C) gint function(_GdkDisplay *, char *, void * *, gint *, char * *, gint *)gdk_string_to_compound_text_for_display;
extern (C) char * function(char *)gdk_utf8_to_string_target;
extern (C) gint function(_GdkDisplay *, void *, gint, char *, gint, char * * *)gdk_text_property_to_utf8_list_for_display;
extern (C) gint function(_GdkDisplay *, void *, gint, char *, gint, char * * *)gdk_text_property_to_text_list_for_display;
extern (C) gint function(char *, void * *, gint *, char * *, gint *)gdk_string_to_compound_text;
extern (C) gint function(char *, void * *, gint *, char * *, gint *)gdk_utf8_to_compound_text;
extern (C) gint function(void *, gint, char *, gint, char * * *)gdk_text_property_to_utf8_list;
extern (C) gint function(void *, gint, char *, gint, char * * *)gdk_text_property_to_text_list;
extern (C) void function(_GdkDrawable *, void *)gdk_property_delete;
extern (C) void function(_GdkDrawable *, void *, void *, gint, gint, char *, gint)gdk_property_change;
extern (C) gint function(_GdkDrawable *, void *, void *, gulong, gulong, gint, void * *, gint *, gint *, char * *)gdk_property_get;
extern (C) char * function(void *)gdk_atom_name;
extern (C) void * function(in char *)gdk_atom_intern_static_string;
extern (C) void * function(in char *, gint)gdk_atom_intern;
extern (C) _GdkDrawable * function(_GdkScreen *, guint, gint, gint, gint)gdk_pixmap_foreign_new_for_screen;
extern (C) _GdkDrawable * function(_GdkDisplay *, guint)gdk_pixmap_lookup_for_display;
extern (C) _GdkDrawable * function(_GdkDisplay *, guint)gdk_pixmap_foreign_new_for_display;
extern (C) _GdkDrawable * function(guint)gdk_pixmap_lookup;
extern (C) _GdkDrawable * function(guint)gdk_pixmap_foreign_new;
extern (C) _GdkDrawable * function(_GdkDrawable *, _GdkColormap *, _GdkDrawable * *, _GdkColor *, char * *)gdk_pixmap_colormap_create_from_xpm_d;
extern (C) _GdkDrawable * function(_GdkDrawable *, _GdkDrawable * *, _GdkColor *, char * *)gdk_pixmap_create_from_xpm_d;
extern (C) _GdkDrawable * function(_GdkDrawable *, _GdkColormap *, _GdkDrawable * *, _GdkColor *, char *)gdk_pixmap_colormap_create_from_xpm;
extern (C) _GdkDrawable * function(_GdkDrawable *, _GdkDrawable * *, _GdkColor *, char *)gdk_pixmap_create_from_xpm;
extern (C) _GdkDrawable * function(_GdkDrawable *, char *, gint, gint, gint, _GdkColor *, _GdkColor *)gdk_pixmap_create_from_data;
extern (C) _GdkDrawable * function(_GdkDrawable *, in char *, gint, gint)gdk_bitmap_create_from_data;
extern (C) _GdkDrawable * function(_GdkDrawable *, gint, gint, gint)gdk_pixmap_new;
extern (C) guint function()gdk_pixmap_get_type;
extern (C) _PangoAttribute * function(_GdkColor *)gdk_pango_attr_emboss_color_new;
extern (C) _PangoAttribute * function(gint)gdk_pango_attr_embossed_new;
extern (C) _PangoAttribute * function(_GdkDrawable *)gdk_pango_attr_stipple_new;
extern (C) void * function(void *, gint, gint, gint *, gint)gdk_pango_layout_get_clip_region;
extern (C) void * function(_PangoLayoutLine *, gint, gint, gint *, gint)gdk_pango_layout_line_get_clip_region;
extern (C) void function(void *, _GdkColormap *)gdk_pango_context_set_colormap;
extern (C) void * function()gdk_pango_context_get;
extern (C) void * function(_GdkScreen *)gdk_pango_context_get_for_screen;
extern (C) void function(_GdkPangoRenderer *, gint, _GdkColor *)gdk_pango_renderer_set_override_color;
extern (C) void function(_GdkPangoRenderer *, gint, _GdkDrawable *)gdk_pango_renderer_set_stipple;
extern (C) void function(_GdkPangoRenderer *, _GdkGC *)gdk_pango_renderer_set_gc;
extern (C) void function(_GdkPangoRenderer *, _GdkDrawable *)gdk_pango_renderer_set_drawable;
extern (C) _PangoRenderer * function(_GdkScreen *)gdk_pango_renderer_get_default;
extern (C) _PangoRenderer * function(_GdkScreen *)gdk_pango_renderer_new;
extern (C) GType function()gdk_pango_renderer_get_type;
extern (C) _GSList * function(void *)gdk_display_manager_list_displays;
extern (C) void function(void *, _GdkDisplay *)gdk_display_manager_set_default_display;
extern (C) _GdkDisplay * function(void *)gdk_display_manager_get_default_display;
extern (C) void * function()gdk_display_manager_get;
extern (C) GType function()gdk_display_manager_get_type;
extern (C) guint function(guint32)gdk_unicode_to_keyval;
extern (C) guint32 function(guint)gdk_keyval_to_unicode;
extern (C) gint function(guint)gdk_keyval_is_lower;
extern (C) gint function(guint)gdk_keyval_is_upper;
extern (C) guint function(guint)gdk_keyval_to_lower;
extern (C) guint function(guint)gdk_keyval_to_upper;
extern (C) void function(guint, guint *, guint *)gdk_keyval_convert_case;
extern (C) guint function(char *)gdk_keyval_from_name;
extern (C) char * function(guint)gdk_keyval_name;
extern (C) gint function(_GdkKeymap *)gdk_keymap_have_bidi_layouts;
extern (C) gint function(_GdkKeymap *)gdk_keymap_get_direction;
extern (C) gint function(_GdkKeymap *, guint, _GdkKeymapKey * *, guint * *, gint *)gdk_keymap_get_entries_for_keycode;
extern (C) gint function(_GdkKeymap *, guint, _GdkKeymapKey * *, gint *)gdk_keymap_get_entries_for_keyval;
extern (C) gint function(_GdkKeymap *, guint, gint, gint, guint *, gint *, gint *, gint *)gdk_keymap_translate_keyboard_state;
extern (C) guint function(_GdkKeymap *, _GdkKeymapKey *)gdk_keymap_lookup_key;
extern (C) _GdkKeymap * function(_GdkDisplay *)gdk_keymap_get_for_display;
extern (C) _GdkKeymap * function()gdk_keymap_get_default;
extern (C) GType function()gdk_keymap_get_type;
extern (C) _GdkColormap * function(_GdkImage *)gdk_image_get_colormap;
extern (C) void function(_GdkImage *, _GdkColormap *)gdk_image_set_colormap;
extern (C) guint function(_GdkImage *, gint, gint)gdk_image_get_pixel;
extern (C) void function(_GdkImage *, gint, gint, guint)gdk_image_put_pixel;
extern (C) void function(_GdkImage *)gdk_image_unref;
extern (C) _GdkImage * function(_GdkImage *)gdk_image_ref;
extern (C) _GdkImage * function(_GdkDrawable *, gint, gint, gint, gint)gdk_image_get;
extern (C) _GdkImage * function(gint, _GdkVisual *, gint, gint)gdk_image_new;
extern (C) guint function()gdk_image_get_type;
extern (C) _GdkDisplay * function(_GdkFont *)gdk_font_get_display;
extern (C) void function(_GdkFont *, char *, gint *, gint *, gint *, gint *, gint *)gdk_string_extents;
extern (C) void function(_GdkFont *, guint *, gint, gint *, gint *, gint *, gint *, gint *)gdk_text_extents_wc;
extern (C) void function(_GdkFont *, char *, gint, gint *, gint *, gint *, gint *, gint *)gdk_text_extents;
extern (C) gint function(_GdkFont *, char)gdk_char_height;
extern (C) gint function(_GdkFont *, char *, gint)gdk_text_height;
extern (C) gint function(_GdkFont *, char *)gdk_string_height;
extern (C) gint function(_GdkFont *, char)gdk_char_measure;
extern (C) gint function(_GdkFont *, char *, gint)gdk_text_measure;
extern (C) gint function(_GdkFont *, char *)gdk_string_measure;
extern (C) gint function(_GdkFont *, guint)gdk_char_width_wc;
extern (C) gint function(_GdkFont *, char)gdk_char_width;
extern (C) gint function(_GdkFont *, guint *, gint)gdk_text_width_wc;
extern (C) gint function(_GdkFont *, char *, gint)gdk_text_width;
extern (C) gint function(_GdkFont *, char *)gdk_string_width;
extern (C) _GdkFont * function(void *)gdk_font_from_description;
extern (C) _GdkFont * function(char *)gdk_fontset_load;
extern (C) _GdkFont * function(char *)gdk_font_load;
extern (C) _GdkFont * function(_GdkDisplay *, void *)gdk_font_from_description_for_display;
extern (C) _GdkFont * function(_GdkDisplay *, char *)gdk_fontset_load_for_display;
extern (C) _GdkFont * function(_GdkDisplay *, char *)gdk_font_load_for_display;
extern (C) gint function(_GdkFont *, _GdkFont *)gdk_font_equal;
extern (C) gint function(_GdkFont *)gdk_font_id;
extern (C) void function(_GdkFont *)gdk_font_unref;
extern (C) _GdkFont * function(_GdkFont *)gdk_font_ref;
extern (C) guint function()gdk_font_get_type;
extern (C) guint function()gdk_window_edge_get_type;
extern (C) guint function()gdk_gravity_get_type;
extern (C) guint function()gdk_wm_function_get_type;
extern (C) guint function()gdk_wm_decoration_get_type;
extern (C) guint function()gdk_window_type_hint_get_type;
extern (C) guint function()gdk_window_hints_get_type;
extern (C) guint function()gdk_window_attributes_type_get_type;
extern (C) guint function()gdk_window_type_get_type;
extern (C) guint function()gdk_window_class_get_type;
extern (C) guint function()gdk_visual_type_get_type;
extern (C) guint function()gdk_grab_status_get_type;
extern (C) guint function()gdk_status_get_type;
extern (C) guint function()gdk_input_condition_get_type;
extern (C) guint function()gdk_modifier_type_get_type;
extern (C) guint function()gdk_byte_order_get_type;
extern (C) guint function()gdk_rgb_dither_get_type;
extern (C) guint function()gdk_overlap_type_get_type;
extern (C) guint function()gdk_fill_rule_get_type;
extern (C) guint function()gdk_prop_mode_get_type;
extern (C) guint function()gdk_axis_use_get_type;
extern (C) guint function()gdk_input_mode_get_type;
extern (C) guint function()gdk_input_source_get_type;
extern (C) guint function()gdk_extension_mode_get_type;
extern (C) guint function()gdk_image_type_get_type;
extern (C) guint function()gdk_gc_values_mask_get_type;
extern (C) guint function()gdk_subwindow_mode_get_type;
extern (C) guint function()gdk_line_style_get_type;
extern (C) guint function()gdk_join_style_get_type;
extern (C) guint function()gdk_function_get_type;
extern (C) guint function()gdk_fill_get_type;
extern (C) guint function()gdk_cap_style_get_type;
extern (C) guint function()gdk_font_type_get_type;
extern (C) guint function()gdk_owner_change_get_type;
extern (C) GType function()gdk_setting_action_get_type;
extern (C) guint function()gdk_window_state_get_type;
extern (C) guint function()gdk_property_state_get_type;
extern (C) guint function()gdk_crossing_mode_get_type;
extern (C) guint function()gdk_notify_type_get_type;
extern (C) guint function()gdk_scroll_direction_get_type;
extern (C) guint function()gdk_visibility_state_get_type;
extern (C) guint function()gdk_event_mask_get_type;
extern (C) guint function()gdk_event_type_get_type;
extern (C) guint function()gdk_filter_return_get_type;
extern (C) guint function()gdk_drag_protocol_get_type;
extern (C) GType function()gdk_drag_action_get_type;
extern (C) guint function()gdk_cursor_type_get_type;
extern (C) void * function(_GdkDrawable *)gdk_drawable_get_visible_region;
extern (C) void * function(_GdkDrawable *)gdk_drawable_get_clip_region;
extern (C) _GdkImage * function(_GdkDrawable *, _GdkImage *, gint, gint, gint, gint, gint, gint)gdk_drawable_copy_to_image;
extern (C) _GdkImage * function(_GdkDrawable *, gint, gint, gint, gint)gdk_drawable_get_image;
extern (C) void function(_GdkDrawable *, _GdkGC *, _GdkTrapezoid *, gint)gdk_draw_trapezoids;
extern (C) void function(_GdkDrawable *, _GdkGC *, _PangoMatrix *, void *, gint, gint, _PangoGlyphString *)gdk_draw_glyphs_transformed;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, void *, _GdkColor *, _GdkColor *)gdk_draw_layout_with_colors;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, _PangoLayoutLine *, _GdkColor *, _GdkColor *)gdk_draw_layout_line_with_colors;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, void *)gdk_draw_layout;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, _PangoLayoutLine *)gdk_draw_layout_line;
extern (C) void function(_GdkDrawable *, _GdkGC *, void *, gint, gint, _PangoGlyphString *)gdk_draw_glyphs;
extern (C) void function(_GdkDrawable *, _GdkGC *, void *, gint, gint, gint, gint, gint, gint, gint, gint, gint)gdk_draw_pixbuf;
extern (C) void function(_GdkDrawable *, _GdkGC *, _GdkPoint *, gint)gdk_draw_lines;
extern (C) void function(_GdkDrawable *, _GdkGC *, _GdkSegment *, gint)gdk_draw_segments;
extern (C) void function(_GdkDrawable *, _GdkGC *, _GdkPoint *, gint)gdk_draw_points;
extern (C) void function(_GdkDrawable *, _GdkGC *, _GdkImage *, gint, gint, gint, gint, gint, gint)gdk_draw_image;
extern (C) void function(_GdkDrawable *, _GdkGC *, _GdkDrawable *, gint, gint, gint, gint, gint, gint)gdk_draw_drawable;
extern (C) void function(_GdkDrawable *, _GdkFont *, _GdkGC *, gint, gint, guint *, gint)gdk_draw_text_wc;
extern (C) void function(_GdkDrawable *, _GdkFont *, _GdkGC *, gint, gint, char *, gint)gdk_draw_text;
extern (C) void function(_GdkDrawable *, _GdkFont *, _GdkGC *, gint, gint, char *)gdk_draw_string;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, _GdkPoint *, gint)gdk_draw_polygon;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, gint, gint)gdk_draw_arc;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint)gdk_draw_rectangle;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint)gdk_draw_line;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint)gdk_draw_point;
extern (C) void function(_GdkDrawable *)gdk_drawable_unref;
extern (C) _GdkDrawable * function(_GdkDrawable *)gdk_drawable_ref;
extern (C) _GdkDisplay * function(_GdkDrawable *)gdk_drawable_get_display;
extern (C) _GdkScreen * function(_GdkDrawable *)gdk_drawable_get_screen;
extern (C) gint function(_GdkDrawable *)gdk_drawable_get_depth;
extern (C) _GdkVisual * function(_GdkDrawable *)gdk_drawable_get_visual;
extern (C) _GdkColormap * function(_GdkDrawable *)gdk_drawable_get_colormap;
extern (C) void function(_GdkDrawable *, _GdkColormap *)gdk_drawable_set_colormap;
extern (C) void function(_GdkDrawable *, gint *, gint *)gdk_drawable_get_size;
extern (C) void * function(_GdkDrawable *, char *)gdk_drawable_get_data;
extern (C) void function(_GdkDrawable *, char *, void *, _BCD_func__4634)gdk_drawable_set_data;
extern (C) guint function()gdk_drawable_get_type;
extern (C) _GdkScreen * function(_GdkGC *)gdk_gc_get_screen;
extern (C) void function(_GdkGC *, _GdkColor *)gdk_gc_set_rgb_bg_color;
extern (C) void function(_GdkGC *, _GdkColor *)gdk_gc_set_rgb_fg_color;
extern (C) _GdkColormap * function(_GdkGC *)gdk_gc_get_colormap;
extern (C) void function(_GdkGC *, _GdkColormap *)gdk_gc_set_colormap;
extern (C) void function(_GdkGC *, _GdkGC *)gdk_gc_copy;
extern (C) void function(_GdkGC *, gint, gint)gdk_gc_offset;
extern (C) void function(_GdkGC *, gint, in char *, gint)gdk_gc_set_dashes;
extern (C) void function(_GdkGC *, gint, gint, gint, gint)gdk_gc_set_line_attributes;
extern (C) void function(_GdkGC *, gint)gdk_gc_set_exposures;
extern (C) void function(_GdkGC *, gint)gdk_gc_set_subwindow;
extern (C) void function(_GdkGC *, void *)gdk_gc_set_clip_region;
extern (C) void function(_GdkGC *, _GdkRectangle *)gdk_gc_set_clip_rectangle;
extern (C) void function(_GdkGC *, _GdkDrawable *)gdk_gc_set_clip_mask;
extern (C) void function(_GdkGC *, gint, gint)gdk_gc_set_clip_origin;
extern (C) void function(_GdkGC *, gint, gint)gdk_gc_set_ts_origin;
extern (C) void function(_GdkGC *, _GdkDrawable *)gdk_gc_set_stipple;
extern (C) void function(_GdkGC *, _GdkDrawable *)gdk_gc_set_tile;
extern (C) void function(_GdkGC *, gint)gdk_gc_set_fill;
extern (C) void function(_GdkGC *, gint)gdk_gc_set_function;
extern (C) void function(_GdkGC *, _GdkFont *)gdk_gc_set_font;
extern (C) void function(_GdkGC *, _GdkColor *)gdk_gc_set_background;
extern (C) void function(_GdkGC *, _GdkColor *)gdk_gc_set_foreground;
extern (C) void function(_GdkGC *, _GdkGCValues *, gint)gdk_gc_set_values;
extern (C) void function(_GdkGC *, _GdkGCValues *)gdk_gc_get_values;
extern (C) void function(_GdkGC *)gdk_gc_unref;
extern (C) _GdkGC * function(_GdkGC *)gdk_gc_ref;
extern (C) _GdkGC * function(_GdkDrawable *, _GdkGCValues *, gint)gdk_gc_new_with_values;
extern (C) _GdkGC * function(_GdkDrawable *)gdk_gc_new;
extern (C) guint function()gdk_gc_get_type;
extern (C) gint function(_GdkDisplay *)gdk_display_supports_composite;
extern (C) gint function(_GdkDisplay *)gdk_display_supports_input_shapes;
extern (C) gint function(_GdkDisplay *)gdk_display_supports_shapes;
extern (C) void function(_GdkDisplay *, _GdkDrawable *, guint32, void * *, gint)gdk_display_store_clipboard;
extern (C) gint function(_GdkDisplay *)gdk_display_supports_clipboard_persistence;
extern (C) gint function(_GdkDisplay *, void *)gdk_display_request_selection_notification;
extern (C) gint function(_GdkDisplay *)gdk_display_supports_selection_notification;
extern (C) _GdkDrawable * function(_GdkDisplay *)gdk_display_get_default_group;
extern (C) void function(_GdkDisplay *, guint *, guint *)gdk_display_get_maximal_cursor_size;
extern (C) guint function(_GdkDisplay *)gdk_display_get_default_cursor_size;
extern (C) gint function(_GdkDisplay *)gdk_display_supports_cursor_color;
extern (C) gint function(_GdkDisplay *)gdk_display_supports_cursor_alpha;
extern (C) _GdkDisplay * function()gdk_display_open_default_libgtk_only;
extern (C) _GdkDisplayPointerHooks * function(_GdkDisplay *, _GdkDisplayPointerHooks *)gdk_display_set_pointer_hooks;
extern (C) void function(_GdkDisplay *, _GdkScreen *, gint, gint)gdk_display_warp_pointer;
extern (C) _GdkDrawable * function(_GdkDisplay *, gint *, gint *)gdk_display_get_window_at_pointer;
extern (C) void function(_GdkDisplay *, _GdkScreen * *, gint *, gint *, gint *)gdk_display_get_pointer;
extern (C) _GdkDevice * function(_GdkDisplay *)gdk_display_get_core_pointer;
extern (C) _GdkDisplay * function()gdk_display_get_default;
extern (C) void function(_GdkDisplay *, guint)gdk_display_set_double_click_distance;
extern (C) void function(_GdkDisplay *, guint)gdk_display_set_double_click_time;
extern (C) void function(_GdkDisplay *, void *, _BCD_func__4335, void *)gdk_display_add_client_message_filter;
extern (C) void function(_GdkDisplay *, _GdkEvent *)gdk_display_put_event;
extern (C) _GdkEvent * function(_GdkDisplay *)gdk_display_peek_event;
extern (C) _GdkEvent * function(_GdkDisplay *)gdk_display_get_event;
extern (C) _GList * function(_GdkDisplay *)gdk_display_list_devices;
extern (C) void function(_GdkDisplay *)gdk_display_close;
extern (C) void function(_GdkDisplay *)gdk_display_flush;
extern (C) void function(_GdkDisplay *)gdk_display_sync;
extern (C) void function(_GdkDisplay *)gdk_display_beep;
extern (C) gint function(_GdkDisplay *)gdk_display_pointer_is_grabbed;
extern (C) void function(_GdkDisplay *, guint32)gdk_display_keyboard_ungrab;
extern (C) void function(_GdkDisplay *, guint32)gdk_display_pointer_ungrab;
extern (C) _GdkScreen * function(_GdkDisplay *)gdk_display_get_default_screen;
extern (C) _GdkScreen * function(_GdkDisplay *, gint)gdk_display_get_screen;
extern (C) gint function(_GdkDisplay *)gdk_display_get_n_screens;
extern (C) char * function(_GdkDisplay *)gdk_display_get_name;
extern (C) _GdkDisplay * function(char *)gdk_display_open;
extern (C) GType function()gdk_display_get_type;
extern (C) gint function(char *, _GValue *)gdk_setting_get;
extern (C) void function(void *, _BCD_func__4335, void *)gdk_add_client_message_filter;
extern (C) gint function()gdk_get_show_events;
extern (C) void function(gint)gdk_set_show_events;
extern (C) _GdkScreen * function(_GdkEvent *)gdk_event_get_screen;
extern (C) void function(_GdkEvent *, _GdkScreen *)gdk_event_set_screen;
extern (C) void function(_BCD_func__4336, void *, _BCD_func__4634)gdk_event_handler_set;
extern (C) void function(_GdkEventMotion *)gdk_event_request_motions;
extern (C) gint function(_GdkEvent *, gint, double *)gdk_event_get_axis;
extern (C) gint function(_GdkEvent *, double *, double *)gdk_event_get_root_coords;
extern (C) gint function(_GdkEvent *, double *, double *)gdk_event_get_coords;
extern (C) gint function(_GdkEvent *, gint *)gdk_event_get_state;
extern (C) guint32 function(_GdkEvent *)gdk_event_get_time;
extern (C) void function(_GdkEvent *)gdk_event_free;
extern (C) _GdkEvent * function(_GdkEvent *)gdk_event_copy;
extern (C) _GdkEvent * function(gint)gdk_event_new;
extern (C) void function(_GdkEvent *)gdk_event_put;
extern (C) _GdkEvent * function(_GdkDrawable *)gdk_event_get_graphics_expose;
extern (C) _GdkEvent * function()gdk_event_peek;
extern (C) _GdkEvent * function()gdk_event_get;
extern (C) gint function()gdk_events_pending;
extern (C) GType function()gdk_event_get_type;
extern (C) _GdkDevice * function()gdk_device_get_core_pointer;
extern (C) void function(_GdkDrawable *, gint, gint)gdk_input_set_extension_events;
extern (C) gint function(_GdkDevice *, double *, gint, double *)gdk_device_get_axis;
extern (C) void function(_GdkTimeCoord * *, gint)gdk_device_free_history;
extern (C) gint function(_GdkDevice *, _GdkDrawable *, guint32, guint32, _GdkTimeCoord * * *, gint *)gdk_device_get_history;
extern (C) void function(_GdkDevice *, _GdkDrawable *, double *, gint *)gdk_device_get_state;
extern (C) void function(_GdkDevice *, guint, gint)gdk_device_set_axis_use;
extern (C) void function(_GdkDevice *, guint, guint, gint)gdk_device_set_key;
extern (C) gint function(_GdkDevice *, gint)gdk_device_set_mode;
extern (C) void function(_GdkDevice *, gint)gdk_device_set_source;
extern (C) _GList * function()gdk_devices_list;
extern (C) GType function()gdk_device_get_type;
extern (C) gint function(_GdkDragContext *)gdk_drag_drop_succeeded;
extern (C) void function(_GdkDragContext *, guint32)gdk_drag_abort;
extern (C) void function(_GdkDragContext *, guint32)gdk_drag_drop;
extern (C) gint function(_GdkDragContext *, _GdkDrawable *, gint, gint, gint, gint, gint, guint32)gdk_drag_motion;
extern (C) void function(_GdkDragContext *, _GdkDrawable *, gint, gint, _GdkDrawable * *, gint *)gdk_drag_find_window;
extern (C) guint function(guint, gint *)gdk_drag_get_protocol;
extern (C) void function(_GdkDragContext *, _GdkDrawable *, _GdkScreen *, gint, gint, _GdkDrawable * *, gint *)gdk_drag_find_window_for_screen;
extern (C) guint function(_GdkDisplay *, guint, gint *)gdk_drag_get_protocol_for_display;
extern (C) _GdkDragContext * function(_GdkDrawable *, _GList *)gdk_drag_begin;
extern (C) void * function(_GdkDragContext *)gdk_drag_get_selection;
extern (C) void function(_GdkDragContext *, gint, guint32)gdk_drop_finish;
extern (C) void function(_GdkDragContext *, gint, guint32)gdk_drop_reply;
extern (C) void function(_GdkDragContext *, gint, guint32)gdk_drag_status;
extern (C) void function(_GdkDragContext *)gdk_drag_context_unref;
extern (C) void function(_GdkDragContext *)gdk_drag_context_ref;
extern (C) _GdkDragContext * function()gdk_drag_context_new;
extern (C) GType function()gdk_drag_context_get_type;
extern (C) void * function(_GdkCursor *)gdk_cursor_get_image;
extern (C) _GdkCursor * function(_GdkDisplay *, char *)gdk_cursor_new_from_name;
extern (C) void function(_GdkCursor *)gdk_cursor_unref;
extern (C) _GdkCursor * function(_GdkCursor *)gdk_cursor_ref;
extern (C) _GdkDisplay * function(_GdkCursor *)gdk_cursor_get_display;
extern (C) _GdkCursor * function(_GdkDisplay *, void *, gint, gint)gdk_cursor_new_from_pixbuf;
extern (C) _GdkCursor * function(_GdkDrawable *, _GdkDrawable *, _GdkColor *, _GdkColor *, gint, gint)gdk_cursor_new_from_pixmap;
extern (C) _GdkCursor * function(gint)gdk_cursor_new;
extern (C) _GdkCursor * function(_GdkDisplay *, gint)gdk_cursor_new_for_display;
extern (C) GType function()gdk_cursor_get_type;
extern (C) void function(void *, void *)gdk_cairo_region;
extern (C) void function(void *, _GdkRectangle *)gdk_cairo_rectangle;
extern (C) void function(void *, _GdkDrawable *, double, double)gdk_cairo_set_source_pixmap;
extern (C) void function(void *, void *, double, double)gdk_cairo_set_source_pixbuf;
extern (C) void function(void *, _GdkColor *)gdk_cairo_set_source_color;
extern (C) void * function(_GdkDrawable *)gdk_cairo_create;
extern (C) void * function(void *, _GdkImage *, _GdkColormap *, gint, gint, gint, gint, gint, gint)gdk_pixbuf_get_from_image;
extern (C) void * function(void *, _GdkDrawable *, _GdkColormap *, gint, gint, gint, gint, gint, gint)gdk_pixbuf_get_from_drawable;
extern (C) void function(void *, _GdkDrawable * *, _GdkDrawable * *, gint)gdk_pixbuf_render_pixmap_and_mask;
extern (C) void function(void *, _GdkColormap *, _GdkDrawable * *, _GdkDrawable * *, gint)gdk_pixbuf_render_pixmap_and_mask_for_colormap;
extern (C) void function(void *, _GdkDrawable *, gint, gint, gint, gint, gint, gint, gint, gint, gint, gint, gint)gdk_pixbuf_render_to_drawable_alpha;
extern (C) void function(void *, _GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, gint, gint, gint, gint)gdk_pixbuf_render_to_drawable;
extern (C) void function(void *, _GdkDrawable *, gint, gint, gint, gint, gint, gint, gint)gdk_pixbuf_render_threshold_alpha;
extern (C) guint function()gdk_pixbuf_rotation_get_type;
extern (C) guint function()gdk_interp_type_get_type;
extern (C) guint function()gdk_pixbuf_error_get_type;
extern (C) guint function()gdk_colorspace_get_type;
extern (C) guint function()gdk_pixbuf_alpha_mode_get_type;
extern (C) void * function(_GdkPixbufLoader *)gdk_pixbuf_loader_get_format;
extern (C) gint function(_GdkPixbufLoader *, _GError * *)gdk_pixbuf_loader_close;
extern (C) void * function(_GdkPixbufLoader *)gdk_pixbuf_loader_get_animation;
extern (C) void * function(_GdkPixbufLoader *)gdk_pixbuf_loader_get_pixbuf;
extern (C) gint function(_GdkPixbufLoader *, char *, gsize, _GError * *)gdk_pixbuf_loader_write;
extern (C) void function(_GdkPixbufLoader *, gint, gint)gdk_pixbuf_loader_set_size;
extern (C) _GdkPixbufLoader * function(char *, _GError * *)gdk_pixbuf_loader_new_with_mime_type;
extern (C) _GdkPixbufLoader * function(char *, _GError * *)gdk_pixbuf_loader_new_with_type;
extern (C) _GdkPixbufLoader * function()gdk_pixbuf_loader_new;
extern (C) GType function()gdk_pixbuf_loader_get_type;
extern (C) void * function(char *, gint *, gint *)gdk_pixbuf_get_file_info;
extern (C) char * function(void *)gdk_pixbuf_format_get_license;
extern (C) void function(void *, gint)gdk_pixbuf_format_set_disabled;
extern (C) gint function(void *)gdk_pixbuf_format_is_disabled;
extern (C) gint function(void *)gdk_pixbuf_format_is_scalable;
extern (C) gint function(void *)gdk_pixbuf_format_is_writable;
extern (C) char * * function(void *)gdk_pixbuf_format_get_extensions;
extern (C) char * * function(void *)gdk_pixbuf_format_get_mime_types;
extern (C) char * function(void *)gdk_pixbuf_format_get_description;
extern (C) char * function(void *)gdk_pixbuf_format_get_name;
extern (C) _GSList * function()gdk_pixbuf_get_formats;
extern (C) void function(void *, void *)gdk_pixbuf_simple_anim_add_frame;
extern (C) void * function(gint, gint, float)gdk_pixbuf_simple_anim_new;
extern (C) GType function()gdk_pixbuf_simple_anim_iter_get_type;
extern (C) GType function()gdk_pixbuf_simple_anim_get_type;
extern (C) gint function(void *, _GTimeVal *)gdk_pixbuf_animation_iter_advance;
extern (C) gint function(void *)gdk_pixbuf_animation_iter_on_currently_loading_frame;
extern (C) void * function(void *)gdk_pixbuf_animation_iter_get_pixbuf;
extern (C) gint function(void *)gdk_pixbuf_animation_iter_get_delay_time;
extern (C) GType function()gdk_pixbuf_animation_iter_get_type;
extern (C) void * function(void *, _GTimeVal *)gdk_pixbuf_animation_get_iter;
extern (C) void * function(void *)gdk_pixbuf_animation_get_static_image;
extern (C) gint function(void *)gdk_pixbuf_animation_is_static_image;
extern (C) gint function(void *)gdk_pixbuf_animation_get_height;
extern (C) gint function(void *)gdk_pixbuf_animation_get_width;
extern (C) void function(void *)gdk_pixbuf_animation_unref;
extern (C) void * function(void *)gdk_pixbuf_animation_ref;
extern (C) void * function(char *, _GError * *)gdk_pixbuf_animation_new_from_file;
extern (C) GType function()gdk_pixbuf_animation_get_type;
extern (C) void * function(void *, gint)gdk_pixbuf_flip;
extern (C) void * function(void *, gint)gdk_pixbuf_rotate_simple;
extern (C) void * function(void *, gint, gint, gint, gint, gint, guint32, guint32)gdk_pixbuf_composite_color_simple;
extern (C) void * function(void *, gint, gint, gint)gdk_pixbuf_scale_simple;
extern (C) void function(void *, void *, gint, gint, gint, gint, double, double, double, double, gint, gint, gint, gint, gint, guint32, guint32)gdk_pixbuf_composite_color;
extern (C) void function(void *, void *, gint, gint, gint, gint, double, double, double, double, gint, gint)gdk_pixbuf_composite;
extern (C) void function(void *, void *, gint, gint, gint, gint, double, double, double, double, gint)gdk_pixbuf_scale;
extern (C) char * function(void *, char *)gdk_pixbuf_get_option;
extern (C) void * function(void *)gdk_pixbuf_apply_embedded_orientation;
extern (C) void function(void *, void *, float, gint)gdk_pixbuf_saturate_and_pixelate;
extern (C) void function(void *, gint, gint, gint, gint, void *, gint, gint)gdk_pixbuf_copy_area;
extern (C) void * function(void *, gint, char, char, char)gdk_pixbuf_add_alpha;
extern (C) gint function(void *, char * *, gsize *, in char *, char * *, char * *, _GError * *)gdk_pixbuf_save_to_bufferv;
extern (C) gint function(void *, char * *, gsize *, in char *, _GError * *, ...)gdk_pixbuf_save_to_buffer;
extern (C) gint function(void *, _BCD_func__4618, void *, char *, char * *, char * *, _GError * *)gdk_pixbuf_save_to_callbackv;
extern (C) gint function(void *, _BCD_func__4618, void *, char *, _GError * *, ...)gdk_pixbuf_save_to_callback;
extern (C) gint function(void *, char *, char *, char * *, char * *, _GError * *)gdk_pixbuf_savev;
extern (C) gint function(void *, char *, char *, _GError * *, ...)gdk_pixbuf_save;
extern (C) void function(void *, guint32)gdk_pixbuf_fill;
extern (C) void * function(gint, char *, gint, _GError * *)gdk_pixbuf_new_from_inline;
extern (C) void * function(char * *)gdk_pixbuf_new_from_xpm_data;
extern (C) void * function(char *, gint, gint, gint, gint, gint, gint, _BCD_func__4621, void *)gdk_pixbuf_new_from_data;
extern (C) void * function(char *, gint, gint, gint, _GError * *)gdk_pixbuf_new_from_file_at_scale;
extern (C) void * function(char *, gint, gint, _GError * *)gdk_pixbuf_new_from_file_at_size;
extern (C) void * function(char *, _GError * *)gdk_pixbuf_new_from_file;
extern (C) void * function(void *, gint, gint, gint, gint)gdk_pixbuf_new_subpixbuf;
extern (C) void * function(void *)gdk_pixbuf_copy;
extern (C) void * function(gint, gint, gint, gint, gint)gdk_pixbuf_new;
extern (C) gint function(void *)gdk_pixbuf_get_rowstride;
extern (C) gint function(void *)gdk_pixbuf_get_height;
extern (C) gint function(void *)gdk_pixbuf_get_width;
extern (C) char * function(void *)gdk_pixbuf_get_pixels;
extern (C) gint function(void *)gdk_pixbuf_get_bits_per_sample;
extern (C) gint function(void *)gdk_pixbuf_get_has_alpha;
extern (C) gint function(void *)gdk_pixbuf_get_n_channels;
extern (C) gint function(void *)gdk_pixbuf_get_colorspace;
extern (C) void function(void *)gdk_pixbuf_unref;
extern (C) void * function(void *)gdk_pixbuf_ref;
extern (C) GType function()gdk_pixbuf_get_type;
extern (C) GQuark function()gdk_pixbuf_error_quark;
extern (C) extern char ** gdk_pixbuf_version;
extern (C) extern guint* gdk_pixbuf_micro_version;
extern (C) extern guint* gdk_pixbuf_minor_version;
extern (C) extern guint* gdk_pixbuf_major_version;
extern (C) gint function(_GdkColormap *)gdk_rgb_colormap_ditherable;
extern (C) gint function()gdk_rgb_ditherable;
extern (C) _GdkVisual * function()gdk_rgb_get_visual;
extern (C) _GdkColormap * function()gdk_rgb_get_colormap;
extern (C) void function(gint)gdk_rgb_set_min_colors;
extern (C) void function(gint)gdk_rgb_set_install;
extern (C) void function(gint)gdk_rgb_set_verbose;
extern (C) void function(_GdkRgbCmap *)gdk_rgb_cmap_free;
extern (C) _GdkRgbCmap * function(guint *, gint)gdk_rgb_cmap_new;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint, _GdkRgbCmap *)gdk_draw_indexed_image;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint)gdk_draw_gray_image;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint, gint, gint)gdk_draw_rgb_32_image_dithalign;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint)gdk_draw_rgb_32_image;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint, gint, gint)gdk_draw_rgb_image_dithalign;
extern (C) void function(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint)gdk_draw_rgb_image;
extern (C) void function(_GdkColormap *, _GdkColor *)gdk_rgb_find_color;
extern (C) void function(_GdkGC *, guint)gdk_rgb_gc_set_background;
extern (C) void function(_GdkGC *, guint)gdk_rgb_gc_set_foreground;
extern (C) guint function(guint)gdk_rgb_xpixel_from_rgb;
extern (C) void function()gdk_rgb_init;
extern (C) void function(_GdkColormap *, guint *, gint, guint)gdk_colors_free;
extern (C) gint function(_GdkColormap *, gint, guint *, gint, guint *, gint)gdk_colors_alloc;
extern (C) gint function(_GdkColormap *, _GdkColor *)gdk_color_change;
extern (C) gint function(_GdkColormap *, _GdkColor *)gdk_color_alloc;
extern (C) gint function(_GdkColormap *, _GdkColor *)gdk_color_black;
extern (C) gint function(_GdkColormap *, _GdkColor *)gdk_color_white;
extern (C) void function(_GdkColormap *, _GdkColor *, gint)gdk_colors_store;
extern (C) GType function()gdk_color_get_type;
extern (C) char * function(_GdkColor *)gdk_color_to_string;
extern (C) gint function(_GdkColor *, _GdkColor *)gdk_color_equal;
extern (C) guint function(_GdkColor *)gdk_color_hash;
extern (C) gint function(char *, _GdkColor *)gdk_color_parse;
extern (C) void function(_GdkColor *)gdk_color_free;
extern (C) _GdkColor * function(_GdkColor *)gdk_color_copy;
extern (C) _GdkVisual * function(_GdkColormap *)gdk_colormap_get_visual;
extern (C) void function(_GdkColormap *, guint, _GdkColor *)gdk_colormap_query_color;
extern (C) void function(_GdkColormap *, _GdkColor *, gint)gdk_colormap_free_colors;
extern (C) gint function(_GdkColormap *, _GdkColor *, gint, gint)gdk_colormap_alloc_color;
extern (C) gint function(_GdkColormap *, _GdkColor *, gint, gint, gint, gint *)gdk_colormap_alloc_colors;
extern (C) void function(_GdkColormap *, gint)gdk_colormap_change;
extern (C) gint function()gdk_colormap_get_system_size;
extern (C) _GdkScreen * function(_GdkColormap *)gdk_colormap_get_screen;
extern (C) _GdkColormap * function()gdk_colormap_get_system;
extern (C) void function(_GdkColormap *)gdk_colormap_unref;
extern (C) _GdkColormap * function(_GdkColormap *)gdk_colormap_ref;
extern (C) _GdkColormap * function(_GdkVisual *, gint)gdk_colormap_new;
extern (C) guint function()gdk_colormap_get_type;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("gdk_threads_add_timeout",  cast(void**)& gdk_threads_add_timeout),
        Symbol("gdk_threads_add_timeout_full",  cast(void**)& gdk_threads_add_timeout_full),
        Symbol("gdk_threads_add_idle",  cast(void**)& gdk_threads_add_idle),
        Symbol("gdk_threads_add_idle_full",  cast(void**)& gdk_threads_add_idle_full),
        Symbol("gdk_threads_set_lock_functions",  cast(void**)& gdk_threads_set_lock_functions),
        Symbol("gdk_threads_init",  cast(void**)& gdk_threads_init),
        Symbol("gdk_threads_leave",  cast(void**)& gdk_threads_leave),
        Symbol("gdk_threads_enter",  cast(void**)& gdk_threads_enter),
        Symbol("gdk_threads_unlock",  cast(void**)& gdk_threads_unlock),
        Symbol("gdk_threads_lock",  cast(void**)& gdk_threads_lock),
        Symbol("gdk_threads_mutex",  cast(void**)& gdk_threads_mutex),
        Symbol("gdk_notify_startup_complete_with_id",  cast(void**)& gdk_notify_startup_complete_with_id),
        Symbol("gdk_notify_startup_complete",  cast(void**)& gdk_notify_startup_complete),
        Symbol("gdk_event_send_client_message_for_display",  cast(void**)& gdk_event_send_client_message_for_display),
        Symbol("gdk_event_send_clientmessage_toall",  cast(void**)& gdk_event_send_clientmessage_toall),
        Symbol("gdk_event_send_client_message",  cast(void**)& gdk_event_send_client_message),
        Symbol("gdk_mbstowcs",  cast(void**)& gdk_mbstowcs),
        Symbol("gdk_wcstombs",  cast(void**)& gdk_wcstombs),
        Symbol("gdk_rectangle_get_type",  cast(void**)& gdk_rectangle_get_type),
        Symbol("gdk_rectangle_union",  cast(void**)& gdk_rectangle_union),
        Symbol("gdk_rectangle_intersect",  cast(void**)& gdk_rectangle_intersect),
        Symbol("gdk_set_double_click_time",  cast(void**)& gdk_set_double_click_time),
        Symbol("gdk_flush",  cast(void**)& gdk_flush),
        Symbol("gdk_beep",  cast(void**)& gdk_beep),
        Symbol("gdk_screen_height_mm",  cast(void**)& gdk_screen_height_mm),
        Symbol("gdk_screen_width_mm",  cast(void**)& gdk_screen_width_mm),
        Symbol("gdk_screen_height",  cast(void**)& gdk_screen_height),
        Symbol("gdk_screen_width",  cast(void**)& gdk_screen_width),
        Symbol("gdk_pointer_is_grabbed",  cast(void**)& gdk_pointer_is_grabbed),
        Symbol("gdk_keyboard_ungrab",  cast(void**)& gdk_keyboard_ungrab),
        Symbol("gdk_pointer_ungrab",  cast(void**)& gdk_pointer_ungrab),
        Symbol("gdk_keyboard_grab_info_libgtk_only",  cast(void**)& gdk_keyboard_grab_info_libgtk_only),
        Symbol("gdk_pointer_grab_info_libgtk_only",  cast(void**)& gdk_pointer_grab_info_libgtk_only),
        Symbol("gdk_keyboard_grab",  cast(void**)& gdk_keyboard_grab),
        Symbol("gdk_pointer_grab",  cast(void**)& gdk_pointer_grab),
        Symbol("gdk_input_remove",  cast(void**)& gdk_input_remove),
        Symbol("gdk_input_add",  cast(void**)& gdk_input_add),
        Symbol("gdk_input_add_full",  cast(void**)& gdk_input_add_full),
        Symbol("gdk_get_display_arg_name",  cast(void**)& gdk_get_display_arg_name),
        Symbol("gdk_get_display",  cast(void**)& gdk_get_display),
        Symbol("gdk_get_use_xshm",  cast(void**)& gdk_get_use_xshm),
        Symbol("gdk_set_use_xshm",  cast(void**)& gdk_set_use_xshm),
        Symbol("gdk_error_trap_pop",  cast(void**)& gdk_error_trap_pop),
        Symbol("gdk_error_trap_push",  cast(void**)& gdk_error_trap_push),
        Symbol("gdk_set_program_class",  cast(void**)& gdk_set_program_class),
        Symbol("gdk_get_program_class",  cast(void**)& gdk_get_program_class),
        Symbol("gdk_set_locale",  cast(void**)& gdk_set_locale),
        Symbol("gdk_exit",  cast(void**)& gdk_exit),
        Symbol("gdk_pre_parse_libgtk_only",  cast(void**)& gdk_pre_parse_libgtk_only),
        Symbol("gdk_add_option_entries_libgtk_only",  cast(void**)& gdk_add_option_entries_libgtk_only),
        Symbol("gdk_init_check",  cast(void**)& gdk_init_check),
        Symbol("gdk_init",  cast(void**)& gdk_init),
        Symbol("gdk_parse_args",  cast(void**)& gdk_parse_args),
        Symbol("gdk_get_default_root_window",  cast(void**)& gdk_get_default_root_window),
        Symbol("gdk_set_pointer_hooks",  cast(void**)& gdk_set_pointer_hooks),
        Symbol("gdk_window_configure_finished",  cast(void**)& gdk_window_configure_finished),
        Symbol("gdk_window_enable_synchronized_configure",  cast(void**)& gdk_window_enable_synchronized_configure),
        Symbol("gdk_window_get_internal_paint_info",  cast(void**)& gdk_window_get_internal_paint_info),
        Symbol("gdk_window_constrain_size",  cast(void**)& gdk_window_constrain_size),
        Symbol("gdk_window_set_debug_updates",  cast(void**)& gdk_window_set_debug_updates),
        Symbol("gdk_window_process_updates",  cast(void**)& gdk_window_process_updates),
        Symbol("gdk_window_process_all_updates",  cast(void**)& gdk_window_process_all_updates),
        Symbol("gdk_window_thaw_toplevel_updates_libgtk_only",  cast(void**)& gdk_window_thaw_toplevel_updates_libgtk_only),
        Symbol("gdk_window_freeze_toplevel_updates_libgtk_only",  cast(void**)& gdk_window_freeze_toplevel_updates_libgtk_only),
        Symbol("gdk_window_thaw_updates",  cast(void**)& gdk_window_thaw_updates),
        Symbol("gdk_window_freeze_updates",  cast(void**)& gdk_window_freeze_updates),
        Symbol("gdk_window_get_update_area",  cast(void**)& gdk_window_get_update_area),
        Symbol("gdk_window_invalidate_maybe_recurse",  cast(void**)& gdk_window_invalidate_maybe_recurse),
        Symbol("gdk_window_invalidate_region",  cast(void**)& gdk_window_invalidate_region),
        Symbol("gdk_window_invalidate_rect",  cast(void**)& gdk_window_invalidate_rect),
        Symbol("gdk_window_begin_move_drag",  cast(void**)& gdk_window_begin_move_drag),
        Symbol("gdk_window_begin_resize_drag",  cast(void**)& gdk_window_begin_resize_drag),
        Symbol("gdk_window_register_dnd",  cast(void**)& gdk_window_register_dnd),
        Symbol("gdk_window_set_opacity",  cast(void**)& gdk_window_set_opacity),
        Symbol("gdk_window_set_keep_below",  cast(void**)& gdk_window_set_keep_below),
        Symbol("gdk_window_set_keep_above",  cast(void**)& gdk_window_set_keep_above),
        Symbol("gdk_window_unfullscreen",  cast(void**)& gdk_window_unfullscreen),
        Symbol("gdk_window_fullscreen",  cast(void**)& gdk_window_fullscreen),
        Symbol("gdk_window_unmaximize",  cast(void**)& gdk_window_unmaximize),
        Symbol("gdk_window_maximize",  cast(void**)& gdk_window_maximize),
        Symbol("gdk_window_unstick",  cast(void**)& gdk_window_unstick),
        Symbol("gdk_window_stick",  cast(void**)& gdk_window_stick),
        Symbol("gdk_window_deiconify",  cast(void**)& gdk_window_deiconify),
        Symbol("gdk_window_iconify",  cast(void**)& gdk_window_iconify),
        Symbol("gdk_window_beep",  cast(void**)& gdk_window_beep),
        Symbol("gdk_window_get_toplevels",  cast(void**)& gdk_window_get_toplevels),
        Symbol("gdk_window_set_functions",  cast(void**)& gdk_window_set_functions),
        Symbol("gdk_window_get_decorations",  cast(void**)& gdk_window_get_decorations),
        Symbol("gdk_window_set_decorations",  cast(void**)& gdk_window_set_decorations),
        Symbol("gdk_window_get_group",  cast(void**)& gdk_window_get_group),
        Symbol("gdk_window_set_group",  cast(void**)& gdk_window_set_group),
        Symbol("gdk_window_set_icon_name",  cast(void**)& gdk_window_set_icon_name),
        Symbol("gdk_window_set_icon",  cast(void**)& gdk_window_set_icon),
        Symbol("gdk_window_set_icon_list",  cast(void**)& gdk_window_set_icon_list),
        Symbol("gdk_window_set_events",  cast(void**)& gdk_window_set_events),
        Symbol("gdk_window_get_events",  cast(void**)& gdk_window_get_events),
        Symbol("gdk_window_peek_children",  cast(void**)& gdk_window_peek_children),
        Symbol("gdk_window_get_children",  cast(void**)& gdk_window_get_children),
        Symbol("gdk_window_get_toplevel",  cast(void**)& gdk_window_get_toplevel),
        Symbol("gdk_window_get_parent",  cast(void**)& gdk_window_get_parent),
        Symbol("gdk_window_get_pointer",  cast(void**)& gdk_window_get_pointer),
        Symbol("gdk_window_get_frame_extents",  cast(void**)& gdk_window_get_frame_extents),
        Symbol("gdk_window_get_root_origin",  cast(void**)& gdk_window_get_root_origin),
        Symbol("gdk_window_get_deskrelative_origin",  cast(void**)& gdk_window_get_deskrelative_origin),
        Symbol("gdk_window_get_origin",  cast(void**)& gdk_window_get_origin),
        Symbol("gdk_window_get_position",  cast(void**)& gdk_window_get_position),
        Symbol("gdk_window_get_geometry",  cast(void**)& gdk_window_get_geometry),
        Symbol("gdk_window_get_user_data",  cast(void**)& gdk_window_get_user_data),
        Symbol("gdk_window_set_cursor",  cast(void**)& gdk_window_set_cursor),
        Symbol("gdk_window_set_back_pixmap",  cast(void**)& gdk_window_set_back_pixmap),
        Symbol("gdk_window_set_background",  cast(void**)& gdk_window_set_background),
        Symbol("gdk_window_set_transient_for",  cast(void**)& gdk_window_set_transient_for),
        Symbol("gdk_window_set_startup_id",  cast(void**)& gdk_window_set_startup_id),
        Symbol("gdk_window_set_role",  cast(void**)& gdk_window_set_role),
        Symbol("gdk_window_set_title",  cast(void**)& gdk_window_set_title),
        Symbol("gdk_window_end_paint",  cast(void**)& gdk_window_end_paint),
        Symbol("gdk_window_begin_paint_region",  cast(void**)& gdk_window_begin_paint_region),
        Symbol("gdk_window_begin_paint_rect",  cast(void**)& gdk_window_begin_paint_rect),
        Symbol("gdk_set_sm_client_id",  cast(void**)& gdk_set_sm_client_id),
        Symbol("gdk_window_set_geometry_hints",  cast(void**)& gdk_window_set_geometry_hints),
        Symbol("gdk_window_set_urgency_hint",  cast(void**)& gdk_window_set_urgency_hint),
        Symbol("gdk_window_set_skip_pager_hint",  cast(void**)& gdk_window_set_skip_pager_hint),
        Symbol("gdk_window_set_skip_taskbar_hint",  cast(void**)& gdk_window_set_skip_taskbar_hint),
        Symbol("gdk_window_set_modal_hint",  cast(void**)& gdk_window_set_modal_hint),
        Symbol("gdk_window_get_type_hint",  cast(void**)& gdk_window_get_type_hint),
        Symbol("gdk_window_set_type_hint",  cast(void**)& gdk_window_set_type_hint),
        Symbol("gdk_window_set_hints",  cast(void**)& gdk_window_set_hints),
        Symbol("gdk_window_lookup_for_display",  cast(void**)& gdk_window_lookup_for_display),
        Symbol("gdk_window_foreign_new_for_display",  cast(void**)& gdk_window_foreign_new_for_display),
        Symbol("gdk_window_lookup",  cast(void**)& gdk_window_lookup),
        Symbol("gdk_window_foreign_new",  cast(void**)& gdk_window_foreign_new),
        Symbol("gdk_window_set_static_gravities",  cast(void**)& gdk_window_set_static_gravities),
        Symbol("gdk_window_get_state",  cast(void**)& gdk_window_get_state),
        Symbol("gdk_window_is_viewable",  cast(void**)& gdk_window_is_viewable),
        Symbol("gdk_window_is_visible",  cast(void**)& gdk_window_is_visible),
        Symbol("gdk_window_merge_child_input_shapes",  cast(void**)& gdk_window_merge_child_input_shapes),
        Symbol("gdk_window_set_child_input_shapes",  cast(void**)& gdk_window_set_child_input_shapes),
        Symbol("gdk_window_input_shape_combine_region",  cast(void**)& gdk_window_input_shape_combine_region),
        Symbol("gdk_window_input_shape_combine_mask",  cast(void**)& gdk_window_input_shape_combine_mask),
        Symbol("gdk_window_merge_child_shapes",  cast(void**)& gdk_window_merge_child_shapes),
        Symbol("gdk_window_set_composited",  cast(void**)& gdk_window_set_composited),
        Symbol("gdk_window_set_child_shapes",  cast(void**)& gdk_window_set_child_shapes),
        Symbol("gdk_window_shape_combine_region",  cast(void**)& gdk_window_shape_combine_region),
        Symbol("gdk_window_shape_combine_mask",  cast(void**)& gdk_window_shape_combine_mask),
        Symbol("gdk_window_move_region",  cast(void**)& gdk_window_move_region),
        Symbol("gdk_window_scroll",  cast(void**)& gdk_window_scroll),
        Symbol("gdk_window_remove_filter",  cast(void**)& gdk_window_remove_filter),
        Symbol("gdk_window_add_filter",  cast(void**)& gdk_window_add_filter),
        Symbol("gdk_window_set_focus_on_map",  cast(void**)& gdk_window_set_focus_on_map),
        Symbol("gdk_window_set_accept_focus",  cast(void**)& gdk_window_set_accept_focus),
        Symbol("gdk_window_set_override_redirect",  cast(void**)& gdk_window_set_override_redirect),
        Symbol("gdk_window_set_user_data",  cast(void**)& gdk_window_set_user_data),
        Symbol("gdk_window_focus",  cast(void**)& gdk_window_focus),
        Symbol("gdk_window_lower",  cast(void**)& gdk_window_lower),
        Symbol("gdk_window_raise",  cast(void**)& gdk_window_raise),
        Symbol("gdk_window_clear_area_e",  cast(void**)& gdk_window_clear_area_e),
        Symbol("gdk_window_clear_area",  cast(void**)& gdk_window_clear_area),
        Symbol("gdk_window_clear",  cast(void**)& gdk_window_clear),
        Symbol("gdk_window_reparent",  cast(void**)& gdk_window_reparent),
        Symbol("gdk_window_move_resize",  cast(void**)& gdk_window_move_resize),
        Symbol("gdk_window_resize",  cast(void**)& gdk_window_resize),
        Symbol("gdk_window_move",  cast(void**)& gdk_window_move),
        Symbol("gdk_window_show_unraised",  cast(void**)& gdk_window_show_unraised),
        Symbol("gdk_window_withdraw",  cast(void**)& gdk_window_withdraw),
        Symbol("gdk_window_hide",  cast(void**)& gdk_window_hide),
        Symbol("gdk_window_show",  cast(void**)& gdk_window_show),
        Symbol("gdk_window_at_pointer",  cast(void**)& gdk_window_at_pointer),
        Symbol("gdk_window_get_window_type",  cast(void**)& gdk_window_get_window_type),
        Symbol("gdk_window_destroy",  cast(void**)& gdk_window_destroy),
        Symbol("gdk_window_new",  cast(void**)& gdk_window_new),
        Symbol("gdk_window_object_get_type",  cast(void**)& gdk_window_object_get_type),
        Symbol("gdk_visual_get_screen",  cast(void**)& gdk_visual_get_screen),
        Symbol("gdk_list_visuals",  cast(void**)& gdk_list_visuals),
        Symbol("gdk_query_visual_types",  cast(void**)& gdk_query_visual_types),
        Symbol("gdk_query_depths",  cast(void**)& gdk_query_depths),
        Symbol("gdk_visual_get_best_with_both",  cast(void**)& gdk_visual_get_best_with_both),
        Symbol("gdk_visual_get_best_with_type",  cast(void**)& gdk_visual_get_best_with_type),
        Symbol("gdk_visual_get_best_with_depth",  cast(void**)& gdk_visual_get_best_with_depth),
        Symbol("gdk_visual_get_best",  cast(void**)& gdk_visual_get_best),
        Symbol("gdk_visual_get_system",  cast(void**)& gdk_visual_get_system),
        Symbol("gdk_visual_get_best_type",  cast(void**)& gdk_visual_get_best_type),
        Symbol("gdk_visual_get_best_depth",  cast(void**)& gdk_visual_get_best_depth),
        Symbol("gdk_visual_get_type",  cast(void**)& gdk_visual_get_type),
        Symbol("gdk_spawn_command_line_on_screen",  cast(void**)& gdk_spawn_command_line_on_screen),
        Symbol("gdk_spawn_on_screen_with_pipes",  cast(void**)& gdk_spawn_on_screen_with_pipes),
        Symbol("gdk_spawn_on_screen",  cast(void**)& gdk_spawn_on_screen),
        Symbol("gdk_selection_send_notify_for_display",  cast(void**)& gdk_selection_send_notify_for_display),
        Symbol("gdk_selection_send_notify",  cast(void**)& gdk_selection_send_notify),
        Symbol("gdk_selection_property_get",  cast(void**)& gdk_selection_property_get),
        Symbol("gdk_selection_convert",  cast(void**)& gdk_selection_convert),
        Symbol("gdk_selection_owner_get_for_display",  cast(void**)& gdk_selection_owner_get_for_display),
        Symbol("gdk_selection_owner_set_for_display",  cast(void**)& gdk_selection_owner_set_for_display),
        Symbol("gdk_selection_owner_get",  cast(void**)& gdk_selection_owner_get),
        Symbol("gdk_selection_owner_set",  cast(void**)& gdk_selection_owner_set),
        Symbol("gdk_screen_get_window_stack",  cast(void**)& gdk_screen_get_window_stack),
        Symbol("gdk_screen_get_active_window",  cast(void**)& gdk_screen_get_active_window),
        Symbol("gdk_screen_get_resolution",  cast(void**)& gdk_screen_get_resolution),
        Symbol("gdk_screen_set_resolution",  cast(void**)& gdk_screen_set_resolution),
        Symbol("gdk_screen_get_font_options",  cast(void**)& gdk_screen_get_font_options),
        Symbol("gdk_screen_set_font_options",  cast(void**)& gdk_screen_set_font_options),
        Symbol("gdk_screen_get_setting",  cast(void**)& gdk_screen_get_setting),
        Symbol("gdk_screen_get_default",  cast(void**)& gdk_screen_get_default),
        Symbol("gdk_screen_broadcast_client_message",  cast(void**)& gdk_screen_broadcast_client_message),
        Symbol("gdk_screen_get_monitor_at_window",  cast(void**)& gdk_screen_get_monitor_at_window),
        Symbol("gdk_screen_get_monitor_at_point",  cast(void**)& gdk_screen_get_monitor_at_point),
        Symbol("gdk_screen_get_monitor_geometry",  cast(void**)& gdk_screen_get_monitor_geometry),
        Symbol("gdk_screen_get_n_monitors",  cast(void**)& gdk_screen_get_n_monitors),
        Symbol("gdk_screen_make_display_name",  cast(void**)& gdk_screen_make_display_name),
        Symbol("gdk_screen_get_toplevel_windows",  cast(void**)& gdk_screen_get_toplevel_windows),
        Symbol("gdk_screen_list_visuals",  cast(void**)& gdk_screen_list_visuals),
        Symbol("gdk_screen_get_height_mm",  cast(void**)& gdk_screen_get_height_mm),
        Symbol("gdk_screen_get_width_mm",  cast(void**)& gdk_screen_get_width_mm),
        Symbol("gdk_screen_get_height",  cast(void**)& gdk_screen_get_height),
        Symbol("gdk_screen_get_width",  cast(void**)& gdk_screen_get_width),
        Symbol("gdk_screen_get_number",  cast(void**)& gdk_screen_get_number),
        Symbol("gdk_screen_get_display",  cast(void**)& gdk_screen_get_display),
        Symbol("gdk_screen_get_root_window",  cast(void**)& gdk_screen_get_root_window),
        Symbol("gdk_screen_is_composited",  cast(void**)& gdk_screen_is_composited),
        Symbol("gdk_screen_get_rgba_visual",  cast(void**)& gdk_screen_get_rgba_visual),
        Symbol("gdk_screen_get_rgba_colormap",  cast(void**)& gdk_screen_get_rgba_colormap),
        Symbol("gdk_screen_get_rgb_visual",  cast(void**)& gdk_screen_get_rgb_visual),
        Symbol("gdk_screen_get_rgb_colormap",  cast(void**)& gdk_screen_get_rgb_colormap),
        Symbol("gdk_screen_get_system_visual",  cast(void**)& gdk_screen_get_system_visual),
        Symbol("gdk_screen_get_system_colormap",  cast(void**)& gdk_screen_get_system_colormap),
        Symbol("gdk_screen_set_default_colormap",  cast(void**)& gdk_screen_set_default_colormap),
        Symbol("gdk_screen_get_default_colormap",  cast(void**)& gdk_screen_get_default_colormap),
        Symbol("gdk_screen_get_type",  cast(void**)& gdk_screen_get_type),
        Symbol("gdk_region_spans_intersect_foreach",  cast(void**)& gdk_region_spans_intersect_foreach),
        Symbol("gdk_region_xor",  cast(void**)& gdk_region_xor),
        Symbol("gdk_region_subtract",  cast(void**)& gdk_region_subtract),
        Symbol("gdk_region_union",  cast(void**)& gdk_region_union),
        Symbol("gdk_region_intersect",  cast(void**)& gdk_region_intersect),
        Symbol("gdk_region_union_with_rect",  cast(void**)& gdk_region_union_with_rect),
        Symbol("gdk_region_shrink",  cast(void**)& gdk_region_shrink),
        Symbol("gdk_region_offset",  cast(void**)& gdk_region_offset),
        Symbol("gdk_region_rect_in",  cast(void**)& gdk_region_rect_in),
        Symbol("gdk_region_point_in",  cast(void**)& gdk_region_point_in),
        Symbol("gdk_region_equal",  cast(void**)& gdk_region_equal),
        Symbol("gdk_region_empty",  cast(void**)& gdk_region_empty),
        Symbol("gdk_region_get_rectangles",  cast(void**)& gdk_region_get_rectangles),
        Symbol("gdk_region_get_clipbox",  cast(void**)& gdk_region_get_clipbox),
        Symbol("gdk_region_destroy",  cast(void**)& gdk_region_destroy),
        Symbol("gdk_region_rectangle",  cast(void**)& gdk_region_rectangle),
        Symbol("gdk_region_copy",  cast(void**)& gdk_region_copy),
        Symbol("gdk_region_polygon",  cast(void**)& gdk_region_polygon),
        Symbol("gdk_region_new",  cast(void**)& gdk_region_new),
        Symbol("gdk_free_compound_text",  cast(void**)& gdk_free_compound_text),
        Symbol("gdk_free_text_list",  cast(void**)& gdk_free_text_list),
        Symbol("gdk_utf8_to_compound_text_for_display",  cast(void**)& gdk_utf8_to_compound_text_for_display),
        Symbol("gdk_string_to_compound_text_for_display",  cast(void**)& gdk_string_to_compound_text_for_display),
        Symbol("gdk_utf8_to_string_target",  cast(void**)& gdk_utf8_to_string_target),
        Symbol("gdk_text_property_to_utf8_list_for_display",  cast(void**)& gdk_text_property_to_utf8_list_for_display),
        Symbol("gdk_text_property_to_text_list_for_display",  cast(void**)& gdk_text_property_to_text_list_for_display),
        Symbol("gdk_string_to_compound_text",  cast(void**)& gdk_string_to_compound_text),
        Symbol("gdk_utf8_to_compound_text",  cast(void**)& gdk_utf8_to_compound_text),
        Symbol("gdk_text_property_to_utf8_list",  cast(void**)& gdk_text_property_to_utf8_list),
        Symbol("gdk_text_property_to_text_list",  cast(void**)& gdk_text_property_to_text_list),
        Symbol("gdk_property_delete",  cast(void**)& gdk_property_delete),
        Symbol("gdk_property_change",  cast(void**)& gdk_property_change),
        Symbol("gdk_property_get",  cast(void**)& gdk_property_get),
        Symbol("gdk_atom_name",  cast(void**)& gdk_atom_name),
        Symbol("gdk_atom_intern_static_string",  cast(void**)& gdk_atom_intern_static_string),
        Symbol("gdk_atom_intern",  cast(void**)& gdk_atom_intern),
        Symbol("gdk_pixmap_foreign_new_for_screen",  cast(void**)& gdk_pixmap_foreign_new_for_screen),
        Symbol("gdk_pixmap_lookup_for_display",  cast(void**)& gdk_pixmap_lookup_for_display),
        Symbol("gdk_pixmap_foreign_new_for_display",  cast(void**)& gdk_pixmap_foreign_new_for_display),
        Symbol("gdk_pixmap_lookup",  cast(void**)& gdk_pixmap_lookup),
        Symbol("gdk_pixmap_foreign_new",  cast(void**)& gdk_pixmap_foreign_new),
        Symbol("gdk_pixmap_colormap_create_from_xpm_d",  cast(void**)& gdk_pixmap_colormap_create_from_xpm_d),
        Symbol("gdk_pixmap_create_from_xpm_d",  cast(void**)& gdk_pixmap_create_from_xpm_d),
        Symbol("gdk_pixmap_colormap_create_from_xpm",  cast(void**)& gdk_pixmap_colormap_create_from_xpm),
        Symbol("gdk_pixmap_create_from_xpm",  cast(void**)& gdk_pixmap_create_from_xpm),
        Symbol("gdk_pixmap_create_from_data",  cast(void**)& gdk_pixmap_create_from_data),
        Symbol("gdk_bitmap_create_from_data",  cast(void**)& gdk_bitmap_create_from_data),
        Symbol("gdk_pixmap_new",  cast(void**)& gdk_pixmap_new),
        Symbol("gdk_pixmap_get_type",  cast(void**)& gdk_pixmap_get_type),
        Symbol("gdk_pango_attr_emboss_color_new",  cast(void**)& gdk_pango_attr_emboss_color_new),
        Symbol("gdk_pango_attr_embossed_new",  cast(void**)& gdk_pango_attr_embossed_new),
        Symbol("gdk_pango_attr_stipple_new",  cast(void**)& gdk_pango_attr_stipple_new),
        Symbol("gdk_pango_layout_get_clip_region",  cast(void**)& gdk_pango_layout_get_clip_region),
        Symbol("gdk_pango_layout_line_get_clip_region",  cast(void**)& gdk_pango_layout_line_get_clip_region),
        Symbol("gdk_pango_context_set_colormap",  cast(void**)& gdk_pango_context_set_colormap),
        Symbol("gdk_pango_context_get",  cast(void**)& gdk_pango_context_get),
        Symbol("gdk_pango_context_get_for_screen",  cast(void**)& gdk_pango_context_get_for_screen),
        Symbol("gdk_pango_renderer_set_override_color",  cast(void**)& gdk_pango_renderer_set_override_color),
        Symbol("gdk_pango_renderer_set_stipple",  cast(void**)& gdk_pango_renderer_set_stipple),
        Symbol("gdk_pango_renderer_set_gc",  cast(void**)& gdk_pango_renderer_set_gc),
        Symbol("gdk_pango_renderer_set_drawable",  cast(void**)& gdk_pango_renderer_set_drawable),
        Symbol("gdk_pango_renderer_get_default",  cast(void**)& gdk_pango_renderer_get_default),
        Symbol("gdk_pango_renderer_new",  cast(void**)& gdk_pango_renderer_new),
        Symbol("gdk_pango_renderer_get_type",  cast(void**)& gdk_pango_renderer_get_type),
        Symbol("gdk_display_manager_list_displays",  cast(void**)& gdk_display_manager_list_displays),
        Symbol("gdk_display_manager_set_default_display",  cast(void**)& gdk_display_manager_set_default_display),
        Symbol("gdk_display_manager_get_default_display",  cast(void**)& gdk_display_manager_get_default_display),
        Symbol("gdk_display_manager_get",  cast(void**)& gdk_display_manager_get),
        Symbol("gdk_display_manager_get_type",  cast(void**)& gdk_display_manager_get_type),
        Symbol("gdk_unicode_to_keyval",  cast(void**)& gdk_unicode_to_keyval),
        Symbol("gdk_keyval_to_unicode",  cast(void**)& gdk_keyval_to_unicode),
        Symbol("gdk_keyval_is_lower",  cast(void**)& gdk_keyval_is_lower),
        Symbol("gdk_keyval_is_upper",  cast(void**)& gdk_keyval_is_upper),
        Symbol("gdk_keyval_to_lower",  cast(void**)& gdk_keyval_to_lower),
        Symbol("gdk_keyval_to_upper",  cast(void**)& gdk_keyval_to_upper),
        Symbol("gdk_keyval_convert_case",  cast(void**)& gdk_keyval_convert_case),
        Symbol("gdk_keyval_from_name",  cast(void**)& gdk_keyval_from_name),
        Symbol("gdk_keyval_name",  cast(void**)& gdk_keyval_name),
        Symbol("gdk_keymap_have_bidi_layouts",  cast(void**)& gdk_keymap_have_bidi_layouts),
        Symbol("gdk_keymap_get_direction",  cast(void**)& gdk_keymap_get_direction),
        Symbol("gdk_keymap_get_entries_for_keycode",  cast(void**)& gdk_keymap_get_entries_for_keycode),
        Symbol("gdk_keymap_get_entries_for_keyval",  cast(void**)& gdk_keymap_get_entries_for_keyval),
        Symbol("gdk_keymap_translate_keyboard_state",  cast(void**)& gdk_keymap_translate_keyboard_state),
        Symbol("gdk_keymap_lookup_key",  cast(void**)& gdk_keymap_lookup_key),
        Symbol("gdk_keymap_get_for_display",  cast(void**)& gdk_keymap_get_for_display),
        Symbol("gdk_keymap_get_default",  cast(void**)& gdk_keymap_get_default),
        Symbol("gdk_keymap_get_type",  cast(void**)& gdk_keymap_get_type),
        Symbol("gdk_image_get_colormap",  cast(void**)& gdk_image_get_colormap),
        Symbol("gdk_image_set_colormap",  cast(void**)& gdk_image_set_colormap),
        Symbol("gdk_image_get_pixel",  cast(void**)& gdk_image_get_pixel),
        Symbol("gdk_image_put_pixel",  cast(void**)& gdk_image_put_pixel),
        Symbol("gdk_image_unref",  cast(void**)& gdk_image_unref),
        Symbol("gdk_image_ref",  cast(void**)& gdk_image_ref),
        Symbol("gdk_image_get",  cast(void**)& gdk_image_get),
        Symbol("gdk_image_new",  cast(void**)& gdk_image_new),
        Symbol("gdk_image_get_type",  cast(void**)& gdk_image_get_type),
        Symbol("gdk_font_get_display",  cast(void**)& gdk_font_get_display),
        Symbol("gdk_string_extents",  cast(void**)& gdk_string_extents),
        Symbol("gdk_text_extents_wc",  cast(void**)& gdk_text_extents_wc),
        Symbol("gdk_text_extents",  cast(void**)& gdk_text_extents),
        Symbol("gdk_char_height",  cast(void**)& gdk_char_height),
        Symbol("gdk_text_height",  cast(void**)& gdk_text_height),
        Symbol("gdk_string_height",  cast(void**)& gdk_string_height),
        Symbol("gdk_char_measure",  cast(void**)& gdk_char_measure),
        Symbol("gdk_text_measure",  cast(void**)& gdk_text_measure),
        Symbol("gdk_string_measure",  cast(void**)& gdk_string_measure),
        Symbol("gdk_char_width_wc",  cast(void**)& gdk_char_width_wc),
        Symbol("gdk_char_width",  cast(void**)& gdk_char_width),
        Symbol("gdk_text_width_wc",  cast(void**)& gdk_text_width_wc),
        Symbol("gdk_text_width",  cast(void**)& gdk_text_width),
        Symbol("gdk_string_width",  cast(void**)& gdk_string_width),
        Symbol("gdk_font_from_description",  cast(void**)& gdk_font_from_description),
        Symbol("gdk_fontset_load",  cast(void**)& gdk_fontset_load),
        Symbol("gdk_font_load",  cast(void**)& gdk_font_load),
        Symbol("gdk_font_from_description_for_display",  cast(void**)& gdk_font_from_description_for_display),
        Symbol("gdk_fontset_load_for_display",  cast(void**)& gdk_fontset_load_for_display),
        Symbol("gdk_font_load_for_display",  cast(void**)& gdk_font_load_for_display),
        Symbol("gdk_font_equal",  cast(void**)& gdk_font_equal),
        Symbol("gdk_font_id",  cast(void**)& gdk_font_id),
        Symbol("gdk_font_unref",  cast(void**)& gdk_font_unref),
        Symbol("gdk_font_ref",  cast(void**)& gdk_font_ref),
        Symbol("gdk_font_get_type",  cast(void**)& gdk_font_get_type),
        Symbol("gdk_window_edge_get_type",  cast(void**)& gdk_window_edge_get_type),
        Symbol("gdk_gravity_get_type",  cast(void**)& gdk_gravity_get_type),
        Symbol("gdk_wm_function_get_type",  cast(void**)& gdk_wm_function_get_type),
        Symbol("gdk_wm_decoration_get_type",  cast(void**)& gdk_wm_decoration_get_type),
        Symbol("gdk_window_type_hint_get_type",  cast(void**)& gdk_window_type_hint_get_type),
        Symbol("gdk_window_hints_get_type",  cast(void**)& gdk_window_hints_get_type),
        Symbol("gdk_window_attributes_type_get_type",  cast(void**)& gdk_window_attributes_type_get_type),
        Symbol("gdk_window_type_get_type",  cast(void**)& gdk_window_type_get_type),
        Symbol("gdk_window_class_get_type",  cast(void**)& gdk_window_class_get_type),
        Symbol("gdk_visual_type_get_type",  cast(void**)& gdk_visual_type_get_type),
        Symbol("gdk_grab_status_get_type",  cast(void**)& gdk_grab_status_get_type),
        Symbol("gdk_status_get_type",  cast(void**)& gdk_status_get_type),
        Symbol("gdk_input_condition_get_type",  cast(void**)& gdk_input_condition_get_type),
        Symbol("gdk_modifier_type_get_type",  cast(void**)& gdk_modifier_type_get_type),
        Symbol("gdk_byte_order_get_type",  cast(void**)& gdk_byte_order_get_type),
        Symbol("gdk_rgb_dither_get_type",  cast(void**)& gdk_rgb_dither_get_type),
        Symbol("gdk_overlap_type_get_type",  cast(void**)& gdk_overlap_type_get_type),
        Symbol("gdk_fill_rule_get_type",  cast(void**)& gdk_fill_rule_get_type),
        Symbol("gdk_prop_mode_get_type",  cast(void**)& gdk_prop_mode_get_type),
        Symbol("gdk_axis_use_get_type",  cast(void**)& gdk_axis_use_get_type),
        Symbol("gdk_input_mode_get_type",  cast(void**)& gdk_input_mode_get_type),
        Symbol("gdk_input_source_get_type",  cast(void**)& gdk_input_source_get_type),
        Symbol("gdk_extension_mode_get_type",  cast(void**)& gdk_extension_mode_get_type),
        Symbol("gdk_image_type_get_type",  cast(void**)& gdk_image_type_get_type),
        Symbol("gdk_gc_values_mask_get_type",  cast(void**)& gdk_gc_values_mask_get_type),
        Symbol("gdk_subwindow_mode_get_type",  cast(void**)& gdk_subwindow_mode_get_type),
        Symbol("gdk_line_style_get_type",  cast(void**)& gdk_line_style_get_type),
        Symbol("gdk_join_style_get_type",  cast(void**)& gdk_join_style_get_type),
        Symbol("gdk_function_get_type",  cast(void**)& gdk_function_get_type),
        Symbol("gdk_fill_get_type",  cast(void**)& gdk_fill_get_type),
        Symbol("gdk_cap_style_get_type",  cast(void**)& gdk_cap_style_get_type),
        Symbol("gdk_font_type_get_type",  cast(void**)& gdk_font_type_get_type),
        Symbol("gdk_owner_change_get_type",  cast(void**)& gdk_owner_change_get_type),
        Symbol("gdk_setting_action_get_type",  cast(void**)& gdk_setting_action_get_type),
        Symbol("gdk_window_state_get_type",  cast(void**)& gdk_window_state_get_type),
        Symbol("gdk_property_state_get_type",  cast(void**)& gdk_property_state_get_type),
        Symbol("gdk_crossing_mode_get_type",  cast(void**)& gdk_crossing_mode_get_type),
        Symbol("gdk_notify_type_get_type",  cast(void**)& gdk_notify_type_get_type),
        Symbol("gdk_scroll_direction_get_type",  cast(void**)& gdk_scroll_direction_get_type),
        Symbol("gdk_visibility_state_get_type",  cast(void**)& gdk_visibility_state_get_type),
        Symbol("gdk_event_mask_get_type",  cast(void**)& gdk_event_mask_get_type),
        Symbol("gdk_event_type_get_type",  cast(void**)& gdk_event_type_get_type),
        Symbol("gdk_filter_return_get_type",  cast(void**)& gdk_filter_return_get_type),
        Symbol("gdk_drag_protocol_get_type",  cast(void**)& gdk_drag_protocol_get_type),
        Symbol("gdk_drag_action_get_type",  cast(void**)& gdk_drag_action_get_type),
        Symbol("gdk_cursor_type_get_type",  cast(void**)& gdk_cursor_type_get_type),
        Symbol("gdk_drawable_get_visible_region",  cast(void**)& gdk_drawable_get_visible_region),
        Symbol("gdk_drawable_get_clip_region",  cast(void**)& gdk_drawable_get_clip_region),
        Symbol("gdk_drawable_copy_to_image",  cast(void**)& gdk_drawable_copy_to_image),
        Symbol("gdk_drawable_get_image",  cast(void**)& gdk_drawable_get_image),
        Symbol("gdk_draw_trapezoids",  cast(void**)& gdk_draw_trapezoids),
        Symbol("gdk_draw_glyphs_transformed",  cast(void**)& gdk_draw_glyphs_transformed),
        Symbol("gdk_draw_layout_with_colors",  cast(void**)& gdk_draw_layout_with_colors),
        Symbol("gdk_draw_layout_line_with_colors",  cast(void**)& gdk_draw_layout_line_with_colors),
        Symbol("gdk_draw_layout",  cast(void**)& gdk_draw_layout),
        Symbol("gdk_draw_layout_line",  cast(void**)& gdk_draw_layout_line),
        Symbol("gdk_draw_glyphs",  cast(void**)& gdk_draw_glyphs),
        Symbol("gdk_draw_pixbuf",  cast(void**)& gdk_draw_pixbuf),
        Symbol("gdk_draw_lines",  cast(void**)& gdk_draw_lines),
        Symbol("gdk_draw_segments",  cast(void**)& gdk_draw_segments),
        Symbol("gdk_draw_points",  cast(void**)& gdk_draw_points),
        Symbol("gdk_draw_image",  cast(void**)& gdk_draw_image),
        Symbol("gdk_draw_drawable",  cast(void**)& gdk_draw_drawable),
        Symbol("gdk_draw_text_wc",  cast(void**)& gdk_draw_text_wc),
        Symbol("gdk_draw_text",  cast(void**)& gdk_draw_text),
        Symbol("gdk_draw_string",  cast(void**)& gdk_draw_string),
        Symbol("gdk_draw_polygon",  cast(void**)& gdk_draw_polygon),
        Symbol("gdk_draw_arc",  cast(void**)& gdk_draw_arc),
        Symbol("gdk_draw_rectangle",  cast(void**)& gdk_draw_rectangle),
        Symbol("gdk_draw_line",  cast(void**)& gdk_draw_line),
        Symbol("gdk_draw_point",  cast(void**)& gdk_draw_point),
        Symbol("gdk_drawable_unref",  cast(void**)& gdk_drawable_unref),
        Symbol("gdk_drawable_ref",  cast(void**)& gdk_drawable_ref),
        Symbol("gdk_drawable_get_display",  cast(void**)& gdk_drawable_get_display),
        Symbol("gdk_drawable_get_screen",  cast(void**)& gdk_drawable_get_screen),
        Symbol("gdk_drawable_get_depth",  cast(void**)& gdk_drawable_get_depth),
        Symbol("gdk_drawable_get_visual",  cast(void**)& gdk_drawable_get_visual),
        Symbol("gdk_drawable_get_colormap",  cast(void**)& gdk_drawable_get_colormap),
        Symbol("gdk_drawable_set_colormap",  cast(void**)& gdk_drawable_set_colormap),
        Symbol("gdk_drawable_get_size",  cast(void**)& gdk_drawable_get_size),
        Symbol("gdk_drawable_get_data",  cast(void**)& gdk_drawable_get_data),
        Symbol("gdk_drawable_set_data",  cast(void**)& gdk_drawable_set_data),
        Symbol("gdk_drawable_get_type",  cast(void**)& gdk_drawable_get_type),
        Symbol("gdk_gc_get_screen",  cast(void**)& gdk_gc_get_screen),
        Symbol("gdk_gc_set_rgb_bg_color",  cast(void**)& gdk_gc_set_rgb_bg_color),
        Symbol("gdk_gc_set_rgb_fg_color",  cast(void**)& gdk_gc_set_rgb_fg_color),
        Symbol("gdk_gc_get_colormap",  cast(void**)& gdk_gc_get_colormap),
        Symbol("gdk_gc_set_colormap",  cast(void**)& gdk_gc_set_colormap),
        Symbol("gdk_gc_copy",  cast(void**)& gdk_gc_copy),
        Symbol("gdk_gc_offset",  cast(void**)& gdk_gc_offset),
        Symbol("gdk_gc_set_dashes",  cast(void**)& gdk_gc_set_dashes),
        Symbol("gdk_gc_set_line_attributes",  cast(void**)& gdk_gc_set_line_attributes),
        Symbol("gdk_gc_set_exposures",  cast(void**)& gdk_gc_set_exposures),
        Symbol("gdk_gc_set_subwindow",  cast(void**)& gdk_gc_set_subwindow),
        Symbol("gdk_gc_set_clip_region",  cast(void**)& gdk_gc_set_clip_region),
        Symbol("gdk_gc_set_clip_rectangle",  cast(void**)& gdk_gc_set_clip_rectangle),
        Symbol("gdk_gc_set_clip_mask",  cast(void**)& gdk_gc_set_clip_mask),
        Symbol("gdk_gc_set_clip_origin",  cast(void**)& gdk_gc_set_clip_origin),
        Symbol("gdk_gc_set_ts_origin",  cast(void**)& gdk_gc_set_ts_origin),
        Symbol("gdk_gc_set_stipple",  cast(void**)& gdk_gc_set_stipple),
        Symbol("gdk_gc_set_tile",  cast(void**)& gdk_gc_set_tile),
        Symbol("gdk_gc_set_fill",  cast(void**)& gdk_gc_set_fill),
        Symbol("gdk_gc_set_function",  cast(void**)& gdk_gc_set_function),
        Symbol("gdk_gc_set_font",  cast(void**)& gdk_gc_set_font),
        Symbol("gdk_gc_set_background",  cast(void**)& gdk_gc_set_background),
        Symbol("gdk_gc_set_foreground",  cast(void**)& gdk_gc_set_foreground),
        Symbol("gdk_gc_set_values",  cast(void**)& gdk_gc_set_values),
        Symbol("gdk_gc_get_values",  cast(void**)& gdk_gc_get_values),
        Symbol("gdk_gc_unref",  cast(void**)& gdk_gc_unref),
        Symbol("gdk_gc_ref",  cast(void**)& gdk_gc_ref),
        Symbol("gdk_gc_new_with_values",  cast(void**)& gdk_gc_new_with_values),
        Symbol("gdk_gc_new",  cast(void**)& gdk_gc_new),
        Symbol("gdk_gc_get_type",  cast(void**)& gdk_gc_get_type),
        Symbol("gdk_display_supports_composite",  cast(void**)& gdk_display_supports_composite),
        Symbol("gdk_display_supports_input_shapes",  cast(void**)& gdk_display_supports_input_shapes),
        Symbol("gdk_display_supports_shapes",  cast(void**)& gdk_display_supports_shapes),
        Symbol("gdk_display_store_clipboard",  cast(void**)& gdk_display_store_clipboard),
        Symbol("gdk_display_supports_clipboard_persistence",  cast(void**)& gdk_display_supports_clipboard_persistence),
        Symbol("gdk_display_request_selection_notification",  cast(void**)& gdk_display_request_selection_notification),
        Symbol("gdk_display_supports_selection_notification",  cast(void**)& gdk_display_supports_selection_notification),
        Symbol("gdk_display_get_default_group",  cast(void**)& gdk_display_get_default_group),
        Symbol("gdk_display_get_maximal_cursor_size",  cast(void**)& gdk_display_get_maximal_cursor_size),
        Symbol("gdk_display_get_default_cursor_size",  cast(void**)& gdk_display_get_default_cursor_size),
        Symbol("gdk_display_supports_cursor_color",  cast(void**)& gdk_display_supports_cursor_color),
        Symbol("gdk_display_supports_cursor_alpha",  cast(void**)& gdk_display_supports_cursor_alpha),
        Symbol("gdk_display_open_default_libgtk_only",  cast(void**)& gdk_display_open_default_libgtk_only),
        Symbol("gdk_display_set_pointer_hooks",  cast(void**)& gdk_display_set_pointer_hooks),
        Symbol("gdk_display_warp_pointer",  cast(void**)& gdk_display_warp_pointer),
        Symbol("gdk_display_get_window_at_pointer",  cast(void**)& gdk_display_get_window_at_pointer),
        Symbol("gdk_display_get_pointer",  cast(void**)& gdk_display_get_pointer),
        Symbol("gdk_display_get_core_pointer",  cast(void**)& gdk_display_get_core_pointer),
        Symbol("gdk_display_get_default",  cast(void**)& gdk_display_get_default),
        Symbol("gdk_display_set_double_click_distance",  cast(void**)& gdk_display_set_double_click_distance),
        Symbol("gdk_display_set_double_click_time",  cast(void**)& gdk_display_set_double_click_time),
        Symbol("gdk_display_add_client_message_filter",  cast(void**)& gdk_display_add_client_message_filter),
        Symbol("gdk_display_put_event",  cast(void**)& gdk_display_put_event),
        Symbol("gdk_display_peek_event",  cast(void**)& gdk_display_peek_event),
        Symbol("gdk_display_get_event",  cast(void**)& gdk_display_get_event),
        Symbol("gdk_display_list_devices",  cast(void**)& gdk_display_list_devices),
        Symbol("gdk_display_close",  cast(void**)& gdk_display_close),
        Symbol("gdk_display_flush",  cast(void**)& gdk_display_flush),
        Symbol("gdk_display_sync",  cast(void**)& gdk_display_sync),
        Symbol("gdk_display_beep",  cast(void**)& gdk_display_beep),
        Symbol("gdk_display_pointer_is_grabbed",  cast(void**)& gdk_display_pointer_is_grabbed),
        Symbol("gdk_display_keyboard_ungrab",  cast(void**)& gdk_display_keyboard_ungrab),
        Symbol("gdk_display_pointer_ungrab",  cast(void**)& gdk_display_pointer_ungrab),
        Symbol("gdk_display_get_default_screen",  cast(void**)& gdk_display_get_default_screen),
        Symbol("gdk_display_get_screen",  cast(void**)& gdk_display_get_screen),
        Symbol("gdk_display_get_n_screens",  cast(void**)& gdk_display_get_n_screens),
        Symbol("gdk_display_get_name",  cast(void**)& gdk_display_get_name),
        Symbol("gdk_display_open",  cast(void**)& gdk_display_open),
        Symbol("gdk_display_get_type",  cast(void**)& gdk_display_get_type),
        Symbol("gdk_setting_get",  cast(void**)& gdk_setting_get),
        Symbol("gdk_add_client_message_filter",  cast(void**)& gdk_add_client_message_filter),
        Symbol("gdk_get_show_events",  cast(void**)& gdk_get_show_events),
        Symbol("gdk_set_show_events",  cast(void**)& gdk_set_show_events),
        Symbol("gdk_event_get_screen",  cast(void**)& gdk_event_get_screen),
        Symbol("gdk_event_set_screen",  cast(void**)& gdk_event_set_screen),
        Symbol("gdk_event_handler_set",  cast(void**)& gdk_event_handler_set),
        Symbol("gdk_event_request_motions",  cast(void**)& gdk_event_request_motions),
        Symbol("gdk_event_get_axis",  cast(void**)& gdk_event_get_axis),
        Symbol("gdk_event_get_root_coords",  cast(void**)& gdk_event_get_root_coords),
        Symbol("gdk_event_get_coords",  cast(void**)& gdk_event_get_coords),
        Symbol("gdk_event_get_state",  cast(void**)& gdk_event_get_state),
        Symbol("gdk_event_get_time",  cast(void**)& gdk_event_get_time),
        Symbol("gdk_event_free",  cast(void**)& gdk_event_free),
        Symbol("gdk_event_copy",  cast(void**)& gdk_event_copy),
        Symbol("gdk_event_new",  cast(void**)& gdk_event_new),
        Symbol("gdk_event_put",  cast(void**)& gdk_event_put),
        Symbol("gdk_event_get_graphics_expose",  cast(void**)& gdk_event_get_graphics_expose),
        Symbol("gdk_event_peek",  cast(void**)& gdk_event_peek),
        Symbol("gdk_event_get",  cast(void**)& gdk_event_get),
        Symbol("gdk_events_pending",  cast(void**)& gdk_events_pending),
        Symbol("gdk_event_get_type",  cast(void**)& gdk_event_get_type),
        Symbol("gdk_device_get_core_pointer",  cast(void**)& gdk_device_get_core_pointer),
        Symbol("gdk_input_set_extension_events",  cast(void**)& gdk_input_set_extension_events),
        Symbol("gdk_device_get_axis",  cast(void**)& gdk_device_get_axis),
        Symbol("gdk_device_free_history",  cast(void**)& gdk_device_free_history),
        Symbol("gdk_device_get_history",  cast(void**)& gdk_device_get_history),
        Symbol("gdk_device_get_state",  cast(void**)& gdk_device_get_state),
        Symbol("gdk_device_set_axis_use",  cast(void**)& gdk_device_set_axis_use),
        Symbol("gdk_device_set_key",  cast(void**)& gdk_device_set_key),
        Symbol("gdk_device_set_mode",  cast(void**)& gdk_device_set_mode),
        Symbol("gdk_device_set_source",  cast(void**)& gdk_device_set_source),
        Symbol("gdk_devices_list",  cast(void**)& gdk_devices_list),
        Symbol("gdk_device_get_type",  cast(void**)& gdk_device_get_type),
        Symbol("gdk_drag_drop_succeeded",  cast(void**)& gdk_drag_drop_succeeded),
        Symbol("gdk_drag_abort",  cast(void**)& gdk_drag_abort),
        Symbol("gdk_drag_drop",  cast(void**)& gdk_drag_drop),
        Symbol("gdk_drag_motion",  cast(void**)& gdk_drag_motion),
        Symbol("gdk_drag_find_window",  cast(void**)& gdk_drag_find_window),
        Symbol("gdk_drag_get_protocol",  cast(void**)& gdk_drag_get_protocol),
        Symbol("gdk_drag_find_window_for_screen",  cast(void**)& gdk_drag_find_window_for_screen),
        Symbol("gdk_drag_get_protocol_for_display",  cast(void**)& gdk_drag_get_protocol_for_display),
        Symbol("gdk_drag_begin",  cast(void**)& gdk_drag_begin),
        Symbol("gdk_drag_get_selection",  cast(void**)& gdk_drag_get_selection),
        Symbol("gdk_drop_finish",  cast(void**)& gdk_drop_finish),
        Symbol("gdk_drop_reply",  cast(void**)& gdk_drop_reply),
        Symbol("gdk_drag_status",  cast(void**)& gdk_drag_status),
        Symbol("gdk_drag_context_unref",  cast(void**)& gdk_drag_context_unref),
        Symbol("gdk_drag_context_ref",  cast(void**)& gdk_drag_context_ref),
        Symbol("gdk_drag_context_new",  cast(void**)& gdk_drag_context_new),
        Symbol("gdk_drag_context_get_type",  cast(void**)& gdk_drag_context_get_type),
        Symbol("gdk_cursor_get_image",  cast(void**)& gdk_cursor_get_image),
        Symbol("gdk_cursor_new_from_name",  cast(void**)& gdk_cursor_new_from_name),
        Symbol("gdk_cursor_unref",  cast(void**)& gdk_cursor_unref),
        Symbol("gdk_cursor_ref",  cast(void**)& gdk_cursor_ref),
        Symbol("gdk_cursor_get_display",  cast(void**)& gdk_cursor_get_display),
        Symbol("gdk_cursor_new_from_pixbuf",  cast(void**)& gdk_cursor_new_from_pixbuf),
        Symbol("gdk_cursor_new_from_pixmap",  cast(void**)& gdk_cursor_new_from_pixmap),
        Symbol("gdk_cursor_new",  cast(void**)& gdk_cursor_new),
        Symbol("gdk_cursor_new_for_display",  cast(void**)& gdk_cursor_new_for_display),
        Symbol("gdk_cursor_get_type",  cast(void**)& gdk_cursor_get_type),
        Symbol("gdk_cairo_region",  cast(void**)& gdk_cairo_region),
        Symbol("gdk_cairo_rectangle",  cast(void**)& gdk_cairo_rectangle),
        Symbol("gdk_cairo_set_source_pixmap",  cast(void**)& gdk_cairo_set_source_pixmap),
        Symbol("gdk_cairo_set_source_pixbuf",  cast(void**)& gdk_cairo_set_source_pixbuf),
        Symbol("gdk_cairo_set_source_color",  cast(void**)& gdk_cairo_set_source_color),
        Symbol("gdk_cairo_create",  cast(void**)& gdk_cairo_create),
        Symbol("gdk_pixbuf_get_from_image",  cast(void**)& gdk_pixbuf_get_from_image),
        Symbol("gdk_pixbuf_get_from_drawable",  cast(void**)& gdk_pixbuf_get_from_drawable),
        Symbol("gdk_pixbuf_render_pixmap_and_mask",  cast(void**)& gdk_pixbuf_render_pixmap_and_mask),
        Symbol("gdk_pixbuf_render_pixmap_and_mask_for_colormap",  cast(void**)& gdk_pixbuf_render_pixmap_and_mask_for_colormap),
        Symbol("gdk_pixbuf_render_to_drawable_alpha",  cast(void**)& gdk_pixbuf_render_to_drawable_alpha),
        Symbol("gdk_pixbuf_render_to_drawable",  cast(void**)& gdk_pixbuf_render_to_drawable),
        Symbol("gdk_pixbuf_render_threshold_alpha",  cast(void**)& gdk_pixbuf_render_threshold_alpha),
        Symbol("gdk_pixbuf_rotation_get_type",  cast(void**)& gdk_pixbuf_rotation_get_type),
        Symbol("gdk_interp_type_get_type",  cast(void**)& gdk_interp_type_get_type),
        Symbol("gdk_pixbuf_error_get_type",  cast(void**)& gdk_pixbuf_error_get_type),
        Symbol("gdk_colorspace_get_type",  cast(void**)& gdk_colorspace_get_type),
        Symbol("gdk_pixbuf_alpha_mode_get_type",  cast(void**)& gdk_pixbuf_alpha_mode_get_type),
        Symbol("gdk_pixbuf_loader_get_format",  cast(void**)& gdk_pixbuf_loader_get_format),
        Symbol("gdk_pixbuf_loader_close",  cast(void**)& gdk_pixbuf_loader_close),
        Symbol("gdk_pixbuf_loader_get_animation",  cast(void**)& gdk_pixbuf_loader_get_animation),
        Symbol("gdk_pixbuf_loader_get_pixbuf",  cast(void**)& gdk_pixbuf_loader_get_pixbuf),
        Symbol("gdk_pixbuf_loader_write",  cast(void**)& gdk_pixbuf_loader_write),
        Symbol("gdk_pixbuf_loader_set_size",  cast(void**)& gdk_pixbuf_loader_set_size),
        Symbol("gdk_pixbuf_loader_new_with_mime_type",  cast(void**)& gdk_pixbuf_loader_new_with_mime_type),
        Symbol("gdk_pixbuf_loader_new_with_type",  cast(void**)& gdk_pixbuf_loader_new_with_type),
        Symbol("gdk_pixbuf_loader_new",  cast(void**)& gdk_pixbuf_loader_new),
        Symbol("gdk_pixbuf_loader_get_type",  cast(void**)& gdk_pixbuf_loader_get_type),
        Symbol("gdk_pixbuf_get_file_info",  cast(void**)& gdk_pixbuf_get_file_info),
        Symbol("gdk_pixbuf_format_get_license",  cast(void**)& gdk_pixbuf_format_get_license),
        Symbol("gdk_pixbuf_format_set_disabled",  cast(void**)& gdk_pixbuf_format_set_disabled),
        Symbol("gdk_pixbuf_format_is_disabled",  cast(void**)& gdk_pixbuf_format_is_disabled),
        Symbol("gdk_pixbuf_format_is_scalable",  cast(void**)& gdk_pixbuf_format_is_scalable),
        Symbol("gdk_pixbuf_format_is_writable",  cast(void**)& gdk_pixbuf_format_is_writable),
        Symbol("gdk_pixbuf_format_get_extensions",  cast(void**)& gdk_pixbuf_format_get_extensions),
        Symbol("gdk_pixbuf_format_get_mime_types",  cast(void**)& gdk_pixbuf_format_get_mime_types),
        Symbol("gdk_pixbuf_format_get_description",  cast(void**)& gdk_pixbuf_format_get_description),
        Symbol("gdk_pixbuf_format_get_name",  cast(void**)& gdk_pixbuf_format_get_name),
        Symbol("gdk_pixbuf_get_formats",  cast(void**)& gdk_pixbuf_get_formats),
        Symbol("gdk_pixbuf_simple_anim_add_frame",  cast(void**)& gdk_pixbuf_simple_anim_add_frame),
        Symbol("gdk_pixbuf_simple_anim_new",  cast(void**)& gdk_pixbuf_simple_anim_new),
        Symbol("gdk_pixbuf_simple_anim_iter_get_type",  cast(void**)& gdk_pixbuf_simple_anim_iter_get_type),
        Symbol("gdk_pixbuf_simple_anim_get_type",  cast(void**)& gdk_pixbuf_simple_anim_get_type),
        Symbol("gdk_pixbuf_animation_iter_advance",  cast(void**)& gdk_pixbuf_animation_iter_advance),
        Symbol("gdk_pixbuf_animation_iter_on_currently_loading_frame",  cast(void**)& gdk_pixbuf_animation_iter_on_currently_loading_frame),
        Symbol("gdk_pixbuf_animation_iter_get_pixbuf",  cast(void**)& gdk_pixbuf_animation_iter_get_pixbuf),
        Symbol("gdk_pixbuf_animation_iter_get_delay_time",  cast(void**)& gdk_pixbuf_animation_iter_get_delay_time),
        Symbol("gdk_pixbuf_animation_iter_get_type",  cast(void**)& gdk_pixbuf_animation_iter_get_type),
        Symbol("gdk_pixbuf_animation_get_iter",  cast(void**)& gdk_pixbuf_animation_get_iter),
        Symbol("gdk_pixbuf_animation_get_static_image",  cast(void**)& gdk_pixbuf_animation_get_static_image),
        Symbol("gdk_pixbuf_animation_is_static_image",  cast(void**)& gdk_pixbuf_animation_is_static_image),
        Symbol("gdk_pixbuf_animation_get_height",  cast(void**)& gdk_pixbuf_animation_get_height),
        Symbol("gdk_pixbuf_animation_get_width",  cast(void**)& gdk_pixbuf_animation_get_width),
        Symbol("gdk_pixbuf_animation_unref",  cast(void**)& gdk_pixbuf_animation_unref),
        Symbol("gdk_pixbuf_animation_ref",  cast(void**)& gdk_pixbuf_animation_ref),
        Symbol("gdk_pixbuf_animation_new_from_file",  cast(void**)& gdk_pixbuf_animation_new_from_file),
        Symbol("gdk_pixbuf_animation_get_type",  cast(void**)& gdk_pixbuf_animation_get_type),
        Symbol("gdk_pixbuf_flip",  cast(void**)& gdk_pixbuf_flip),
        Symbol("gdk_pixbuf_rotate_simple",  cast(void**)& gdk_pixbuf_rotate_simple),
        Symbol("gdk_pixbuf_composite_color_simple",  cast(void**)& gdk_pixbuf_composite_color_simple),
        Symbol("gdk_pixbuf_scale_simple",  cast(void**)& gdk_pixbuf_scale_simple),
        Symbol("gdk_pixbuf_composite_color",  cast(void**)& gdk_pixbuf_composite_color),
        Symbol("gdk_pixbuf_composite",  cast(void**)& gdk_pixbuf_composite),
        Symbol("gdk_pixbuf_scale",  cast(void**)& gdk_pixbuf_scale),
        Symbol("gdk_pixbuf_get_option",  cast(void**)& gdk_pixbuf_get_option),
        Symbol("gdk_pixbuf_apply_embedded_orientation",  cast(void**)& gdk_pixbuf_apply_embedded_orientation),
        Symbol("gdk_pixbuf_saturate_and_pixelate",  cast(void**)& gdk_pixbuf_saturate_and_pixelate),
        Symbol("gdk_pixbuf_copy_area",  cast(void**)& gdk_pixbuf_copy_area),
        Symbol("gdk_pixbuf_add_alpha",  cast(void**)& gdk_pixbuf_add_alpha),
        Symbol("gdk_pixbuf_save_to_bufferv",  cast(void**)& gdk_pixbuf_save_to_bufferv),
        Symbol("gdk_pixbuf_save_to_buffer",  cast(void**)& gdk_pixbuf_save_to_buffer),
        Symbol("gdk_pixbuf_save_to_callbackv",  cast(void**)& gdk_pixbuf_save_to_callbackv),
        Symbol("gdk_pixbuf_save_to_callback",  cast(void**)& gdk_pixbuf_save_to_callback),
        Symbol("gdk_pixbuf_savev",  cast(void**)& gdk_pixbuf_savev),
        Symbol("gdk_pixbuf_save",  cast(void**)& gdk_pixbuf_save),
        Symbol("gdk_pixbuf_fill",  cast(void**)& gdk_pixbuf_fill),
        Symbol("gdk_pixbuf_new_from_inline",  cast(void**)& gdk_pixbuf_new_from_inline),
        Symbol("gdk_pixbuf_new_from_xpm_data",  cast(void**)& gdk_pixbuf_new_from_xpm_data),
        Symbol("gdk_pixbuf_new_from_data",  cast(void**)& gdk_pixbuf_new_from_data),
        Symbol("gdk_pixbuf_new_from_file_at_scale",  cast(void**)& gdk_pixbuf_new_from_file_at_scale),
        Symbol("gdk_pixbuf_new_from_file_at_size",  cast(void**)& gdk_pixbuf_new_from_file_at_size),
        Symbol("gdk_pixbuf_new_from_file",  cast(void**)& gdk_pixbuf_new_from_file),
        Symbol("gdk_pixbuf_new_subpixbuf",  cast(void**)& gdk_pixbuf_new_subpixbuf),
        Symbol("gdk_pixbuf_copy",  cast(void**)& gdk_pixbuf_copy),
        Symbol("gdk_pixbuf_new",  cast(void**)& gdk_pixbuf_new),
        Symbol("gdk_pixbuf_get_rowstride",  cast(void**)& gdk_pixbuf_get_rowstride),
        Symbol("gdk_pixbuf_get_height",  cast(void**)& gdk_pixbuf_get_height),
        Symbol("gdk_pixbuf_get_width",  cast(void**)& gdk_pixbuf_get_width),
        Symbol("gdk_pixbuf_get_pixels",  cast(void**)& gdk_pixbuf_get_pixels),
        Symbol("gdk_pixbuf_get_bits_per_sample",  cast(void**)& gdk_pixbuf_get_bits_per_sample),
        Symbol("gdk_pixbuf_get_has_alpha",  cast(void**)& gdk_pixbuf_get_has_alpha),
        Symbol("gdk_pixbuf_get_n_channels",  cast(void**)& gdk_pixbuf_get_n_channels),
        Symbol("gdk_pixbuf_get_colorspace",  cast(void**)& gdk_pixbuf_get_colorspace),
        Symbol("gdk_pixbuf_unref",  cast(void**)& gdk_pixbuf_unref),
        Symbol("gdk_pixbuf_ref",  cast(void**)& gdk_pixbuf_ref),
        Symbol("gdk_pixbuf_get_type",  cast(void**)& gdk_pixbuf_get_type),
        Symbol("gdk_pixbuf_error_quark",  cast(void**)& gdk_pixbuf_error_quark),
        Symbol("gdk_pixbuf_version",  cast(void**)& gdk_pixbuf_version),
        Symbol("gdk_pixbuf_micro_version",  cast(void**)& gdk_pixbuf_micro_version),
        Symbol("gdk_pixbuf_minor_version",  cast(void**)& gdk_pixbuf_minor_version),
        Symbol("gdk_pixbuf_major_version",  cast(void**)& gdk_pixbuf_major_version),
        Symbol("gdk_rgb_colormap_ditherable",  cast(void**)& gdk_rgb_colormap_ditherable),
        Symbol("gdk_rgb_ditherable",  cast(void**)& gdk_rgb_ditherable),
        Symbol("gdk_rgb_get_visual",  cast(void**)& gdk_rgb_get_visual),
        Symbol("gdk_rgb_get_colormap",  cast(void**)& gdk_rgb_get_colormap),
        Symbol("gdk_rgb_set_min_colors",  cast(void**)& gdk_rgb_set_min_colors),
        Symbol("gdk_rgb_set_install",  cast(void**)& gdk_rgb_set_install),
        Symbol("gdk_rgb_set_verbose",  cast(void**)& gdk_rgb_set_verbose),
        Symbol("gdk_rgb_cmap_free",  cast(void**)& gdk_rgb_cmap_free),
        Symbol("gdk_rgb_cmap_new",  cast(void**)& gdk_rgb_cmap_new),
        Symbol("gdk_draw_indexed_image",  cast(void**)& gdk_draw_indexed_image),
        Symbol("gdk_draw_gray_image",  cast(void**)& gdk_draw_gray_image),
        Symbol("gdk_draw_rgb_32_image_dithalign",  cast(void**)& gdk_draw_rgb_32_image_dithalign),
        Symbol("gdk_draw_rgb_32_image",  cast(void**)& gdk_draw_rgb_32_image),
        Symbol("gdk_draw_rgb_image_dithalign",  cast(void**)& gdk_draw_rgb_image_dithalign),
        Symbol("gdk_draw_rgb_image",  cast(void**)& gdk_draw_rgb_image),
        Symbol("gdk_rgb_find_color",  cast(void**)& gdk_rgb_find_color),
        Symbol("gdk_rgb_gc_set_background",  cast(void**)& gdk_rgb_gc_set_background),
        Symbol("gdk_rgb_gc_set_foreground",  cast(void**)& gdk_rgb_gc_set_foreground),
        Symbol("gdk_rgb_xpixel_from_rgb",  cast(void**)& gdk_rgb_xpixel_from_rgb),
        Symbol("gdk_rgb_init",  cast(void**)& gdk_rgb_init),
        Symbol("gdk_colors_free",  cast(void**)& gdk_colors_free),
        Symbol("gdk_colors_alloc",  cast(void**)& gdk_colors_alloc),
        Symbol("gdk_color_change",  cast(void**)& gdk_color_change),
        Symbol("gdk_color_alloc",  cast(void**)& gdk_color_alloc),
        Symbol("gdk_color_black",  cast(void**)& gdk_color_black),
        Symbol("gdk_color_white",  cast(void**)& gdk_color_white),
        Symbol("gdk_colors_store",  cast(void**)& gdk_colors_store),
        Symbol("gdk_color_get_type",  cast(void**)& gdk_color_get_type),
        Symbol("gdk_color_to_string",  cast(void**)& gdk_color_to_string),
        Symbol("gdk_color_equal",  cast(void**)& gdk_color_equal),
        Symbol("gdk_color_hash",  cast(void**)& gdk_color_hash),
        Symbol("gdk_color_parse",  cast(void**)& gdk_color_parse),
        Symbol("gdk_color_free",  cast(void**)& gdk_color_free),
        Symbol("gdk_color_copy",  cast(void**)& gdk_color_copy),
        Symbol("gdk_colormap_get_visual",  cast(void**)& gdk_colormap_get_visual),
        Symbol("gdk_colormap_query_color",  cast(void**)& gdk_colormap_query_color),
        Symbol("gdk_colormap_free_colors",  cast(void**)& gdk_colormap_free_colors),
        Symbol("gdk_colormap_alloc_color",  cast(void**)& gdk_colormap_alloc_color),
        Symbol("gdk_colormap_alloc_colors",  cast(void**)& gdk_colormap_alloc_colors),
        Symbol("gdk_colormap_change",  cast(void**)& gdk_colormap_change),
        Symbol("gdk_colormap_get_system_size",  cast(void**)& gdk_colormap_get_system_size),
        Symbol("gdk_colormap_get_screen",  cast(void**)& gdk_colormap_get_screen),
        Symbol("gdk_colormap_get_system",  cast(void**)& gdk_colormap_get_system),
        Symbol("gdk_colormap_unref",  cast(void**)& gdk_colormap_unref),
        Symbol("gdk_colormap_ref",  cast(void**)& gdk_colormap_ref),
        Symbol("gdk_colormap_new",  cast(void**)& gdk_colormap_new),
        Symbol("gdk_colormap_get_type",  cast(void**)& gdk_colormap_get_type)
    ];
}

} else { // version(DYNLINK)
extern (C) guint gdk_threads_add_timeout(guint, _BCD_func__5647, void *);
extern (C) guint gdk_threads_add_timeout_full(gint, guint, _BCD_func__5647, void *, _BCD_func__4634);
extern (C) guint gdk_threads_add_idle(_BCD_func__5647, void *);
extern (C) guint gdk_threads_add_idle_full(gint, _BCD_func__5647, void *, _BCD_func__4634);
extern (C) void gdk_threads_set_lock_functions(_BCD_func__5298, _BCD_func__5298);
extern (C) void gdk_threads_init();
extern (C) void gdk_threads_leave();
extern (C) void gdk_threads_enter();
extern (C) extern _BCD_func__5298 gdk_threads_unlock;
extern (C) extern _BCD_func__5298 gdk_threads_lock;
extern (C) extern void * gdk_threads_mutex;
extern (C) void gdk_notify_startup_complete_with_id(char *);
extern (C) void gdk_notify_startup_complete();
extern (C) gint gdk_event_send_client_message_for_display(_GdkDisplay *, _GdkEvent *, guint);
extern (C) void gdk_event_send_clientmessage_toall(_GdkEvent *);
extern (C) gint gdk_event_send_client_message(_GdkEvent *, guint);
extern (C) gint gdk_mbstowcs(guint *, char *, gint);
extern (C) char * gdk_wcstombs(guint *);
extern (C) GType gdk_rectangle_get_type();
extern (C) void gdk_rectangle_union(_GdkRectangle *, _GdkRectangle *, _GdkRectangle *);
extern (C) gint gdk_rectangle_intersect(_GdkRectangle *, _GdkRectangle *, _GdkRectangle *);
extern (C) void gdk_set_double_click_time(guint);
extern (C) void gdk_flush();
extern (C) void gdk_beep();
extern (C) gint gdk_screen_height_mm();
extern (C) gint gdk_screen_width_mm();
extern (C) gint gdk_screen_height();
extern (C) gint gdk_screen_width();
extern (C) gint gdk_pointer_is_grabbed();
extern (C) void gdk_keyboard_ungrab(guint32);
extern (C) void gdk_pointer_ungrab(guint32);
extern (C) gint gdk_keyboard_grab_info_libgtk_only(_GdkDisplay *, _GdkDrawable * *, gint *);
extern (C) gint gdk_pointer_grab_info_libgtk_only(_GdkDisplay *, _GdkDrawable * *, gint *);
extern (C) gint gdk_keyboard_grab(_GdkDrawable *, gint, guint32);
extern (C) gint gdk_pointer_grab(_GdkDrawable *, gint, gint, _GdkDrawable *, _GdkCursor *, guint32);
extern (C) void gdk_input_remove(gint);
extern (C) gint gdk_input_add(gint, gint, _BCD_func__4635, void *);
extern (C) gint gdk_input_add_full(gint, gint, _BCD_func__4635, void *, _BCD_func__4634);
extern (C) char * gdk_get_display_arg_name();
extern (C) char * gdk_get_display();
extern (C) gint gdk_get_use_xshm();
extern (C) void gdk_set_use_xshm(gint);
extern (C) gint gdk_error_trap_pop();
extern (C) void gdk_error_trap_push();
extern (C) void gdk_set_program_class(char *);
extern (C) char * gdk_get_program_class();
extern (C) char * gdk_set_locale();
extern (C) void gdk_exit(gint);
extern (C) void gdk_pre_parse_libgtk_only();
extern (C) void gdk_add_option_entries_libgtk_only(void *);
extern (C) gint gdk_init_check(gint *, char * * *);
extern (C) void gdk_init(gint *, char * * *);
extern (C) void gdk_parse_args(gint *, char * * *);
extern (C) _GdkDrawable * gdk_get_default_root_window();
extern (C) _GdkPointerHooks * gdk_set_pointer_hooks(_GdkPointerHooks *);
extern (C) void gdk_window_configure_finished(_GdkDrawable *);
extern (C) void gdk_window_enable_synchronized_configure(_GdkDrawable *);
extern (C) void gdk_window_get_internal_paint_info(_GdkDrawable *, _GdkDrawable * *, gint *, gint *);
extern (C) void gdk_window_constrain_size(_GdkGeometry *, guint, gint, gint, gint *, gint *);
extern (C) void gdk_window_set_debug_updates(gint);
extern (C) void gdk_window_process_updates(_GdkDrawable *, gint);
extern (C) void gdk_window_process_all_updates();
extern (C) void gdk_window_thaw_toplevel_updates_libgtk_only(_GdkDrawable *);
extern (C) void gdk_window_freeze_toplevel_updates_libgtk_only(_GdkDrawable *);
extern (C) void gdk_window_thaw_updates(_GdkDrawable *);
extern (C) void gdk_window_freeze_updates(_GdkDrawable *);
extern (C) void * gdk_window_get_update_area(_GdkDrawable *);
extern (C) void gdk_window_invalidate_maybe_recurse(_GdkDrawable *, void *, _BCD_func__6008, void *);
extern (C) void gdk_window_invalidate_region(_GdkDrawable *, void *, gint);
extern (C) void gdk_window_invalidate_rect(_GdkDrawable *, _GdkRectangle *, gint);
extern (C) void gdk_window_begin_move_drag(_GdkDrawable *, gint, gint, gint, guint32);
extern (C) void gdk_window_begin_resize_drag(_GdkDrawable *, gint, gint, gint, gint, guint32);
extern (C) void gdk_window_register_dnd(_GdkDrawable *);
extern (C) void gdk_window_set_opacity(_GdkDrawable *, double);
extern (C) void gdk_window_set_keep_below(_GdkDrawable *, gint);
extern (C) void gdk_window_set_keep_above(_GdkDrawable *, gint);
extern (C) void gdk_window_unfullscreen(_GdkDrawable *);
extern (C) void gdk_window_fullscreen(_GdkDrawable *);
extern (C) void gdk_window_unmaximize(_GdkDrawable *);
extern (C) void gdk_window_maximize(_GdkDrawable *);
extern (C) void gdk_window_unstick(_GdkDrawable *);
extern (C) void gdk_window_stick(_GdkDrawable *);
extern (C) void gdk_window_deiconify(_GdkDrawable *);
extern (C) void gdk_window_iconify(_GdkDrawable *);
extern (C) void gdk_window_beep(_GdkDrawable *);
extern (C) _GList * gdk_window_get_toplevels();
extern (C) void gdk_window_set_functions(_GdkDrawable *, gint);
extern (C) gint gdk_window_get_decorations(_GdkDrawable *, gint *);
extern (C) void gdk_window_set_decorations(_GdkDrawable *, gint);
extern (C) _GdkDrawable * gdk_window_get_group(_GdkDrawable *);
extern (C) void gdk_window_set_group(_GdkDrawable *, _GdkDrawable *);
extern (C) void gdk_window_set_icon_name(_GdkDrawable *, char *);
extern (C) void gdk_window_set_icon(_GdkDrawable *, _GdkDrawable *, _GdkDrawable *, _GdkDrawable *);
extern (C) void gdk_window_set_icon_list(_GdkDrawable *, _GList *);
extern (C) void gdk_window_set_events(_GdkDrawable *, gint);
extern (C) gint gdk_window_get_events(_GdkDrawable *);
extern (C) _GList * gdk_window_peek_children(_GdkDrawable *);
extern (C) _GList * gdk_window_get_children(_GdkDrawable *);
extern (C) _GdkDrawable * gdk_window_get_toplevel(_GdkDrawable *);
extern (C) _GdkDrawable * gdk_window_get_parent(_GdkDrawable *);
extern (C) _GdkDrawable * gdk_window_get_pointer(_GdkDrawable *, gint *, gint *, gint *);
extern (C) void gdk_window_get_frame_extents(_GdkDrawable *, _GdkRectangle *);
extern (C) void gdk_window_get_root_origin(_GdkDrawable *, gint *, gint *);
extern (C) gint gdk_window_get_deskrelative_origin(_GdkDrawable *, gint *, gint *);
extern (C) gint gdk_window_get_origin(_GdkDrawable *, gint *, gint *);
extern (C) void gdk_window_get_position(_GdkDrawable *, gint *, gint *);
extern (C) void gdk_window_get_geometry(_GdkDrawable *, gint *, gint *, gint *, gint *, gint *);
extern (C) void gdk_window_get_user_data(_GdkDrawable *, void * *);
extern (C) void gdk_window_set_cursor(_GdkDrawable *, _GdkCursor *);
extern (C) void gdk_window_set_back_pixmap(_GdkDrawable *, _GdkDrawable *, gint);
extern (C) void gdk_window_set_background(_GdkDrawable *, _GdkColor *);
extern (C) void gdk_window_set_transient_for(_GdkDrawable *, _GdkDrawable *);
extern (C) void gdk_window_set_startup_id(_GdkDrawable *, char *);
extern (C) void gdk_window_set_role(_GdkDrawable *, char *);
extern (C) void gdk_window_set_title(_GdkDrawable *, char *);
extern (C) void gdk_window_end_paint(_GdkDrawable *);
extern (C) void gdk_window_begin_paint_region(_GdkDrawable *, void *);
extern (C) void gdk_window_begin_paint_rect(_GdkDrawable *, _GdkRectangle *);
extern (C) void gdk_set_sm_client_id(char *);
extern (C) void gdk_window_set_geometry_hints(_GdkDrawable *, _GdkGeometry *, gint);
extern (C) void gdk_window_set_urgency_hint(_GdkDrawable *, gint);
extern (C) void gdk_window_set_skip_pager_hint(_GdkDrawable *, gint);
extern (C) void gdk_window_set_skip_taskbar_hint(_GdkDrawable *, gint);
extern (C) void gdk_window_set_modal_hint(_GdkDrawable *, gint);
extern (C) gint gdk_window_get_type_hint(_GdkDrawable *);
extern (C) void gdk_window_set_type_hint(_GdkDrawable *, gint);
extern (C) void gdk_window_set_hints(_GdkDrawable *, gint, gint, gint, gint, gint, gint, gint);
extern (C) _GdkDrawable * gdk_window_lookup_for_display(_GdkDisplay *, guint);
extern (C) _GdkDrawable * gdk_window_foreign_new_for_display(_GdkDisplay *, guint);
extern (C) _GdkDrawable * gdk_window_lookup(GdkNativeWindow);
extern (C) _GdkDrawable * gdk_window_foreign_new(guint);
extern (C) gint gdk_window_set_static_gravities(_GdkDrawable *, gint);
extern (C) gint gdk_window_get_state(_GdkDrawable *);
extern (C) gint gdk_window_is_viewable(_GdkDrawable *);
extern (C) gint gdk_window_is_visible(_GdkDrawable *);
extern (C) void gdk_window_merge_child_input_shapes(_GdkDrawable *);
extern (C) void gdk_window_set_child_input_shapes(_GdkDrawable *);
extern (C) void gdk_window_input_shape_combine_region(_GdkDrawable *, void *, gint, gint);
extern (C) void gdk_window_input_shape_combine_mask(_GdkDrawable *, _GdkDrawable *, gint, gint);
extern (C) void gdk_window_merge_child_shapes(_GdkDrawable *);
extern (C) void gdk_window_set_composited(_GdkDrawable *, gint);
extern (C) void gdk_window_set_child_shapes(_GdkDrawable *);
extern (C) void gdk_window_shape_combine_region(_GdkDrawable *, void *, gint, gint);
extern (C) void gdk_window_shape_combine_mask(_GdkDrawable *, _GdkDrawable *, gint, gint);
extern (C) void gdk_window_move_region(_GdkDrawable *, void *, gint, gint);
extern (C) void gdk_window_scroll(_GdkDrawable *, gint, gint);
extern (C) void gdk_window_remove_filter(_GdkDrawable *, _BCD_func__4335, void *);
extern (C) void gdk_window_add_filter(_GdkDrawable *, _BCD_func__4335, void *);
extern (C) void gdk_window_set_focus_on_map(_GdkDrawable *, gint);
extern (C) void gdk_window_set_accept_focus(_GdkDrawable *, gint);
extern (C) void gdk_window_set_override_redirect(_GdkDrawable *, gint);
extern (C) void gdk_window_set_user_data(_GdkDrawable *, void *);
extern (C) void gdk_window_focus(_GdkDrawable *, guint32);
extern (C) void gdk_window_lower(_GdkDrawable *);
extern (C) void gdk_window_raise(_GdkDrawable *);
extern (C) void gdk_window_clear_area_e(_GdkDrawable *, gint, gint, gint, gint);
extern (C) void gdk_window_clear_area(_GdkDrawable *, gint, gint, gint, gint);
extern (C) void gdk_window_clear(_GdkDrawable *);
extern (C) void gdk_window_reparent(_GdkDrawable *, _GdkDrawable *, gint, gint);
extern (C) void gdk_window_move_resize(_GdkDrawable *, gint, gint, gint, gint);
extern (C) void gdk_window_resize(_GdkDrawable *, gint, gint);
extern (C) void gdk_window_move(_GdkDrawable *, gint, gint);
extern (C) void gdk_window_show_unraised(_GdkDrawable *);
extern (C) void gdk_window_withdraw(_GdkDrawable *);
extern (C) void gdk_window_hide(_GdkDrawable *);
extern (C) void gdk_window_show(_GdkDrawable *);
extern (C) _GdkDrawable * gdk_window_at_pointer(gint *, gint *);
extern (C) gint gdk_window_get_window_type(_GdkDrawable *);
extern (C) void gdk_window_destroy(_GdkDrawable *);
extern (C) _GdkDrawable * gdk_window_new(_GdkDrawable *, _GdkWindowAttr *, gint);
extern (C) guint gdk_window_object_get_type();
extern (C) _GdkScreen * gdk_visual_get_screen(_GdkVisual *);
extern (C) _GList * gdk_list_visuals();
extern (C) void gdk_query_visual_types(gint * *, gint *);
extern (C) void gdk_query_depths(gint * *, gint *);
extern (C) _GdkVisual * gdk_visual_get_best_with_both(gint, gint);
extern (C) _GdkVisual * gdk_visual_get_best_with_type(gint);
extern (C) _GdkVisual * gdk_visual_get_best_with_depth(gint);
extern (C) _GdkVisual * gdk_visual_get_best();
extern (C) _GdkVisual * gdk_visual_get_system();
extern (C) gint gdk_visual_get_best_type();
extern (C) gint gdk_visual_get_best_depth();
extern (C) GType gdk_visual_get_type();
extern (C) gint gdk_spawn_command_line_on_screen(_GdkScreen *, char *, _GError * *);
extern (C) gint gdk_spawn_on_screen_with_pipes(_GdkScreen *, char *, char * *, char * *, gint, _BCD_func__4634, void *, gint *, gint *, gint *, gint *, _GError * *);
extern (C) gint gdk_spawn_on_screen(_GdkScreen *, char *, char * *, char * *, gint, _BCD_func__4634, void *, gint *, _GError * *);
extern (C) void gdk_selection_send_notify_for_display(_GdkDisplay *, guint, void *, void *, void *, guint32);
extern (C) void gdk_selection_send_notify(guint, void *, void *, void *, guint32);
extern (C) gint gdk_selection_property_get(_GdkDrawable *, char * *, void * *, gint *);
extern (C) void gdk_selection_convert(_GdkDrawable *, void *, void *, guint32);
extern (C) _GdkDrawable * gdk_selection_owner_get_for_display(_GdkDisplay *, void *);
extern (C) gint gdk_selection_owner_set_for_display(_GdkDisplay *, _GdkDrawable *, void *, guint32, gint);
extern (C) _GdkDrawable * gdk_selection_owner_get(void *);
extern (C) gint gdk_selection_owner_set(_GdkDrawable *, void *, guint32, gint);
extern (C) _GList * gdk_screen_get_window_stack(_GdkScreen *);
extern (C) _GdkDrawable * gdk_screen_get_active_window(_GdkScreen *);
extern (C) double gdk_screen_get_resolution(_GdkScreen *);
extern (C) void gdk_screen_set_resolution(_GdkScreen *, double);
extern (C) void * gdk_screen_get_font_options(_GdkScreen *);
extern (C) void gdk_screen_set_font_options(_GdkScreen *, void *);
extern (C) gint gdk_screen_get_setting(_GdkScreen *, char *, _GValue *);
extern (C) _GdkScreen * gdk_screen_get_default();
extern (C) void gdk_screen_broadcast_client_message(_GdkScreen *, _GdkEvent *);
extern (C) gint gdk_screen_get_monitor_at_window(_GdkScreen *, _GdkDrawable *);
extern (C) gint gdk_screen_get_monitor_at_point(_GdkScreen *, gint, gint);
extern (C) void gdk_screen_get_monitor_geometry(_GdkScreen *, gint, _GdkRectangle *);
extern (C) gint gdk_screen_get_n_monitors(_GdkScreen *);
extern (C) char * gdk_screen_make_display_name(_GdkScreen *);
extern (C) _GList * gdk_screen_get_toplevel_windows(_GdkScreen *);
extern (C) _GList * gdk_screen_list_visuals(_GdkScreen *);
extern (C) gint gdk_screen_get_height_mm(_GdkScreen *);
extern (C) gint gdk_screen_get_width_mm(_GdkScreen *);
extern (C) gint gdk_screen_get_height(_GdkScreen *);
extern (C) gint gdk_screen_get_width(_GdkScreen *);
extern (C) gint gdk_screen_get_number(_GdkScreen *);
extern (C) _GdkDisplay * gdk_screen_get_display(_GdkScreen *);
extern (C) _GdkDrawable * gdk_screen_get_root_window(_GdkScreen *);
extern (C) gint gdk_screen_is_composited(_GdkScreen *);
extern (C) _GdkVisual * gdk_screen_get_rgba_visual(_GdkScreen *);
extern (C) _GdkColormap * gdk_screen_get_rgba_colormap(_GdkScreen *);
extern (C) _GdkVisual * gdk_screen_get_rgb_visual(_GdkScreen *);
extern (C) _GdkColormap * gdk_screen_get_rgb_colormap(_GdkScreen *);
extern (C) _GdkVisual * gdk_screen_get_system_visual(_GdkScreen *);
extern (C) _GdkColormap * gdk_screen_get_system_colormap(_GdkScreen *);
extern (C) void gdk_screen_set_default_colormap(_GdkScreen *, _GdkColormap *);
extern (C) _GdkColormap * gdk_screen_get_default_colormap(_GdkScreen *);
extern (C) GType gdk_screen_get_type();
extern (C) void gdk_region_spans_intersect_foreach(void *, _GdkSpan *, gint, gint, _BCD_func__4157, void *);
extern (C) void gdk_region_xor(void *, void *);
extern (C) void gdk_region_subtract(void *, void *);
extern (C) void gdk_region_union(void *, void *);
extern (C) void gdk_region_intersect(void *, void *);
extern (C) void gdk_region_union_with_rect(void *, _GdkRectangle *);
extern (C) void gdk_region_shrink(void *, gint, gint);
extern (C) void gdk_region_offset(void *, gint, gint);
extern (C) gint gdk_region_rect_in(void *, _GdkRectangle *);
extern (C) gint gdk_region_point_in(void *, gint, gint);
extern (C) gint gdk_region_equal(void *, void *);
extern (C) gint gdk_region_empty(void *);
extern (C) void gdk_region_get_rectangles(void *, _GdkRectangle * *, gint *);
extern (C) void gdk_region_get_clipbox(void *, _GdkRectangle *);
extern (C) void gdk_region_destroy(void *);
extern (C) void * gdk_region_rectangle(_GdkRectangle *);
extern (C) void * gdk_region_copy(void *);
extern (C) void * gdk_region_polygon(_GdkPoint *, gint, gint);
extern (C) void * gdk_region_new();
extern (C) void gdk_free_compound_text(char *);
extern (C) void gdk_free_text_list(char * *);
extern (C) gint gdk_utf8_to_compound_text_for_display(_GdkDisplay *, char *, void * *, gint *, char * *, gint *);
extern (C) gint gdk_string_to_compound_text_for_display(_GdkDisplay *, char *, void * *, gint *, char * *, gint *);
extern (C) char * gdk_utf8_to_string_target(char *);
extern (C) gint gdk_text_property_to_utf8_list_for_display(_GdkDisplay *, void *, gint, char *, gint, char * * *);
extern (C) gint gdk_text_property_to_text_list_for_display(_GdkDisplay *, void *, gint, char *, gint, char * * *);
extern (C) gint gdk_string_to_compound_text(char *, void * *, gint *, char * *, gint *);
extern (C) gint gdk_utf8_to_compound_text(char *, void * *, gint *, char * *, gint *);
extern (C) gint gdk_text_property_to_utf8_list(void *, gint, char *, gint, char * * *);
extern (C) gint gdk_text_property_to_text_list(void *, gint, char *, gint, char * * *);
extern (C) void gdk_property_delete(_GdkDrawable *, void *);
extern (C) void gdk_property_change(_GdkDrawable *, void *, void *, gint, gint, char *, gint);
extern (C) gint gdk_property_get(_GdkDrawable *, void *, void *, gulong, gulong, gint, void * *, gint *, gint *, char * *);
extern (C) char * gdk_atom_name(void *);
extern (C) void * gdk_atom_intern_static_string(in char *);
extern (C) void * gdk_atom_intern(in char *, gint);
extern (C) _GdkDrawable * gdk_pixmap_foreign_new_for_screen(_GdkScreen *, guint, gint, gint, gint);
extern (C) _GdkDrawable * gdk_pixmap_lookup_for_display(_GdkDisplay *, guint);
extern (C) _GdkDrawable * gdk_pixmap_foreign_new_for_display(_GdkDisplay *, guint);
extern (C) _GdkDrawable * gdk_pixmap_lookup(guint);
extern (C) _GdkDrawable * gdk_pixmap_foreign_new(guint);
extern (C) _GdkDrawable * gdk_pixmap_colormap_create_from_xpm_d(_GdkDrawable *, _GdkColormap *, _GdkDrawable * *, _GdkColor *, char * *);
extern (C) _GdkDrawable * gdk_pixmap_create_from_xpm_d(_GdkDrawable *, _GdkDrawable * *, _GdkColor *, char * *);
extern (C) _GdkDrawable * gdk_pixmap_colormap_create_from_xpm(_GdkDrawable *, _GdkColormap *, _GdkDrawable * *, _GdkColor *, char *);
extern (C) _GdkDrawable * gdk_pixmap_create_from_xpm(_GdkDrawable *, _GdkDrawable * *, _GdkColor *, char *);
extern (C) _GdkDrawable * gdk_pixmap_create_from_data(_GdkDrawable *, char *, gint, gint, gint, _GdkColor *, _GdkColor *);
extern (C) _GdkDrawable * gdk_bitmap_create_from_data(_GdkDrawable *, in char *, gint, gint);
extern (C) _GdkDrawable * gdk_pixmap_new(_GdkDrawable *, gint, gint, gint);
extern (C) guint gdk_pixmap_get_type();
extern (C) _PangoAttribute * gdk_pango_attr_emboss_color_new(_GdkColor *);
extern (C) _PangoAttribute * gdk_pango_attr_embossed_new(gint);
extern (C) _PangoAttribute * gdk_pango_attr_stipple_new(_GdkDrawable *);
extern (C) void * gdk_pango_layout_get_clip_region(void *, gint, gint, gint *, gint);
extern (C) void * gdk_pango_layout_line_get_clip_region(_PangoLayoutLine *, gint, gint, gint *, gint);
extern (C) void gdk_pango_context_set_colormap(void *, _GdkColormap *);
extern (C) void * gdk_pango_context_get();
extern (C) void * gdk_pango_context_get_for_screen(_GdkScreen *);
extern (C) void gdk_pango_renderer_set_override_color(_GdkPangoRenderer *, gint, _GdkColor *);
extern (C) void gdk_pango_renderer_set_stipple(_GdkPangoRenderer *, gint, _GdkDrawable *);
extern (C) void gdk_pango_renderer_set_gc(_GdkPangoRenderer *, _GdkGC *);
extern (C) void gdk_pango_renderer_set_drawable(_GdkPangoRenderer *, _GdkDrawable *);
extern (C) _PangoRenderer * gdk_pango_renderer_get_default(_GdkScreen *);
extern (C) _PangoRenderer * gdk_pango_renderer_new(_GdkScreen *);
extern (C) guint gdk_pango_renderer_get_type();
extern (C) _GSList * gdk_display_manager_list_displays(void *);
extern (C) void gdk_display_manager_set_default_display(void *, _GdkDisplay *);
extern (C) _GdkDisplay * gdk_display_manager_get_default_display(void *);
extern (C) void * gdk_display_manager_get();
extern (C) GType gdk_display_manager_get_type();
extern (C) guint gdk_unicode_to_keyval(guint32);
extern (C) guint32 gdk_keyval_to_unicode(guint);
extern (C) gint gdk_keyval_is_lower(guint);
extern (C) gint gdk_keyval_is_upper(guint);
extern (C) guint gdk_keyval_to_lower(guint);
extern (C) guint gdk_keyval_to_upper(guint);
extern (C) void gdk_keyval_convert_case(guint, guint *, guint *);
extern (C) guint gdk_keyval_from_name(char *);
extern (C) char * gdk_keyval_name(guint);
extern (C) gint gdk_keymap_have_bidi_layouts(_GdkKeymap *);
extern (C) gint gdk_keymap_get_direction(_GdkKeymap *);
extern (C) gint gdk_keymap_get_entries_for_keycode(_GdkKeymap *, guint, _GdkKeymapKey * *, guint * *, gint *);
extern (C) gint gdk_keymap_get_entries_for_keyval(_GdkKeymap *, guint, _GdkKeymapKey * *, gint *);
extern (C) gint gdk_keymap_translate_keyboard_state(_GdkKeymap *, guint, gint, gint, guint *, gint *, gint *, gint *);
extern (C) guint gdk_keymap_lookup_key(_GdkKeymap *, _GdkKeymapKey *);
extern (C) _GdkKeymap * gdk_keymap_get_for_display(_GdkDisplay *);
extern (C) _GdkKeymap * gdk_keymap_get_default();
extern (C) GType gdk_keymap_get_type();
extern (C) _GdkColormap * gdk_image_get_colormap(_GdkImage *);
extern (C) void gdk_image_set_colormap(_GdkImage *, _GdkColormap *);
extern (C) guint gdk_image_get_pixel(_GdkImage *, gint, gint);
extern (C) void gdk_image_put_pixel(_GdkImage *, gint, gint, guint);
extern (C) void gdk_image_unref(_GdkImage *);
extern (C) _GdkImage * gdk_image_ref(_GdkImage *);
extern (C) _GdkImage * gdk_image_get(_GdkDrawable *, gint, gint, gint, gint);
extern (C) _GdkImage * gdk_image_new(gint, _GdkVisual *, gint, gint);
extern (C) guint gdk_image_get_type();
extern (C) _GdkDisplay * gdk_font_get_display(_GdkFont *);
extern (C) void gdk_string_extents(_GdkFont *, char *, gint *, gint *, gint *, gint *, gint *);
extern (C) void gdk_text_extents_wc(_GdkFont *, guint *, gint, gint *, gint *, gint *, gint *, gint *);
extern (C) void gdk_text_extents(_GdkFont *, char *, gint, gint *, gint *, gint *, gint *, gint *);
extern (C) gint gdk_char_height(_GdkFont *, char);
extern (C) gint gdk_text_height(_GdkFont *, char *, gint);
extern (C) gint gdk_string_height(_GdkFont *, char *);
extern (C) gint gdk_char_measure(_GdkFont *, char);
extern (C) gint gdk_text_measure(_GdkFont *, char *, gint);
extern (C) gint gdk_string_measure(_GdkFont *, char *);
extern (C) gint gdk_char_width_wc(_GdkFont *, guint);
extern (C) gint gdk_char_width(_GdkFont *, char);
extern (C) gint gdk_text_width_wc(_GdkFont *, guint *, gint);
extern (C) gint gdk_text_width(_GdkFont *, char *, gint);
extern (C) gint gdk_string_width(_GdkFont *, char *);
extern (C) _GdkFont * gdk_font_from_description(void *);
extern (C) _GdkFont * gdk_fontset_load(char *);
extern (C) _GdkFont * gdk_font_load(char *);
extern (C) _GdkFont * gdk_font_from_description_for_display(_GdkDisplay *, void *);
extern (C) _GdkFont * gdk_fontset_load_for_display(_GdkDisplay *, char *);
extern (C) _GdkFont * gdk_font_load_for_display(_GdkDisplay *, char *);
extern (C) gint gdk_font_equal(_GdkFont *, _GdkFont *);
extern (C) gint gdk_font_id(_GdkFont *);
extern (C) void gdk_font_unref(_GdkFont *);
extern (C) _GdkFont * gdk_font_ref(_GdkFont *);
extern (C) guint gdk_font_get_type();
extern (C) guint gdk_window_edge_get_type();
extern (C) guint gdk_gravity_get_type();
extern (C) guint gdk_wm_function_get_type();
extern (C) guint gdk_wm_decoration_get_type();
extern (C) guint gdk_window_type_hint_get_type();
extern (C) guint gdk_window_hints_get_type();
extern (C) guint gdk_window_attributes_type_get_type();
extern (C) guint gdk_window_type_get_type();
extern (C) guint gdk_window_class_get_type();
extern (C) guint gdk_visual_type_get_type();
extern (C) guint gdk_grab_status_get_type();
extern (C) guint gdk_status_get_type();
extern (C) guint gdk_input_condition_get_type();
extern (C) guint gdk_modifier_type_get_type();
extern (C) guint gdk_byte_order_get_type();
extern (C) guint gdk_rgb_dither_get_type();
extern (C) guint gdk_overlap_type_get_type();
extern (C) guint gdk_fill_rule_get_type();
extern (C) guint gdk_prop_mode_get_type();
extern (C) guint gdk_axis_use_get_type();
extern (C) guint gdk_input_mode_get_type();
extern (C) guint gdk_input_source_get_type();
extern (C) guint gdk_extension_mode_get_type();
extern (C) guint gdk_image_type_get_type();
extern (C) guint gdk_gc_values_mask_get_type();
extern (C) guint gdk_subwindow_mode_get_type();
extern (C) guint gdk_line_style_get_type();
extern (C) guint gdk_join_style_get_type();
extern (C) guint gdk_function_get_type();
extern (C) guint gdk_fill_get_type();
extern (C) guint gdk_cap_style_get_type();
extern (C) guint gdk_font_type_get_type();
extern (C) guint gdk_owner_change_get_type();
extern (C) guint gdk_setting_action_get_type();
extern (C) guint gdk_window_state_get_type();
extern (C) guint gdk_property_state_get_type();
extern (C) guint gdk_crossing_mode_get_type();
extern (C) guint gdk_notify_type_get_type();
extern (C) guint gdk_scroll_direction_get_type();
extern (C) guint gdk_visibility_state_get_type();
extern (C) guint gdk_event_mask_get_type();
extern (C) guint gdk_event_type_get_type();
extern (C) guint gdk_filter_return_get_type();
extern (C) guint gdk_drag_protocol_get_type();
extern (C) guint gdk_drag_action_get_type();
extern (C) guint gdk_cursor_type_get_type();
extern (C) void * gdk_drawable_get_visible_region(_GdkDrawable *);
extern (C) void * gdk_drawable_get_clip_region(_GdkDrawable *);
extern (C) _GdkImage * gdk_drawable_copy_to_image(_GdkDrawable *, _GdkImage *, gint, gint, gint, gint, gint, gint);
extern (C) _GdkImage * gdk_drawable_get_image(_GdkDrawable *, gint, gint, gint, gint);
extern (C) void gdk_draw_trapezoids(_GdkDrawable *, _GdkGC *, _GdkTrapezoid *, gint);
extern (C) void gdk_draw_glyphs_transformed(_GdkDrawable *, _GdkGC *, _PangoMatrix *, void *, gint, gint, _PangoGlyphString *);
extern (C) void gdk_draw_layout_with_colors(_GdkDrawable *, _GdkGC *, gint, gint, void *, _GdkColor *, _GdkColor *);
extern (C) void gdk_draw_layout_line_with_colors(_GdkDrawable *, _GdkGC *, gint, gint, _PangoLayoutLine *, _GdkColor *, _GdkColor *);
extern (C) void gdk_draw_layout(_GdkDrawable *, _GdkGC *, gint, gint, void *);
extern (C) void gdk_draw_layout_line(_GdkDrawable *, _GdkGC *, gint, gint, _PangoLayoutLine *);
extern (C) void gdk_draw_glyphs(_GdkDrawable *, _GdkGC *, void *, gint, gint, _PangoGlyphString *);
extern (C) void gdk_draw_pixbuf(_GdkDrawable *, _GdkGC *, void *, gint, gint, gint, gint, gint, gint, gint, gint, gint);
extern (C) void gdk_draw_lines(_GdkDrawable *, _GdkGC *, _GdkPoint *, gint);
extern (C) void gdk_draw_segments(_GdkDrawable *, _GdkGC *, _GdkSegment *, gint);
extern (C) void gdk_draw_points(_GdkDrawable *, _GdkGC *, _GdkPoint *, gint);
extern (C) void gdk_draw_image(_GdkDrawable *, _GdkGC *, _GdkImage *, gint, gint, gint, gint, gint, gint);
extern (C) void gdk_draw_drawable(_GdkDrawable *, _GdkGC *, _GdkDrawable *, gint, gint, gint, gint, gint, gint);
extern (C) void gdk_draw_text_wc(_GdkDrawable *, _GdkFont *, _GdkGC *, gint, gint, guint *, gint);
extern (C) void gdk_draw_text(_GdkDrawable *, _GdkFont *, _GdkGC *, gint, gint, char *, gint);
extern (C) void gdk_draw_string(_GdkDrawable *, _GdkFont *, _GdkGC *, gint, gint, char *);
extern (C) void gdk_draw_polygon(_GdkDrawable *, _GdkGC *, gint, _GdkPoint *, gint);
extern (C) void gdk_draw_arc(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, gint, gint);
extern (C) void gdk_draw_rectangle(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint);
extern (C) void gdk_draw_line(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint);
extern (C) void gdk_draw_point(_GdkDrawable *, _GdkGC *, gint, gint);
extern (C) void gdk_drawable_unref(_GdkDrawable *);
extern (C) _GdkDrawable * gdk_drawable_ref(_GdkDrawable *);
extern (C) _GdkDisplay * gdk_drawable_get_display(_GdkDrawable *);
extern (C) _GdkScreen * gdk_drawable_get_screen(_GdkDrawable *);
extern (C) gint gdk_drawable_get_depth(_GdkDrawable *);
extern (C) _GdkVisual * gdk_drawable_get_visual(_GdkDrawable *);
extern (C) _GdkColormap * gdk_drawable_get_colormap(_GdkDrawable *);
extern (C) void gdk_drawable_set_colormap(_GdkDrawable *, _GdkColormap *);
extern (C) void gdk_drawable_get_size(_GdkDrawable *, gint *, gint *);
extern (C) void * gdk_drawable_get_data(_GdkDrawable *, char *);
extern (C) void gdk_drawable_set_data(_GdkDrawable *, char *, void *, _BCD_func__4634);
extern (C) guint gdk_drawable_get_type();
extern (C) _GdkScreen * gdk_gc_get_screen(_GdkGC *);
extern (C) void gdk_gc_set_rgb_bg_color(_GdkGC *, _GdkColor *);
extern (C) void gdk_gc_set_rgb_fg_color(_GdkGC *, _GdkColor *);
extern (C) _GdkColormap * gdk_gc_get_colormap(_GdkGC *);
extern (C) void gdk_gc_set_colormap(_GdkGC *, _GdkColormap *);
extern (C) void gdk_gc_copy(_GdkGC *, _GdkGC *);
extern (C) void gdk_gc_offset(_GdkGC *, gint, gint);
extern (C) void gdk_gc_set_dashes(_GdkGC *, gint, in char *, gint);
extern (C) void gdk_gc_set_line_attributes(_GdkGC *, gint, gint, gint, gint);
extern (C) void gdk_gc_set_exposures(_GdkGC *, gint);
extern (C) void gdk_gc_set_subwindow(_GdkGC *, gint);
extern (C) void gdk_gc_set_clip_region(_GdkGC *, void *);
extern (C) void gdk_gc_set_clip_rectangle(_GdkGC *, _GdkRectangle *);
extern (C) void gdk_gc_set_clip_mask(_GdkGC *, _GdkDrawable *);
extern (C) void gdk_gc_set_clip_origin(_GdkGC *, gint, gint);
extern (C) void gdk_gc_set_ts_origin(_GdkGC *, gint, gint);
extern (C) void gdk_gc_set_stipple(_GdkGC *, _GdkDrawable *);
extern (C) void gdk_gc_set_tile(_GdkGC *, _GdkDrawable *);
extern (C) void gdk_gc_set_fill(_GdkGC *, gint);
extern (C) void gdk_gc_set_function(_GdkGC *, gint);
extern (C) void gdk_gc_set_font(_GdkGC *, _GdkFont *);
extern (C) void gdk_gc_set_background(_GdkGC *, _GdkColor *);
extern (C) void gdk_gc_set_foreground(_GdkGC *, _GdkColor *);
extern (C) void gdk_gc_set_values(_GdkGC *, _GdkGCValues *, gint);
extern (C) void gdk_gc_get_values(_GdkGC *, _GdkGCValues *);
extern (C) void gdk_gc_unref(_GdkGC *);
extern (C) _GdkGC * gdk_gc_ref(_GdkGC *);
extern (C) _GdkGC * gdk_gc_new_with_values(_GdkDrawable *, _GdkGCValues *, gint);
extern (C) _GdkGC * gdk_gc_new(_GdkDrawable *);
extern (C) guint gdk_gc_get_type();
extern (C) gint gdk_display_supports_composite(_GdkDisplay *);
extern (C) gint gdk_display_supports_input_shapes(_GdkDisplay *);
extern (C) gint gdk_display_supports_shapes(_GdkDisplay *);
extern (C) void gdk_display_store_clipboard(_GdkDisplay *, _GdkDrawable *, guint32, void * *, gint);
extern (C) gint gdk_display_supports_clipboard_persistence(_GdkDisplay *);
extern (C) gint gdk_display_request_selection_notification(_GdkDisplay *, void *);
extern (C) gint gdk_display_supports_selection_notification(_GdkDisplay *);
extern (C) _GdkDrawable * gdk_display_get_default_group(_GdkDisplay *);
extern (C) void gdk_display_get_maximal_cursor_size(_GdkDisplay *, guint *, guint *);
extern (C) guint gdk_display_get_default_cursor_size(_GdkDisplay *);
extern (C) gint gdk_display_supports_cursor_color(_GdkDisplay *);
extern (C) gint gdk_display_supports_cursor_alpha(_GdkDisplay *);
extern (C) _GdkDisplay * gdk_display_open_default_libgtk_only();
extern (C) _GdkDisplayPointerHooks * gdk_display_set_pointer_hooks(_GdkDisplay *, _GdkDisplayPointerHooks *);
extern (C) void gdk_display_warp_pointer(_GdkDisplay *, _GdkScreen *, gint, gint);
extern (C) _GdkDrawable * gdk_display_get_window_at_pointer(_GdkDisplay *, gint *, gint *);
extern (C) void gdk_display_get_pointer(_GdkDisplay *, _GdkScreen * *, gint *, gint *, gint *);
extern (C) _GdkDevice * gdk_display_get_core_pointer(_GdkDisplay *);
extern (C) _GdkDisplay * gdk_display_get_default();
extern (C) void gdk_display_set_double_click_distance(_GdkDisplay *, guint);
extern (C) void gdk_display_set_double_click_time(_GdkDisplay *, guint);
extern (C) void gdk_display_add_client_message_filter(_GdkDisplay *, void *, _BCD_func__4335, void *);
extern (C) void gdk_display_put_event(_GdkDisplay *, _GdkEvent *);
extern (C) _GdkEvent * gdk_display_peek_event(_GdkDisplay *);
extern (C) _GdkEvent * gdk_display_get_event(_GdkDisplay *);
extern (C) _GList * gdk_display_list_devices(_GdkDisplay *);
extern (C) void gdk_display_close(_GdkDisplay *);
extern (C) void gdk_display_flush(_GdkDisplay *);
extern (C) void gdk_display_sync(_GdkDisplay *);
extern (C) void gdk_display_beep(_GdkDisplay *);
extern (C) gint gdk_display_pointer_is_grabbed(_GdkDisplay *);
extern (C) void gdk_display_keyboard_ungrab(_GdkDisplay *, guint32);
extern (C) void gdk_display_pointer_ungrab(_GdkDisplay *, guint32);
extern (C) _GdkScreen * gdk_display_get_default_screen(_GdkDisplay *);
extern (C) _GdkScreen * gdk_display_get_screen(_GdkDisplay *, gint);
extern (C) gint gdk_display_get_n_screens(_GdkDisplay *);
extern (C) char * gdk_display_get_name(_GdkDisplay *);
extern (C) _GdkDisplay * gdk_display_open(char *);
extern (C) GType gdk_display_get_type();
extern (C) gint gdk_setting_get(char *, _GValue *);
extern (C) void gdk_add_client_message_filter(void *, _BCD_func__4335, void *);
extern (C) gint gdk_get_show_events();
extern (C) void gdk_set_show_events(gint);
extern (C) _GdkScreen * gdk_event_get_screen(_GdkEvent *);
extern (C) void gdk_event_set_screen(_GdkEvent *, _GdkScreen *);
extern (C) void gdk_event_handler_set(_BCD_func__4336, void *, _BCD_func__4634);
extern (C) void gdk_event_request_motions(_GdkEventMotion *);
extern (C) gint gdk_event_get_axis(_GdkEvent *, gint, double *);
extern (C) gint gdk_event_get_root_coords(_GdkEvent *, double *, double *);
extern (C) gint gdk_event_get_coords(_GdkEvent *, double *, double *);
extern (C) gint gdk_event_get_state(_GdkEvent *, gint *);
extern (C) guint32 gdk_event_get_time(_GdkEvent *);
extern (C) void gdk_event_free(_GdkEvent *);
extern (C) _GdkEvent * gdk_event_copy(_GdkEvent *);
extern (C) _GdkEvent * gdk_event_new(gint);
extern (C) void gdk_event_put(_GdkEvent *);
extern (C) _GdkEvent * gdk_event_get_graphics_expose(_GdkDrawable *);
extern (C) _GdkEvent * gdk_event_peek();
extern (C) _GdkEvent * gdk_event_get();
extern (C) gint gdk_events_pending();
extern (C) GType gdk_event_get_type();
extern (C) _GdkDevice * gdk_device_get_core_pointer();
extern (C) void gdk_input_set_extension_events(_GdkDrawable *, gint, gint);
extern (C) gint gdk_device_get_axis(_GdkDevice *, double *, gint, double *);
extern (C) void gdk_device_free_history(_GdkTimeCoord * *, gint);
extern (C) gint gdk_device_get_history(_GdkDevice *, _GdkDrawable *, guint32, guint32, _GdkTimeCoord * * *, gint *);
extern (C) void gdk_device_get_state(_GdkDevice *, _GdkDrawable *, double *, gint *);
extern (C) void gdk_device_set_axis_use(_GdkDevice *, guint, gint);
extern (C) void gdk_device_set_key(_GdkDevice *, guint, guint, gint);
extern (C) gint gdk_device_set_mode(_GdkDevice *, gint);
extern (C) void gdk_device_set_source(_GdkDevice *, gint);
extern (C) _GList * gdk_devices_list();
extern (C) GType gdk_device_get_type();
extern (C) gint gdk_drag_drop_succeeded(_GdkDragContext *);
extern (C) void gdk_drag_abort(_GdkDragContext *, guint32);
extern (C) void gdk_drag_drop(_GdkDragContext *, guint32);
extern (C) gint gdk_drag_motion(_GdkDragContext *, _GdkDrawable *, gint, gint, gint, gint, gint, guint32);
extern (C) void gdk_drag_find_window(_GdkDragContext *, _GdkDrawable *, gint, gint, _GdkDrawable * *, gint *);
extern (C) guint gdk_drag_get_protocol(guint, gint *);
extern (C) void gdk_drag_find_window_for_screen(_GdkDragContext *, _GdkDrawable *, _GdkScreen *, gint, gint, _GdkDrawable * *, gint *);
extern (C) guint gdk_drag_get_protocol_for_display(_GdkDisplay *, guint, gint *);
extern (C) _GdkDragContext * gdk_drag_begin(_GdkDrawable *, _GList *);
extern (C) void * gdk_drag_get_selection(_GdkDragContext *);
extern (C) void gdk_drop_finish(_GdkDragContext *, gint, guint32);
extern (C) void gdk_drop_reply(_GdkDragContext *, gint, guint32);
extern (C) void gdk_drag_status(_GdkDragContext *, gint, guint32);
extern (C) void gdk_drag_context_unref(_GdkDragContext *);
extern (C) void gdk_drag_context_ref(_GdkDragContext *);
extern (C) _GdkDragContext * gdk_drag_context_new();
extern (C) GType gdk_drag_context_get_type();
extern (C) void * gdk_cursor_get_image(_GdkCursor *);
extern (C) _GdkCursor * gdk_cursor_new_from_name(_GdkDisplay *, char *);
extern (C) void gdk_cursor_unref(_GdkCursor *);
extern (C) _GdkCursor * gdk_cursor_ref(_GdkCursor *);
extern (C) _GdkDisplay * gdk_cursor_get_display(_GdkCursor *);
extern (C) _GdkCursor * gdk_cursor_new_from_pixbuf(_GdkDisplay *, void *, gint, gint);
extern (C) _GdkCursor * gdk_cursor_new_from_pixmap(_GdkDrawable *, _GdkDrawable *, _GdkColor *, _GdkColor *, gint, gint);
extern (C) _GdkCursor * gdk_cursor_new(gint);
extern (C) _GdkCursor * gdk_cursor_new_for_display(_GdkDisplay *, gint);
extern (C) GType gdk_cursor_get_type();
extern (C) void gdk_cairo_region(void *, void *);
extern (C) void gdk_cairo_rectangle(void *, _GdkRectangle *);
extern (C) void gdk_cairo_set_source_pixmap(void *, _GdkDrawable *, double, double);
extern (C) void gdk_cairo_set_source_pixbuf(void *, void *, double, double);
extern (C) void gdk_cairo_set_source_color(void *, _GdkColor *);
extern (C) void * gdk_cairo_create(_GdkDrawable *);
extern (C) void * gdk_pixbuf_get_from_image(void *, _GdkImage *, _GdkColormap *, gint, gint, gint, gint, gint, gint);
extern (C) void * gdk_pixbuf_get_from_drawable(void *, _GdkDrawable *, _GdkColormap *, gint, gint, gint, gint, gint, gint);
extern (C) void gdk_pixbuf_render_pixmap_and_mask(void *, _GdkDrawable * *, _GdkDrawable * *, gint);
extern (C) void gdk_pixbuf_render_pixmap_and_mask_for_colormap(void *, _GdkColormap *, _GdkDrawable * *, _GdkDrawable * *, gint);
extern (C) void gdk_pixbuf_render_to_drawable_alpha(void *, _GdkDrawable *, gint, gint, gint, gint, gint, gint, gint, gint, gint, gint, gint);
extern (C) void gdk_pixbuf_render_to_drawable(void *, _GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, gint, gint, gint, gint);
extern (C) void gdk_pixbuf_render_threshold_alpha(void *, _GdkDrawable *, gint, gint, gint, gint, gint, gint, gint);
extern (C) guint gdk_pixbuf_rotation_get_type();
extern (C) guint gdk_interp_type_get_type();
extern (C) guint gdk_pixbuf_error_get_type();
extern (C) guint gdk_colorspace_get_type();
extern (C) guint gdk_pixbuf_alpha_mode_get_type();
extern (C) void * gdk_pixbuf_loader_get_format(_GdkPixbufLoader *);
extern (C) gint gdk_pixbuf_loader_close(_GdkPixbufLoader *, _GError * *);
extern (C) void * gdk_pixbuf_loader_get_animation(_GdkPixbufLoader *);
extern (C) void * gdk_pixbuf_loader_get_pixbuf(_GdkPixbufLoader *);
extern (C) gint gdk_pixbuf_loader_write(_GdkPixbufLoader *, char *, gsize, _GError * *);
extern (C) void gdk_pixbuf_loader_set_size(_GdkPixbufLoader *, gint, gint);
extern (C) _GdkPixbufLoader * gdk_pixbuf_loader_new_with_mime_type(char *, _GError * *);
extern (C) _GdkPixbufLoader * gdk_pixbuf_loader_new_with_type(char *, _GError * *);
extern (C) _GdkPixbufLoader * gdk_pixbuf_loader_new();
extern (C) GType gdk_pixbuf_loader_get_type();
extern (C) void * gdk_pixbuf_get_file_info(char *, gint *, gint *);
extern (C) char * gdk_pixbuf_format_get_license(void *);
extern (C) void gdk_pixbuf_format_set_disabled(void *, gint);
extern (C) gint gdk_pixbuf_format_is_disabled(void *);
extern (C) gint gdk_pixbuf_format_is_scalable(void *);
extern (C) gint gdk_pixbuf_format_is_writable(void *);
extern (C) char * * gdk_pixbuf_format_get_extensions(void *);
extern (C) char * * gdk_pixbuf_format_get_mime_types(void *);
extern (C) char * gdk_pixbuf_format_get_description(void *);
extern (C) char * gdk_pixbuf_format_get_name(void *);
extern (C) _GSList * gdk_pixbuf_get_formats();
extern (C) void gdk_pixbuf_simple_anim_add_frame(void *, void *);
extern (C) void * gdk_pixbuf_simple_anim_new(gint, gint, float);
extern (C) GType gdk_pixbuf_simple_anim_iter_get_type();
extern (C) GType gdk_pixbuf_simple_anim_get_type();
extern (C) gint gdk_pixbuf_animation_iter_advance(void *, _GTimeVal *);
extern (C) gint gdk_pixbuf_animation_iter_on_currently_loading_frame(void *);
extern (C) void * gdk_pixbuf_animation_iter_get_pixbuf(void *);
extern (C) gint gdk_pixbuf_animation_iter_get_delay_time(void *);
extern (C) GType gdk_pixbuf_animation_iter_get_type();
extern (C) void * gdk_pixbuf_animation_get_iter(void *, _GTimeVal *);
extern (C) void * gdk_pixbuf_animation_get_static_image(void *);
extern (C) gint gdk_pixbuf_animation_is_static_image(void *);
extern (C) gint gdk_pixbuf_animation_get_height(void *);
extern (C) gint gdk_pixbuf_animation_get_width(void *);
extern (C) void gdk_pixbuf_animation_unref(void *);
extern (C) void * gdk_pixbuf_animation_ref(void *);
extern (C) void * gdk_pixbuf_animation_new_from_file(char *, _GError * *);
extern (C) GType gdk_pixbuf_animation_get_type();
extern (C) void * gdk_pixbuf_flip(void *, gint);
extern (C) void * gdk_pixbuf_rotate_simple(void *, gint);
extern (C) void * gdk_pixbuf_composite_color_simple(void *, gint, gint, gint, gint, gint, guint32, guint32);
extern (C) void * gdk_pixbuf_scale_simple(void *, gint, gint, gint);
extern (C) void gdk_pixbuf_composite_color(void *, void *, gint, gint, gint, gint, double, double, double, double, gint, gint, gint, gint, gint, guint32, guint32);
extern (C) void gdk_pixbuf_composite(void *, void *, gint, gint, gint, gint, double, double, double, double, gint, gint);
extern (C) void gdk_pixbuf_scale(void *, void *, gint, gint, gint, gint, double, double, double, double, gint);
extern (C) char * gdk_pixbuf_get_option(void *, char *);
extern (C) void * gdk_pixbuf_apply_embedded_orientation(void *);
extern (C) void gdk_pixbuf_saturate_and_pixelate(void *, void *, float, gint);
extern (C) void gdk_pixbuf_copy_area(void *, gint, gint, gint, gint, void *, gint, gint);
extern (C) void * gdk_pixbuf_add_alpha(void *, gint, char, char, char);
extern (C) gint gdk_pixbuf_save_to_bufferv(void *, char * *, gsize *, in char *, char * *, char * *, _GError * *);
extern (C) gint gdk_pixbuf_save_to_buffer(void *, char * *, gsize *, in char *, _GError * *, ...);
extern (C) gint gdk_pixbuf_save_to_callbackv(void *, _BCD_func__4618, void *, char *, char * *, char * *, _GError * *);
extern (C) gint gdk_pixbuf_save_to_callback(void *, _BCD_func__4618, void *, char *, _GError * *, ...);
extern (C) gint gdk_pixbuf_savev(void *, char *, char *, char * *, char * *, _GError * *);
extern (C) gint gdk_pixbuf_save(void *, char *, char *, _GError * *, ...);
extern (C) void gdk_pixbuf_fill(void *, guint32);
extern (C) void * gdk_pixbuf_new_from_inline(gint, char *, gint, _GError * *);
extern (C) void * gdk_pixbuf_new_from_xpm_data(char * *);
extern (C) void * gdk_pixbuf_new_from_data(char *, gint, gint, gint, gint, gint, gint, _BCD_func__4621, void *);
extern (C) void * gdk_pixbuf_new_from_file_at_scale(char *, gint, gint, gint, _GError * *);
extern (C) void * gdk_pixbuf_new_from_file_at_size(char *, gint, gint, _GError * *);
extern (C) void * gdk_pixbuf_new_from_file(char *, _GError * *);
extern (C) void * gdk_pixbuf_new_subpixbuf(void *, gint, gint, gint, gint);
extern (C) void * gdk_pixbuf_copy(void *);
extern (C) void * gdk_pixbuf_new(gint, gint, gint, gint, gint);
extern (C) gint gdk_pixbuf_get_rowstride(void *);
extern (C) gint gdk_pixbuf_get_height(void *);
extern (C) gint gdk_pixbuf_get_width(void *);
extern (C) char * gdk_pixbuf_get_pixels(void *);
extern (C) gint gdk_pixbuf_get_bits_per_sample(void *);
extern (C) gint gdk_pixbuf_get_has_alpha(void *);
extern (C) gint gdk_pixbuf_get_n_channels(void *);
extern (C) gint gdk_pixbuf_get_colorspace(void *);
extern (C) void gdk_pixbuf_unref(void *);
extern (C) void * gdk_pixbuf_ref(void *);
extern (C) GType gdk_pixbuf_get_type();
extern (C) GQuark gdk_pixbuf_error_quark();
extern (C) extern char * gdk_pixbuf_version;
extern (C) extern guint gdk_pixbuf_micro_version;
extern (C) extern guint gdk_pixbuf_minor_version;
extern (C) extern guint gdk_pixbuf_major_version;
extern (C) gint gdk_rgb_colormap_ditherable(_GdkColormap *);
extern (C) gint gdk_rgb_ditherable();
extern (C) _GdkVisual * gdk_rgb_get_visual();
extern (C) _GdkColormap * gdk_rgb_get_colormap();
extern (C) void gdk_rgb_set_min_colors(gint);
extern (C) void gdk_rgb_set_install(gint);
extern (C) void gdk_rgb_set_verbose(gint);
extern (C) void gdk_rgb_cmap_free(_GdkRgbCmap *);
extern (C) _GdkRgbCmap * gdk_rgb_cmap_new(guint *, gint);
extern (C) void gdk_draw_indexed_image(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint, _GdkRgbCmap *);
extern (C) void gdk_draw_gray_image(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint);
extern (C) void gdk_draw_rgb_32_image_dithalign(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint, gint, gint);
extern (C) void gdk_draw_rgb_32_image(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint);
extern (C) void gdk_draw_rgb_image_dithalign(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint, gint, gint);
extern (C) void gdk_draw_rgb_image(_GdkDrawable *, _GdkGC *, gint, gint, gint, gint, gint, char *, gint);
extern (C) void gdk_rgb_find_color(_GdkColormap *, _GdkColor *);
extern (C) void gdk_rgb_gc_set_background(_GdkGC *, guint);
extern (C) void gdk_rgb_gc_set_foreground(_GdkGC *, guint);
extern (C) guint gdk_rgb_xpixel_from_rgb(guint);
extern (C) void gdk_rgb_init();
extern (C) void gdk_colors_free(_GdkColormap *, guint *, gint, guint);
extern (C) gint gdk_colors_alloc(_GdkColormap *, gint, guint *, gint, guint *, gint);
extern (C) gint gdk_color_change(_GdkColormap *, _GdkColor *);
extern (C) gint gdk_color_alloc(_GdkColormap *, _GdkColor *);
extern (C) gint gdk_color_black(_GdkColormap *, _GdkColor *);
extern (C) gint gdk_color_white(_GdkColormap *, _GdkColor *);
extern (C) void gdk_colors_store(_GdkColormap *, _GdkColor *, gint);
extern (C) GType gdk_color_get_type();
extern (C) char * gdk_color_to_string(_GdkColor *);
extern (C) gint gdk_color_equal(_GdkColor *, _GdkColor *);
extern (C) guint gdk_color_hash(_GdkColor *);
extern (C) gint gdk_color_parse(char *, _GdkColor *);
extern (C) void gdk_color_free(_GdkColor *);
extern (C) _GdkColor * gdk_color_copy(_GdkColor *);
extern (C) _GdkVisual * gdk_colormap_get_visual(_GdkColormap *);
extern (C) void gdk_colormap_query_color(_GdkColormap *, guint, _GdkColor *);
extern (C) void gdk_colormap_free_colors(_GdkColormap *, _GdkColor *, gint);
extern (C) gint gdk_colormap_alloc_color(_GdkColormap *, _GdkColor *, gint, gint);
extern (C) gint gdk_colormap_alloc_colors(_GdkColormap *, _GdkColor *, gint, gint, gint, gint *);
extern (C) void gdk_colormap_change(_GdkColormap *, gint);
extern (C) gint gdk_colormap_get_system_size();
extern (C) _GdkScreen * gdk_colormap_get_screen(_GdkColormap *);
extern (C) _GdkColormap * gdk_colormap_get_system();
extern (C) void gdk_colormap_unref(_GdkColormap *);
extern (C) _GdkColormap * gdk_colormap_ref(_GdkColormap *);
extern (C) _GdkColormap * gdk_colormap_new(_GdkVisual *, gint);
extern (C) guint gdk_colormap_get_type();
} // version(DYNLINK)

