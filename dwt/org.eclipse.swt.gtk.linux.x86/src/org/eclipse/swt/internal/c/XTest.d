/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.XTest;

import java.lang.all;

public import org.eclipse.swt.internal.c.Xlib;
public import org.eclipse.swt.internal.c.XInput;
private import org.eclipse.swt.internal.c.X;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):

const c_int X_XTestGetVersion = 0;
const c_int X_XTestCompareCursor = 1;
const c_int X_XTestFakeInput = 2;
const c_int X_XTestGrabControl = 3;
const c_int XTestNumberEvents = 0;
const c_int XTestNumberErrors = 0;
const c_int XTestMajorVersion = 2;
const c_int XTestMinorVersion = 2;
const String XTestExtensionName = "XTEST";
alias void function(void *, char *, c_int, c_int, char * *) _BCD_func__1414;
alias c_int function(void *) _BCD_func__1456;
alias c_int function(void *, XErrorEvent *) _BCD_func__1457;
alias void function(void *, char *, char *) _BCD_func__1530;
alias c_int function(void *, char *, char *) _BCD_func__1531;
alias void function(void *, char *, char *) _BCD_func__1532;
version(DYNLINK){
mixin(gshared!(
"extern (C) Status function(Display *)XTestDiscard;
extern (C) void function(Visual *, VisualID)XTestSetVisualIDOfVisual;
extern (C) void function(GC, GContext)XTestSetGContextOfGC;
extern (C) c_int function(Display *, Bool)XTestGrabControl;
extern (C) c_int function(Display *, XDevice *, Bool, c_int, c_int *, c_int, c_uint)XTestFakeDeviceMotionEvent;
extern (C) c_int function(Display *, XDevice *, Bool, c_int *, c_int, c_uint)XTestFakeProximityEvent;
extern (C) c_int function(Display *, XDevice *, c_uint, Bool, c_int *, c_int, c_uint)XTestFakeDeviceButtonEvent;
extern (C) c_int function(Display *, XDevice *, c_uint, Bool, c_int *, c_int, c_uint)XTestFakeDeviceKeyEvent;
extern (C) c_int function(Display *, c_int, c_int, c_uint)XTestFakeRelativeMotionEvent;
extern (C) c_int function(Display *, c_int, c_int, c_int, c_uint)XTestFakeMotionEvent;
extern (C) c_int function(Display *, c_uint, Bool , c_uint)XTestFakeButtonEvent;
extern (C) c_int function(Display *, c_uint, Bool, c_uint)XTestFakeKeyEvent;
extern (C) Bool function(Display *, Window)XTestCompareCurrentCursorWithWindow;
extern (C) Bool function(Display *, Window, Cursor)XTestCompareCursorWithWindow;
extern (C) Bool function(Display *, c_int *, c_int *, c_int *, c_int *)XTestQueryExtension;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("XTestDiscard",  cast(void**)& XTestDiscard),
        Symbol("XTestSetVisualIDOfVisual",  cast(void**)& XTestSetVisualIDOfVisual),
        Symbol("XTestSetGContextOfGC",  cast(void**)& XTestSetGContextOfGC),
        Symbol("XTestGrabControl",  cast(void**)& XTestGrabControl),
        Symbol("XTestFakeDeviceMotionEvent",  cast(void**)& XTestFakeDeviceMotionEvent),
        Symbol("XTestFakeProximityEvent",  cast(void**)& XTestFakeProximityEvent),
        Symbol("XTestFakeDeviceButtonEvent",  cast(void**)& XTestFakeDeviceButtonEvent),
        Symbol("XTestFakeDeviceKeyEvent",  cast(void**)& XTestFakeDeviceKeyEvent),
        Symbol("XTestFakeRelativeMotionEvent",  cast(void**)& XTestFakeRelativeMotionEvent),
        Symbol("XTestFakeMotionEvent",  cast(void**)& XTestFakeMotionEvent),
        Symbol("XTestFakeButtonEvent",  cast(void**)& XTestFakeButtonEvent),
        Symbol("XTestFakeKeyEvent",  cast(void**)& XTestFakeKeyEvent),
        Symbol("XTestCompareCurrentCursorWithWindow",  cast(void**)& XTestCompareCurrentCursorWithWindow),
        Symbol("XTestCompareCursorWithWindow",  cast(void**)& XTestCompareCursorWithWindow),
        Symbol("XTestQueryExtension",  cast(void**)& XTestQueryExtension)
    ];
}

} else { // version(DYNLINK)
extern (C) Status XTestDiscard(Display *);
extern (C) void XTestSetVisualIDOfVisual(Visual *, VisualID);
extern (C) void XTestSetGContextOfGC(GC, GContext);
extern (C) c_int XTestGrabControl(Display *, Bool);
extern (C) c_int XTestFakeDeviceMotionEvent(Display *, XDevice *, Bool, c_int, c_int *, c_int, c_uint);
extern (C) c_int XTestFakeProximityEvent(Display *, XDevice *, Bool, c_int *, c_int, c_uint);
extern (C) c_int XTestFakeDeviceButtonEvent(Display *, XDevice *, c_uint, Bool, c_int *, c_int, c_uint);
extern (C) c_int XTestFakeDeviceKeyEvent(Display *, XDevice *, c_uint, Bool, c_int *, c_int, c_uint);
extern (C) c_int XTestFakeRelativeMotionEvent(Display *, c_int, c_int, c_uint);
extern (C) c_int XTestFakeMotionEvent(Display *, c_int, c_int, c_int, c_uint);
extern (C) c_int XTestFakeButtonEvent(Display *, c_uint, Bool , c_uint);
extern (C) c_int XTestFakeKeyEvent(Display *, c_uint, Bool, c_uint);
extern (C) Bool XTestCompareCurrentCursorWithWindow(Display *, Window);
extern (C) Bool XTestCompareCursorWithWindow(Display *, Window, Cursor);
extern (C) Bool XTestQueryExtension(Display *, c_int *, c_int *, c_int *, c_int *);
} // version(DYNLINK)

