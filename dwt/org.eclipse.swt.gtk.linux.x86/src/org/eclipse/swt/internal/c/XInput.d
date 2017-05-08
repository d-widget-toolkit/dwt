/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.XInput;

import java.lang.all;

public import org.eclipse.swt.internal.c.Xlib;
private import org.eclipse.swt.internal.c.X;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):

struct XExtensionVersion{
    c_int present;
    short major_version;
    short minor_version;
};



const c_int _deviceKeyPress = 0;
const c_int _deviceKeyRelease = 1;
const c_int _deviceButtonPress = 0;
const c_int _deviceButtonRelease = 1;
const c_int _deviceMotionNotify = 0;
const c_int _deviceFocusIn = 0;
const c_int _deviceFocusOut = 1;
const c_int _proximityIn = 0;
const c_int _proximityOut = 1;
const c_int _deviceStateNotify = 0;
const c_int _deviceMappingNotify = 1;
const c_int _changeDeviceNotify = 2;
alias _XValuatorInfo XValuatorInfo;
alias _XValuatorInfo * XValuatorInfoPtr;
alias _XAxisInfo * XAxisInfoPtr;
alias _XAxisInfo XAxisInfo;
alias _XButtonInfo XButtonInfo;
alias _XButtonInfo * XButtonInfoPtr;
alias _XKeyInfo XKeyInfo;
alias _XKeyInfo * XKeyInfoPtr;
alias _XDeviceInfo XDeviceInfo;
alias _XDeviceInfo * XDeviceInfoPtr;
alias _XAnyClassinfo * XAnyClassPtr;
alias _XAnyClassinfo XAnyClassInfo;
alias XDeviceEnableControl XDeviceEnableState;
alias XDeviceAbsAreaControl XDeviceAbsAreaState;
alias XDeviceAbsCalibControl XDeviceAbsCalibState;
alias XProximityNotifyEvent XProximityOutEvent;
alias XProximityNotifyEvent XProximityInEvent;
alias XDeviceFocusChangeEvent XDeviceFocusOutEvent;
alias XDeviceFocusChangeEvent XDeviceFocusInEvent;
alias XDeviceButtonEvent XDeviceButtonReleasedEvent;
alias XDeviceButtonEvent XDeviceButtonPressedEvent;
alias XDeviceKeyEvent XDeviceKeyReleasedEvent;
alias XDeviceKeyEvent XDeviceKeyPressedEvent;
struct XButtonState {
char c_class;
char length;
short num_buttons;
char [32] buttons;
}
struct XKeyState {
char c_class;
char length;
short num_keys;
char [32] keys;
}
struct XValuatorState {
char c_class;
char length;
char num_valuators;
char mode;
c_int * valuators;
}
struct XDeviceState {
XID device_id;
c_int num_classes;
XInputClass * data;
}
struct XDeviceTimeCoord {
Time time;
c_int * data;
}
struct XEventList {
XEventClass event_type;
XID device;
}
struct XDevice {
XID device_id;
c_int num_classes;
XInputClassInfo * classes;
}
struct XInputClassInfo {
char input_class;
char event_type_base;
}
struct _XValuatorInfo {
XID c_class;
c_int length;
char num_axes;
char mode;
c_ulong motion_buffer;
_XAxisInfo * axes;
}
struct _XAxisInfo {
c_int resolution;
c_int min_value;
c_int max_value;
}
struct _XButtonInfo {
XID c_class;
c_int length;
short num_buttons;
}
struct _XKeyInfo {
XID c_class;
c_int length;
ushort min_keycode;
ushort max_keycode;
ushort num_keys;
}
struct _XDeviceInfo {
XID id;
Atom type;
char * name;
c_int num_classes;
c_int use;
_XAnyClassinfo * inputclassinfo;
}
struct _XAnyClassinfo {
XID c_class;
c_int length;
}
struct XDeviceEnableControl {
XID control;
c_int length;
c_int enable;
}
struct XDeviceCoreState {
XID control;
c_int length;
c_int status;
c_int iscore;
}
struct XDeviceCoreControl {
XID control;
c_int length;
c_int status;
}
struct XDeviceAbsAreaControl {
XID control;
c_int length;
c_int offset_x;
c_int offset_y;
c_int width;
c_int height;
c_int screen;
XID following;
}
struct XDeviceAbsCalibControl {
XID control;
c_int length;
c_int min_x;
c_int max_x;
c_int min_y;
c_int max_y;
c_int flip_x;
c_int flip_y;
c_int rotation;
c_int button_threshold;
}
struct XDeviceResolutionState {
XID control;
c_int length;
c_int num_valuators;
c_int * resolutions;
c_int * min_resolutions;
c_int * max_resolutions;
}
struct XDeviceResolutionControl {
XID control;
c_int length;
c_int first_valuator;
c_int num_valuators;
c_int * resolutions;
}
struct XDeviceControl {
XID control;
c_int length;
}
struct XLedFeedbackControl {
XID c_class;
c_int length;
XID id;
c_int led_mask;
c_int led_values;
}
struct XBellFeedbackControl {
XID c_class;
c_int length;
XID id;
c_int percent;
c_int pitch;
c_int duration;
}
struct XIntegerFeedbackControl {
XID c_class;
c_int length;
XID id;
c_int int_to_display;
}
struct XStringFeedbackControl {
XID c_class;
c_int length;
XID id;
c_int num_keysyms;
KeySym * syms_to_display;
}
struct XKbdFeedbackControl {
XID c_class;
c_int length;
XID id;
c_int click;
c_int percent;
c_int pitch;
c_int duration;
c_int led_mask;
c_int led_value;
c_int key;
c_int auto_repeat_mode;
}
struct XPtrFeedbackControl {
XID c_class;
c_int length;
XID id;
c_int accelNum;
c_int accelDenom;
c_int threshold;
}
struct XFeedbackControl {
XID c_class;
c_int length;
XID id;
}
struct XLedFeedbackState {
XID c_class;
c_int length;
XID id;
c_int led_values;
c_int led_mask;
}
struct XBellFeedbackState {
XID c_class;
c_int length;
XID id;
c_int percent;
c_int pitch;
c_int duration;
}
struct XStringFeedbackState {
XID c_class;
c_int length;
XID id;
c_int max_symbols;
c_int num_syms_supported;
KeySym * syms_supported;
}
struct XIntegerFeedbackState {
XID c_class;
c_int length;
XID id;
c_int resolution;
c_int minVal;
c_int maxVal;
}
struct XPtrFeedbackState {
XID c_class;
c_int length;
XID id;
c_int accelNum;
c_int accelDenom;
c_int threshold;
}
struct XKbdFeedbackState {
XID c_class;
c_int length;
XID id;
c_int click;
c_int percent;
c_int pitch;
c_int duration;
c_int led_mask;
c_int global_auto_repeat;
char [32] auto_repeats;
}
struct XFeedbackState {
XID c_class;
c_int length;
XID id;
}
struct XDevicePresenceNotifyEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
Time time;
Bool devchange;
XID deviceid;
XID control;
}
struct XChangeDeviceNotifyEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
XID deviceid;
Time time;
c_int request;
}
struct XDeviceMappingEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
XID deviceid;
Time time;
c_int request;
c_int first_keycode;
c_int count;
}
struct XButtonStatus {
char c_class;
char length;
short num_buttons;
char [32] buttons;
}
struct XKeyStatus {
char c_class;
char length;
short num_keys;
char [32] keys;
}
struct XValuatorStatus {
char c_class;
char length;
char num_valuators;
char mode;
c_int [6] valuators;
}
struct XDeviceStateNotifyEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
XID deviceid;
Time time;
c_int num_classes;
char [64] data;
}
struct XInputClass {
char c_class;
char length;
}
struct XProximityNotifyEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
XID deviceid;
Window root;
Window subwindow;
Time time;
c_int x;
c_int y;
c_int x_root;
c_int y_root;
c_uint state;
Bool same_screen;
c_uint device_state;
char axes_count;
char first_axis;
c_int [6] axis_data;
}
struct XDeviceFocusChangeEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
XID deviceid;
c_int mode;
c_int detail;
Time time;
}
struct XDeviceMotionEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
XID deviceid;
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
c_uint device_state;
char axes_count;
char first_axis;
c_int [6] axis_data;
}
struct XDeviceButtonEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
XID deviceid;
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
c_uint device_state;
char axes_count;
char first_axis;
c_int [6] axis_data;
}
struct XDeviceKeyEvent {
c_int type;
c_ulong serial;
Bool send_event;
Display * display;
Window window;
XID deviceid;
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
c_uint device_state;
char axes_count;
char first_axis;
c_int [6] axis_data;
}
version(DYNLINK){
mixin(gshared!(
"extern(C) Status function(Display*, XDevice*, Atom, c_long, c_long, Bool, Atom, Atom*, c_int*, c_ulong*, c_ulong*, char**) XGetDeviceProperty;
extern(C) void function(Display*, XDevice*, Atom) XDeleteDeviceProperty;
extern(C) void function(Display*, XDevice*, Atom, Atom, c_int, c_int, const char *, c_int) XChangeDeviceProperty;
extern(C) Atom* function(Display*, XDevice*, c_int*) XListDeviceProperties;
extern(C) void function(XDeviceControl*) XFreeDeviceControl;
extern(C) void function(XDeviceTimeCoord*) XFreeDeviceMotionEvents;
extern(C) XDeviceTimeCoord function(Display*, XDevice*, Time, Time, c_int*, c_int*, c_int*) *XGetDeviceMotionEvents;
extern(C) Status function(Display*, XDevice*, Window, Bool, c_int, XEventClass*, XEvent*) XSendExtensionEvent;
extern(C) XEventClass function(Display*, Window, c_int*) *XGetDeviceDontPropagateList;
extern(C) c_int function(Display*, Window, c_int, XEventClass*, c_int) XChangeDeviceDontPropagateList;
extern(C) c_int function(Display*, Window, c_int*, XEventClass**, c_int*, XEventClass**) XGetSelectedExtensionEvents;
extern(C) c_int function(Display*, Window, XEventClass*, c_int) XSelectExtensionEvent;
extern(C) c_int function(Display*, XDevice*, c_int, XDeviceControl*) XChangeDeviceControl;
extern(C) XDeviceControl function(Display*, XDevice*, c_int) *XGetDeviceControl;
extern(C) c_int function(Display*, XDevice*, c_int*, c_int, c_int) XSetDeviceValuators;
extern(C) c_int function(Display*, XDevice*, c_int) XSetDeviceMode;
extern(C) c_int function(Display*, XDevice*) XCloseDevice;
extern(C) XDevice function(Display*, XID) *XOpenDevice;
extern(C) void function(XDeviceInfo*) XFreeDeviceList;
extern(C) XDeviceInfo function(Display*, c_int*) *XListInputDevices;
extern(C) XExtensionVersion function(Display*, const char*) *XGetExtensionVersion;
extern(C) void function(XDeviceState*) XFreeDeviceState;
extern(C) XDeviceState function(Display*, XDevice*) *XQueryDeviceState;
extern(C) c_int function(Display*, XDevice*, char*, c_uint) XGetDeviceButtonMapping;
extern(C) c_int function(Display*, XDevice*, char*, c_int) XSetDeviceButtonMapping;
extern(C) c_int function(Display*, XDevice*, XModifierKeymap*) XSetDeviceModifierMapping;
extern(C) XModifierKeymap function(Display*, XDevice*) *XGetDeviceModifierMapping;
extern(C) c_int function(Display*, XDevice*, c_int, c_int, KeySym*, c_int) XChangeDeviceKeyMapping;
extern(C) KeySym function(Display*, XDevice*, KeyCode, c_int, c_int*) *XGetDeviceKeyMapping;
extern(C) c_int function(Display*, XDevice*, XID, XID, c_int) XDeviceBell;
extern(C) c_int function(Display*, XDevice*, c_ulong, XFeedbackControl*) XChangeFeedbackControl;
extern(C) void function(XFeedbackState*) XFreeFeedbackList;
extern(C) XFeedbackState function(Display*, XDevice*, c_int*) *XGetFeedbackControl;
extern(C) c_int function(Display*, XDevice*, Window, c_int, Time) XSetDeviceFocus;
extern(C) c_int function(Display*, XDevice*, Window*, c_int*, Time*) XGetDeviceFocus;
extern(C) c_int function(Display*, XDevice*, c_int, Time) XAllowDeviceEvents;
extern(C) c_int function(Display*, XDevice*, c_uint, c_uint, XDevice*, Window) XUngrabDeviceButton;
extern(C) c_int function(Display*, XDevice*, c_uint, c_uint, XDevice*, Window, Bool, c_uint, XEventClass*, c_int, c_int) XGrabDeviceButton;
extern(C) c_int function(Display*, XDevice*, c_uint, c_uint, XDevice*, Window) XUngrabDeviceKey;
extern(C) c_int function(Display*, XDevice*, c_uint, c_uint, XDevice*, Window, Bool, c_uint, XEventClass*, c_int, c_int) XGrabDeviceKey;
extern(C) c_int function(Display*, XDevice*, Time) XUngrabDevice;
extern(C) c_int function(Display*, XDevice*, Window, Bool, c_int, XEventClass*, c_int, c_int, Time) XGrabDevice;
extern(C) c_int function(Display*, XDevice*, c_int, c_int) XChangePointerDevice;
extern(C) c_int function(Display*, XDevice*) XChangeKeyboardDevice;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("XFreeDeviceControl",  cast(void**)& XFreeDeviceControl),
        Symbol("XFreeDeviceMotionEvents",  cast(void**)& XFreeDeviceMotionEvents),
        Symbol("XGetDeviceMotionEvents",  cast(void**)& XGetDeviceMotionEvents),
        Symbol("XSendExtensionEvent",  cast(void**)& XSendExtensionEvent),
        Symbol("XGetDeviceDontPropagateList",  cast(void**)& XGetDeviceDontPropagateList),
        Symbol("XChangeDeviceDontPropagateList",  cast(void**)& XChangeDeviceDontPropagateList),
        Symbol("XGetSelectedExtensionEvents",  cast(void**)& XGetSelectedExtensionEvents),
        Symbol("XSelectExtensionEvent",  cast(void**)& XSelectExtensionEvent),
        Symbol("XChangeDeviceControl",  cast(void**)& XChangeDeviceControl),
        Symbol("XGetDeviceControl",  cast(void**)& XGetDeviceControl),
        Symbol("XSetDeviceValuators",  cast(void**)& XSetDeviceValuators),
        Symbol("XSetDeviceMode",  cast(void**)& XSetDeviceMode),
        Symbol("XCloseDevice",  cast(void**)& XCloseDevice),
        Symbol("XOpenDevice",  cast(void**)& XOpenDevice),
        Symbol("XFreeDeviceList",  cast(void**)& XFreeDeviceList),
        Symbol("XListInputDevices",  cast(void**)& XListInputDevices),
        Symbol("XGetExtensionVersion",  cast(void**)& XGetExtensionVersion),
        Symbol("XFreeDeviceState",  cast(void**)& XFreeDeviceState),
        Symbol("XQueryDeviceState",  cast(void**)& XQueryDeviceState),
        Symbol("XGetDeviceButtonMapping",  cast(void**)& XGetDeviceButtonMapping),
        Symbol("XSetDeviceButtonMapping",  cast(void**)& XSetDeviceButtonMapping),
        Symbol("XSetDeviceModifierMapping",  cast(void**)& XSetDeviceModifierMapping),
        Symbol("XGetDeviceModifierMapping",  cast(void**)& XGetDeviceModifierMapping),
        Symbol("XChangeDeviceKeyMapping",  cast(void**)& XChangeDeviceKeyMapping),
        Symbol("XGetDeviceKeyMapping",  cast(void**)& XGetDeviceKeyMapping),
        Symbol("XDeviceBell",  cast(void**)& XDeviceBell),
        Symbol("XChangeFeedbackControl",  cast(void**)& XChangeFeedbackControl),
        Symbol("XFreeFeedbackList",  cast(void**)& XFreeFeedbackList),
        Symbol("XGetFeedbackControl",  cast(void**)& XGetFeedbackControl),
        Symbol("XSetDeviceFocus",  cast(void**)& XSetDeviceFocus),
        Symbol("XGetDeviceFocus",  cast(void**)& XGetDeviceFocus),
        Symbol("XAllowDeviceEvents",  cast(void**)& XAllowDeviceEvents),
        Symbol("XUngrabDeviceButton",  cast(void**)& XUngrabDeviceButton),
        Symbol("XGrabDeviceButton",  cast(void**)& XGrabDeviceButton),
        Symbol("XUngrabDeviceKey",  cast(void**)& XUngrabDeviceKey),
        Symbol("XGrabDeviceKey",  cast(void**)& XGrabDeviceKey),
        Symbol("XUngrabDevice",  cast(void**)& XUngrabDevice),
        Symbol("XGrabDevice",  cast(void**)& XGrabDevice),
        Symbol("XChangePointerDevice",  cast(void**)& XChangePointerDevice),
        Symbol("XChangeKeyboardDevice",  cast(void**)& XChangeKeyboardDevice)
    ];
}

} else { // version(DYNLINK)
extern(C) void XFreeDeviceControl(XDeviceControl*);
extern(C) void XFreeDeviceMotionEvents(XDeviceTimeCoord*);
extern(C) XDeviceTimeCoord *XGetDeviceMotionEvents(Display*, XDevice*, Time, Time, c_int*, c_int*, c_int*);
extern(C) Status XSendExtensionEvent(Display*, XDevice*, Window, Bool, c_int, XEventClass*, XEvent*);
extern(C) XEventClass *XGetDeviceDontPropagateList(Display*, Window, c_int*);
extern(C) c_int XChangeDeviceDontPropagateList(Display*, Window, c_int, XEventClass*, c_int);
extern(C) c_int XGetSelectedExtensionEvents(Display*, Window, c_int*, XEventClass**, c_int*, XEventClass**);
extern(C) c_int XSelectExtensionEvent(Display*, Window, XEventClass*, c_int);
extern(C) c_int XChangeDeviceControl(Display*, XDevice*, c_int, XDeviceControl*);
extern(C) XDeviceControl *XGetDeviceControl(Display*, XDevice*, c_int);
extern(C) c_int XSetDeviceValuators(Display*, XDevice*, c_int*, c_int, c_int);
extern(C) c_int XSetDeviceMode(Display*, XDevice*, c_int);
extern(C) c_int XCloseDevice(Display*, XDevice*);
extern(C) XDevice *XOpenDevice(Display*, XID);
extern(C) void XFreeDeviceList(XDeviceInfo*);
extern(C) XDeviceInfo *XListInputDevices(Display*, c_int*);
extern(C) XExtensionVersion *XGetExtensionVersion(Display*, const char*);
extern(C) void XFreeDeviceState(XDeviceState*);
extern(C) XDeviceState *XQueryDeviceState(Display*, XDevice*);
extern(C) c_int XGetDeviceButtonMapping(Display*, XDevice*, char*, c_uint);
extern(C) c_int XSetDeviceButtonMapping(Display*, XDevice*, char*, c_int);
extern(C) c_int XSetDeviceModifierMapping(Display*, XDevice*, XModifierKeymap*);
extern(C) XModifierKeymap *XGetDeviceModifierMapping(Display*, XDevice*);
extern(C) c_int XChangeDeviceKeyMapping(Display*, XDevice*, c_int, c_int, KeySym*, c_int);
extern(C) KeySym *XGetDeviceKeyMapping(Display*, XDevice*, KeyCode, c_int, c_int*);
extern(C) c_int XDeviceBell(Display*, XDevice*, XID, XID, c_int);
extern(C) c_int XChangeFeedbackControl(Display*, XDevice*, c_ulong, XFeedbackControl*);
extern(C) void XFreeFeedbackList(XFeedbackState*);
extern(C) XFeedbackState *XGetFeedbackControl(Display*, XDevice*, c_int*);
extern(C) c_int XSetDeviceFocus(Display*, XDevice*, Window, c_int, Time);
extern(C) c_int XGetDeviceFocus(Display*, XDevice*, Window*, c_int*, Time*);
extern(C) c_int XAllowDeviceEvents(Display*, XDevice*, c_int, Time);
extern(C) c_int XUngrabDeviceButton(Display*, XDevice*, c_uint, c_uint, XDevice*, Window);
extern(C) c_int XGrabDeviceButton(Display*, XDevice*, c_uint, c_uint, XDevice*, Window, Bool, c_uint, XEventClass*, c_int, c_int);
extern(C) c_int XUngrabDeviceKey(Display*, XDevice*, c_uint, c_uint, XDevice*, Window);
extern(C) c_int XGrabDeviceKey(Display*, XDevice*, c_uint, c_uint, XDevice*, Window, Bool, c_uint, XEventClass*, c_int, c_int);
extern(C) c_int XUngrabDevice(Display*, XDevice*, Time);
extern(C) c_int XGrabDevice(Display*, XDevice*, Window, Bool, c_int, XEventClass*, c_int, c_int, Time);
extern(C) c_int XChangePointerDevice(Display*, XDevice*, c_int, c_int);
extern(C) c_int XChangeKeyboardDevice(Display*, XDevice*);
} // version(DYNLINK)

