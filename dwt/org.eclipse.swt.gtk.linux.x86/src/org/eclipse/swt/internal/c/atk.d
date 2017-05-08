/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <benoit@tionex.de>
******************************************************************************/
module org.eclipse.swt.internal.c.atk;

import java.lang.all;

public import org.eclipse.swt.internal.c.glib_object;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):


alias _AtkValueIface AtkValueIface;
alias void AtkValue;
alias void function(void *, _GValue *) _BCD_func__4131;
alias gint function(void *, _GValue *) _BCD_func__4132;
alias gint function(void *) _BCD_func__2817;
alias _BCD_func__2817 AtkFunction;
alias _AtkMiscClass AtkMiscClass;
alias _AtkMisc AtkMisc;
alias void function(_AtkMisc *) _BCD_func__4134;
alias _AtkTableIface AtkTableIface;
alias _AtkObject AtkObject;
alias void AtkTable;
alias _AtkObject * function(void *, gint, gint) _BCD_func__4137;
alias gint function(void *, gint, gint) _BCD_func__4138;
alias gint function(void *, gint) _BCD_func__4139;
alias gint function(void *) _BCD_func__4140;
alias _AtkObject * function(void *) _BCD_func__4141;
alias char * function(void *, gint) _BCD_func__4142;
alias _AtkObject * function(void *, gint) _BCD_func__4143;
alias void function(void *, _AtkObject *) _BCD_func__4144;
alias void function(void *, gint, char *) _BCD_func__4145;
alias void function(void *, gint, _AtkObject *) _BCD_func__4146;
alias gint function(void *, gint * *) _BCD_func__4147;
alias gint function(void *, gint) _BCD_func__4148;
alias gint function(void *, gint, gint) _BCD_func__4149;
alias void function(void *, gint, gint) _BCD_func__4150;
alias void function(void *) _BCD_func__4151;
alias _AtkStreamableContentIface AtkStreamableContentIface;
alias void AtkStreamableContent;
alias gint function(void *) _BCD_func__4153;
alias char * function(void *, gint) _BCD_func__4154;
alias _GIOChannel * function(void *, char *) _BCD_func__4155;
alias char * function(void *, char *) _BCD_func__4156;
alias _AtkStateSetClass AtkStateSetClass;
alias _AtkSelectionIface AtkSelectionIface;
alias void AtkSelection;
alias gint function(void *, gint) _BCD_func__4159;
alias gint function(void *) _BCD_func__4160;
alias _AtkObject * function(void *, gint) _BCD_func__4161;
alias gint function(void *) _BCD_func__4162;
alias void function(void *) _BCD_func__4163;
alias _AtkRelationSetClass AtkRelationSetClass;
alias _AtkRelationClass AtkRelationClass;
alias _AtkRelation AtkRelation;
enum AtkRelationType {
ATK_RELATION_NULL=0,
ATK_RELATION_CONTROLLED_BY=1,
ATK_RELATION_CONTROLLER_FOR=2,
ATK_RELATION_LABEL_FOR=3,
ATK_RELATION_LABELLED_BY=4,
ATK_RELATION_MEMBER_OF=5,
ATK_RELATION_NODE_CHILD_OF=6,
ATK_RELATION_FLOWS_TO=7,
ATK_RELATION_FLOWS_FROM=8,
ATK_RELATION_SUBWINDOW_OF=9,
ATK_RELATION_EMBEDS=10,
ATK_RELATION_EMBEDDED_BY=11,
ATK_RELATION_POPUP_FOR=12,
ATK_RELATION_PARENT_WINDOW_OF=13,
ATK_RELATION_DESCRIBED_BY=14,
ATK_RELATION_DESCRIPTION_FOR=15,
ATK_RELATION_LAST_DEFINED=16,
}
alias _AtkRegistryClass AtkRegistryClass;
alias _AtkRegistry AtkRegistry;
alias _AtkNoOpObjectFactoryClass AtkNoOpObjectFactoryClass;
alias _AtkObjectFactoryClass AtkObjectFactoryClass;
alias _AtkNoOpObjectFactory AtkNoOpObjectFactory;
alias _AtkObjectFactory AtkObjectFactory;
alias _AtkObject * function(_GObject *) _BCD_func__4172;
alias void function(_AtkObjectFactory *) _BCD_func__4173;
alias GType function() _BCD_func__4174;
alias _AtkNoOpObjectClass AtkNoOpObjectClass;
alias _AtkObjectClass AtkObjectClass;
alias _AtkNoOpObject AtkNoOpObject;
alias _AtkImageIface AtkImageIface;
alias void AtkImage;
enum AtkCoordType {
ATK_XY_SCREEN=0,
ATK_XY_WINDOW=1,
}
alias void function(void *, gint *, gint *, gint) _BCD_func__4179;
alias char * function(void *) _BCD_func__4180;
alias void function(void *, gint *, gint *) _BCD_func__4181;
alias gint function(void *, char *) _BCD_func__4182;
alias _AtkHypertextIface AtkHypertextIface;
alias _AtkHyperlink AtkHyperlink;
alias void AtkHypertext;
alias _AtkHyperlink * function(void *, gint) _BCD_func__4184;
alias gint function(void *) _BCD_func__4185;
alias gint function(void *, gint) _BCD_func__4186;
alias void function(void *, gint) _BCD_func__4187;
alias _AtkHyperlinkImplIface AtkHyperlinkImplIface;
alias void AtkHyperlinkImpl;
alias _AtkHyperlink * function(void *) _BCD_func__4189;
alias _AtkHyperlinkClass AtkHyperlinkClass;
alias char * function(_AtkHyperlink *, gint) _BCD_func__4191;
alias _AtkObject * function(_AtkHyperlink *, gint) _BCD_func__4192;
alias gint function(_AtkHyperlink *) _BCD_func__4193;
alias gint function(_AtkHyperlink *) _BCD_func__4194;
alias guint function(_AtkHyperlink *) _BCD_func__4195;
alias void function(_AtkHyperlink *) _BCD_func__4196;
enum AtkHyperlinkStateFlags {
ATK_HYPERLINK_IS_INLINE=1,
}
alias _AtkGObjectAccessibleClass AtkGObjectAccessibleClass;
alias _AtkGObjectAccessible AtkGObjectAccessible;
alias _AtkEditableTextIface AtkEditableTextIface;
alias void AtkEditableText;
alias _GSList AtkAttributeSet;
alias gint function(void *, _GSList *, gint, gint) _BCD_func__4201;
alias void function(void *, char *) _BCD_func__4202;
alias void function(void *, char *, gint, gint *) _BCD_func__4203;
alias void function(void *, gint, gint) _BCD_func__4204;
alias void function(void *, gint) _BCD_func__4205;
enum AtkTextClipType {
ATK_TEXT_CLIP_NONE=0,
ATK_TEXT_CLIP_MIN=1,
ATK_TEXT_CLIP_MAX=2,
ATK_TEXT_CLIP_BOTH=3,
}
alias _AtkTextRange AtkTextRange;
alias _AtkTextRectangle AtkTextRectangle;
enum AtkTextBoundary {
ATK_TEXT_BOUNDARY_CHAR=0,
ATK_TEXT_BOUNDARY_WORD_START=1,
ATK_TEXT_BOUNDARY_WORD_END=2,
ATK_TEXT_BOUNDARY_SENTENCE_START=3,
ATK_TEXT_BOUNDARY_SENTENCE_END=4,
ATK_TEXT_BOUNDARY_LINE_START=5,
ATK_TEXT_BOUNDARY_LINE_END=6,
}
alias _AtkTextIface AtkTextIface;
alias void AtkText;
alias char * function(void *, gint, gint) _BCD_func__4209;
alias char * function(void *, gint, gint, gint *, gint *) _BCD_func__4210;
alias gunichar function(void *, gint) _BCD_func__4211;
alias gint function(void *) _BCD_func__4212;
alias _GSList * function(void *, gint, gint *, gint *) _BCD_func__4213;
alias _GSList * function(void *) _BCD_func__4214;
alias void function(void *, gint, gint *, gint *, gint *, gint *, gint) _BCD_func__4215;
alias gint function(void *, gint, gint, gint) _BCD_func__4216;
alias char * function(void *, gint, gint *, gint *) _BCD_func__4217;
alias gint function(void *, gint, gint) _BCD_func__4218;
alias gint function(void *, gint) _BCD_func__4219;
alias gint function(void *, gint, gint, gint) _BCD_func__4220;
alias void function(void *, gint, gint) _BCD_func__4221;
alias void function(void *, gint) _BCD_func__4222;
alias void function(void *) _BCD_func__4223;
alias void function(void *, gint, gint, gint, _AtkTextRectangle *) _BCD_func__4224;
alias _AtkTextRange * * function(void *, _AtkTextRectangle *, gint, gint, gint) _BCD_func__4225;
enum AtkTextAttribute {
ATK_TEXT_ATTR_INVALID=0,
ATK_TEXT_ATTR_LEFT_MARGIN=1,
ATK_TEXT_ATTR_RIGHT_MARGIN=2,
ATK_TEXT_ATTR_INDENT=3,
ATK_TEXT_ATTR_INVISIBLE=4,
ATK_TEXT_ATTR_EDITABLE=5,
ATK_TEXT_ATTR_PIXELS_ABOVE_LINES=6,
ATK_TEXT_ATTR_PIXELS_BELOW_LINES=7,
ATK_TEXT_ATTR_PIXELS_INSIDE_WRAP=8,
ATK_TEXT_ATTR_BG_FULL_HEIGHT=9,
ATK_TEXT_ATTR_RISE=10,
ATK_TEXT_ATTR_UNDERLINE=11,
ATK_TEXT_ATTR_STRIKETHROUGH=12,
ATK_TEXT_ATTR_SIZE=13,
ATK_TEXT_ATTR_SCALE=14,
ATK_TEXT_ATTR_WEIGHT=15,
ATK_TEXT_ATTR_LANGUAGE=16,
ATK_TEXT_ATTR_FAMILY_NAME=17,
ATK_TEXT_ATTR_BG_COLOR=18,
ATK_TEXT_ATTR_FG_COLOR=19,
ATK_TEXT_ATTR_BG_STIPPLE=20,
ATK_TEXT_ATTR_FG_STIPPLE=21,
ATK_TEXT_ATTR_WRAP_MODE=22,
ATK_TEXT_ATTR_DIRECTION=23,
ATK_TEXT_ATTR_JUSTIFICATION=24,
ATK_TEXT_ATTR_STRETCH=25,
ATK_TEXT_ATTR_VARIANT=26,
ATK_TEXT_ATTR_STYLE=27,
ATK_TEXT_ATTR_LAST_DEFINED=28,
}
alias _AtkDocumentIface AtkDocumentIface;
alias void AtkDocument;
alias char * function(void *) _BCD_func__4227;
alias void * function(void *) _BCD_func__4228;
alias _GSList * function(void *) _BCD_func__4229;
alias char * function(void *, char *) _BCD_func__4230;
alias gint function(void *, char *, char *) _BCD_func__4231;
alias _AtkRectangle AtkRectangle;
alias void function(_AtkObject *, gint) _BCD_func__2758;
alias _BCD_func__2758 AtkFocusHandler;
alias _AtkComponentIface AtkComponentIface;
alias void AtkComponent;
alias guint function(void *, _BCD_func__2758) _BCD_func__4234;
alias gint function(void *, gint, gint, gint) _BCD_func__4235;
alias _AtkObject * function(void *, gint, gint, gint) _BCD_func__4236;
alias void function(void *, gint *, gint *, gint *, gint *, gint) _BCD_func__4237;
alias void function(void *, gint *, gint *, gint) _BCD_func__4238;
alias void function(void *, gint *, gint *) _BCD_func__4239;
alias gint function(void *) _BCD_func__4240;
alias void function(void *, guint) _BCD_func__4241;
alias gint function(void *, gint, gint, gint, gint, gint) _BCD_func__4242;
alias gint function(void *, gint, gint) _BCD_func__4243;
enum AtkLayer {
ATK_LAYER_INVALID=0,
ATK_LAYER_BACKGROUND=1,
ATK_LAYER_CANVAS=2,
ATK_LAYER_WIDGET=3,
ATK_LAYER_MDI=4,
ATK_LAYER_POPUP=5,
ATK_LAYER_OVERLAY=6,
ATK_LAYER_WINDOW=7,
}
alias gint function(void *) _BCD_func__4244;
alias gint function(void *) _BCD_func__4245;
alias void function(void *, _AtkRectangle *) _BCD_func__4246;
alias double function(void *) _BCD_func__4247;
enum AtkKeyEventType {
ATK_KEY_EVENT_PRESS=0,
ATK_KEY_EVENT_RELEASE=1,
ATK_KEY_EVENT_LAST_DEFINED=2,
}
alias _AtkKeyEventStruct AtkKeyEventStruct;
alias gint function(_AtkKeyEventStruct *, void *) _BCD_func__2777;
alias _BCD_func__2777 AtkKeySnoopFunc;
alias void function() _BCD_func__2778;
alias _BCD_func__2778 AtkEventListenerInit;
alias void function(_AtkObject *) _BCD_func__2779;
alias _BCD_func__2779 AtkEventListener;
alias _AtkUtilClass AtkUtilClass;
alias gint function(_GSignalInvocationHint *, guint, _GValue *, void *) _BCD_func__3077;
alias guint function(_BCD_func__3077, char *) _BCD_func__4250;
alias void function(guint) _BCD_func__4251;
alias guint function(_BCD_func__2777, void *) _BCD_func__4252;
alias _AtkObject * function() _BCD_func__4253;
alias char * function() _BCD_func__4254;
alias _AtkUtil AtkUtil;
alias _AtkActionIface AtkActionIface;
alias void AtkAction;
alias gint function(void *, gint) _BCD_func__4257;
alias gint function(void *) _BCD_func__4258;
alias char * function(void *, gint) _BCD_func__4259;
alias gint function(void *, gint, char *) _BCD_func__4260;
alias _AtkPropertyValues AtkPropertyValues;
alias void function(_AtkObject *, _AtkPropertyValues *) _BCD_func__2816;
alias _BCD_func__2816 AtkPropertyChangeHandler;
alias _AtkStateSet AtkStateSet;
alias _AtkRelationSet AtkRelationSet;
alias char * function(_AtkObject *) _BCD_func__4265;
alias _AtkObject * function(_AtkObject *) _BCD_func__4266;
alias gint function(_AtkObject *) _BCD_func__4267;
alias _AtkObject * function(_AtkObject *, gint) _BCD_func__4268;
alias _AtkRelationSet * function(_AtkObject *) _BCD_func__4269;
enum AtkRole {
ATK_ROLE_INVALID=0,
ATK_ROLE_ACCEL_LABEL=1,
ATK_ROLE_ALERT=2,
ATK_ROLE_ANIMATION=3,
ATK_ROLE_ARROW=4,
ATK_ROLE_CALENDAR=5,
ATK_ROLE_CANVAS=6,
ATK_ROLE_CHECK_BOX=7,
ATK_ROLE_CHECK_MENU_ITEM=8,
ATK_ROLE_COLOR_CHOOSER=9,
ATK_ROLE_COLUMN_HEADER=10,
ATK_ROLE_COMBO_BOX=11,
ATK_ROLE_DATE_EDITOR=12,
ATK_ROLE_DESKTOP_ICON=13,
ATK_ROLE_DESKTOP_FRAME=14,
ATK_ROLE_DIAL=15,
ATK_ROLE_DIALOG=16,
ATK_ROLE_DIRECTORY_PANE=17,
ATK_ROLE_DRAWING_AREA=18,
ATK_ROLE_FILE_CHOOSER=19,
ATK_ROLE_FILLER=20,
ATK_ROLE_FONT_CHOOSER=21,
ATK_ROLE_FRAME=22,
ATK_ROLE_GLASS_PANE=23,
ATK_ROLE_HTML_CONTAINER=24,
ATK_ROLE_ICON=25,
ATK_ROLE_IMAGE=26,
ATK_ROLE_INTERNAL_FRAME=27,
ATK_ROLE_LABEL=28,
ATK_ROLE_LAYERED_PANE=29,
ATK_ROLE_LIST=30,
ATK_ROLE_LIST_ITEM=31,
ATK_ROLE_MENU=32,
ATK_ROLE_MENU_BAR=33,
ATK_ROLE_MENU_ITEM=34,
ATK_ROLE_OPTION_PANE=35,
ATK_ROLE_PAGE_TAB=36,
ATK_ROLE_PAGE_TAB_LIST=37,
ATK_ROLE_PANEL=38,
ATK_ROLE_PASSWORD_TEXT=39,
ATK_ROLE_POPUP_MENU=40,
ATK_ROLE_PROGRESS_BAR=41,
ATK_ROLE_PUSH_BUTTON=42,
ATK_ROLE_RADIO_BUTTON=43,
ATK_ROLE_RADIO_MENU_ITEM=44,
ATK_ROLE_ROOT_PANE=45,
ATK_ROLE_ROW_HEADER=46,
ATK_ROLE_SCROLL_BAR=47,
ATK_ROLE_SCROLL_PANE=48,
ATK_ROLE_SEPARATOR=49,
ATK_ROLE_SLIDER=50,
ATK_ROLE_SPLIT_PANE=51,
ATK_ROLE_SPIN_BUTTON=52,
ATK_ROLE_STATUSBAR=53,
ATK_ROLE_TABLE=54,
ATK_ROLE_TABLE_CELL=55,
ATK_ROLE_TABLE_COLUMN_HEADER=56,
ATK_ROLE_TABLE_ROW_HEADER=57,
ATK_ROLE_TEAR_OFF_MENU_ITEM=58,
ATK_ROLE_TERMINAL=59,
ATK_ROLE_TEXT=60,
ATK_ROLE_TOGGLE_BUTTON=61,
ATK_ROLE_TOOL_BAR=62,
ATK_ROLE_TOOL_TIP=63,
ATK_ROLE_TREE=64,
ATK_ROLE_TREE_TABLE=65,
ATK_ROLE_UNKNOWN=66,
ATK_ROLE_VIEWPORT=67,
ATK_ROLE_WINDOW=68,
ATK_ROLE_HEADER=69,
ATK_ROLE_FOOTER=70,
ATK_ROLE_PARAGRAPH=71,
ATK_ROLE_RULER=72,
ATK_ROLE_APPLICATION=73,
ATK_ROLE_AUTOCOMPLETE=74,
ATK_ROLE_EDITBAR=75,
ATK_ROLE_EMBEDDED=76,
ATK_ROLE_ENTRY=77,
ATK_ROLE_CHART=78,
ATK_ROLE_CAPTION=79,
ATK_ROLE_DOCUMENT_FRAME=80,
ATK_ROLE_HEADING=81,
ATK_ROLE_PAGE=82,
ATK_ROLE_SECTION=83,
ATK_ROLE_REDUNDANT_OBJECT=84,
ATK_ROLE_FORM=85,
ATK_ROLE_LINK=86,
ATK_ROLE_INPUT_METHOD_WINDOW=87,
ATK_ROLE_LAST_DEFINED=88,
}
alias gint function(_AtkObject *) _BCD_func__4270;
alias gint function(_AtkObject *) _BCD_func__4271;
alias _AtkStateSet * function(_AtkObject *) _BCD_func__4272;
alias void function(_AtkObject *, char *) _BCD_func__4273;
alias void function(_AtkObject *, _AtkObject *) _BCD_func__4274;
alias void function(_AtkObject *, gint) _BCD_func__4275;
alias guint function(_AtkObject *, _BCD_func__2816 *) _BCD_func__4276;
alias void function(_AtkObject *, guint) _BCD_func__4277;
alias void function(_AtkObject *, void *) _BCD_func__4278;
alias void function(_AtkObject *, guint, void *) _BCD_func__4279;
alias void function(_AtkObject *, char *, gint) _BCD_func__4280;
alias void function(_AtkObject *, void * *) _BCD_func__4281;
alias _GSList * function(_AtkObject *) _BCD_func__4282;
alias _AtkImplementorIface AtkImplementorIface;
alias void AtkImplementor;
alias _AtkObject * function(void *) _BCD_func__4285;
alias _AtkAttribute AtkAttribute;
alias ulong AtkState;
enum AtkStateType {
ATK_STATE_INVALID=0,
ATK_STATE_ACTIVE=1,
ATK_STATE_ARMED=2,
ATK_STATE_BUSY=3,
ATK_STATE_CHECKED=4,
ATK_STATE_DEFUNCT=5,
ATK_STATE_EDITABLE=6,
ATK_STATE_ENABLED=7,
ATK_STATE_EXPANDABLE=8,
ATK_STATE_EXPANDED=9,
ATK_STATE_FOCUSABLE=10,
ATK_STATE_FOCUSED=11,
ATK_STATE_HORIZONTAL=12,
ATK_STATE_ICONIFIED=13,
ATK_STATE_MODAL=14,
ATK_STATE_MULTI_LINE=15,
ATK_STATE_MULTISELECTABLE=16,
ATK_STATE_OPAQUE=17,
ATK_STATE_PRESSED=18,
ATK_STATE_RESIZABLE=19,
ATK_STATE_SELECTABLE=20,
ATK_STATE_SELECTED=21,
ATK_STATE_SENSITIVE=22,
ATK_STATE_SHOWING=23,
ATK_STATE_SINGLE_LINE=24,
ATK_STATE_STALE=25,
ATK_STATE_TRANSIENT=26,
ATK_STATE_VERTICAL=27,
ATK_STATE_VISIBLE=28,
ATK_STATE_MANAGES_DESCENDANTS=29,
ATK_STATE_INDETERMINATE=30,
ATK_STATE_TRUNCATED=31,
ATK_STATE_REQUIRED=32,
ATK_STATE_INVALID_ENTRY=33,
ATK_STATE_SUPPORTS_AUTOCOMPLETION=34,
ATK_STATE_SELECTABLE_TEXT=35,
ATK_STATE_DEFAULT=36,
ATK_STATE_ANIMATED=37,
ATK_STATE_VISITED=38,
ATK_STATE_LAST_DEFINED=39,
}
alias void function(void *, guint, guint, _GInterfaceInfo *) _BCD_func__2892;
alias void function(void *, guint, _GTypeInfo *, _GTypeValueTable *) _BCD_func__2893;
alias void function(void *) _BCD_func__2894;
alias void function(void *, _GObject *, gint) _BCD_func__3041;
alias void function(void *, _GObject *) _BCD_func__3047;
alias void function(_GObject *) _BCD_func__3048;
alias void function(_GObject *, guint, _GValue *, _GParamSpec *) _BCD_func__3049;
alias void function(_GObject *, guint, _GValue *, _GParamSpec *) _BCD_func__3050;
alias gint function(_GSignalInvocationHint *, _GValue *, _GValue *, void *) _BCD_func__3076;
alias void function(_GClosure *, _GValue *, guint, _GValue *, void *, void *) _BCD_func__3078;
alias void function(void *, _GClosure *) _BCD_func__3097;
alias void function(_GValue *, _GValue *) _BCD_func__3155;
alias void function(void *) _BCD_func__3183;
alias void * function(void *) _BCD_func__3184;
alias void function(void *, void *) _BCD_func__3188;
alias gint function(void *, _GTypeClass *) _BCD_func__3189;
alias void function(_GTypeInstance *, void *) _BCD_func__3190;
alias gint function(void *, void *, void *) _BCD_func__3244;
alias gint function(void *, void *, void *) _BCD_func__3262;
alias void function(_GScanner *, char *, gint) _BCD_func__3265;
alias gint function(void *, _GString *, void *) _BCD_func__3338;
alias void function(void *, void *, void *, _GError * *) _BCD_func__3356;
alias gint function(void *, void *, void *, _GError * *) _BCD_func__3357;
alias gint function(char *, char *, void *, _GError * *) _BCD_func__3358;
alias void * function(void *, void *) _BCD_func__3369;
alias void function(_GNode *, void *) _BCD_func__3370;
alias gint function(_GNode *, void *) _BCD_func__3371;
alias void function(char *) _BCD_func__3379;
alias void function(char *, gint, char *, void *) _BCD_func__3381;
alias gint function(_GIOChannel *, gint, void *) _BCD_func__3399;
alias gint function(_GPollFD *, guint, gint) _BCD_func__3452;
alias void function(gint, gint, void *) _BCD_func__3458;
alias void function(_GHookList *, _GHook *) _BCD_func__3490;
alias gint function(_GHook *, void *) _BCD_func__3491;
alias void function(_GHook *, void *) _BCD_func__3492;
alias gint function(_GHook *, _GHook *) _BCD_func__3493;
alias void function(guint, void *, void *) _BCD_func__3527;
alias gint function(char *, char *, guint) _BCD_func__3530;
alias char * function(void *) _BCD_func__3531;
alias char * function(char *, void *) _BCD_func__3722;
alias void function(void *, void *, void *) _BCD_func__3723;
alias guint function(void *) _BCD_func__3724;
alias gint function(void *, void *) _BCD_func__3725;
alias gint function(void *, void *, void *) _BCD_func__3726;
alias gint function(void *, void *) _BCD_func__3727;
struct _AtkValueIface {
_GTypeInterface parent;
_BCD_func__4131 get_current_value;
_BCD_func__4131 get_maximum_value;
_BCD_func__4131 get_minimum_value;
_BCD_func__4132 set_current_value;
_BCD_func__4131 get_minimum_increment;
_BCD_func__2817 pad1;
}
struct _AtkMiscClass {
_GObjectClass parent;
_BCD_func__4134 threads_enter;
_BCD_func__4134 threads_leave;
void * [32] vfuncs;
}
struct _AtkMisc {
_GObject parent;
}
struct _AtkTableIface {
_GTypeInterface parent;
_BCD_func__4137 ref_at;
_BCD_func__4138 get_index_at;
_BCD_func__4139 get_column_at_index;
_BCD_func__4139 get_row_at_index;
_BCD_func__4140 get_n_columns;
_BCD_func__4140 get_n_rows;
_BCD_func__4138 get_column_extent_at;
_BCD_func__4138 get_row_extent_at;
_BCD_func__4141 get_caption;
_BCD_func__4142 get_column_description;
_BCD_func__4143 get_column_header;
_BCD_func__4142 get_row_description;
_BCD_func__4143 get_row_header;
_BCD_func__4141 get_summary;
_BCD_func__4144 set_caption;
_BCD_func__4145 set_column_description;
_BCD_func__4146 set_column_header;
_BCD_func__4145 set_row_description;
_BCD_func__4146 set_row_header;
_BCD_func__4144 set_summary;
_BCD_func__4147 get_selected_columns;
_BCD_func__4147 get_selected_rows;
_BCD_func__4148 is_column_selected;
_BCD_func__4148 is_row_selected;
_BCD_func__4149 is_selected;
_BCD_func__4148 add_row_selection;
_BCD_func__4148 remove_row_selection;
_BCD_func__4148 add_column_selection;
_BCD_func__4148 remove_column_selection;
_BCD_func__4150 row_inserted;
_BCD_func__4150 column_inserted;
_BCD_func__4150 row_deleted;
_BCD_func__4150 column_deleted;
_BCD_func__4151 row_reordered;
_BCD_func__4151 column_reordered;
_BCD_func__4151 model_changed;
_BCD_func__2817 pad1;
_BCD_func__2817 pad2;
_BCD_func__2817 pad3;
_BCD_func__2817 pad4;
}
struct _AtkStreamableContentIface {
_GTypeInterface parent;
_BCD_func__4153 get_n_mime_types;
_BCD_func__4154 get_mime_type;
_BCD_func__4155 get_stream;
_BCD_func__4156 get_uri;
_BCD_func__2817 pad1;
_BCD_func__2817 pad2;
_BCD_func__2817 pad3;
}
struct _AtkStateSetClass {
_GObjectClass parent;
}
struct _AtkSelectionIface {
_GTypeInterface parent;
_BCD_func__4159 add_selection;
_BCD_func__4160 clear_selection;
_BCD_func__4161 ref_selection;
_BCD_func__4162 get_selection_count;
_BCD_func__4159 is_child_selected;
_BCD_func__4159 remove_selection;
_BCD_func__4160 select_all_selection;
_BCD_func__4163 selection_changed;
_BCD_func__2817 pad1;
_BCD_func__2817 pad2;
}
struct _AtkRelationSetClass {
_GObjectClass parent;
_BCD_func__2817 pad1;
_BCD_func__2817 pad2;
}
struct _AtkRelationClass {
_GObjectClass parent;
}
struct _AtkRelation {
_GObject parent;
_GPtrArray * target;
gint relationship;
}
struct _AtkRegistryClass {
_GObjectClass parent_class;
}
struct _AtkRegistry {
_GObject parent;
void * factory_type_registry;
void * factory_singleton_cache;
}
struct _AtkNoOpObjectFactoryClass {
_AtkObjectFactoryClass parent_class;
}
struct _AtkNoOpObjectFactory {
_AtkObjectFactory parent;
}
struct _AtkObjectFactoryClass {
_GObjectClass parent_class;
_BCD_func__4172 create_accessible;
_BCD_func__4173 invalidate;
_BCD_func__4174 get_accessible_type;
_BCD_func__2817 pad1;
_BCD_func__2817 pad2;
}
struct _AtkObjectFactory {
_GObject parent;
}
struct _AtkNoOpObjectClass {
_AtkObjectClass parent_class;
}
struct _AtkNoOpObject {
_AtkObject parent;
}
struct _AtkImageIface {
_GTypeInterface parent;
_BCD_func__4179 get_image_position;
_BCD_func__4180 get_image_description;
_BCD_func__4181 get_image_size;
_BCD_func__4182 set_image_description;
_BCD_func__4180 get_image_locale;
_BCD_func__2817 pad1;
}
struct _AtkHypertextIface {
_GTypeInterface parent;
_BCD_func__4184 get_link;
_BCD_func__4185 get_n_links;
_BCD_func__4186 get_link_index;
_BCD_func__4187 link_selected;
_BCD_func__2817 pad1;
_BCD_func__2817 pad2;
_BCD_func__2817 pad3;
}
struct _AtkHyperlinkImplIface {
_GTypeInterface parent;
_BCD_func__4189 get_hyperlink;
_BCD_func__2817 pad1;
}
struct _AtkHyperlinkClass {
_GObjectClass parent;
_BCD_func__4191 get_uri;
_BCD_func__4192 get_object;
_BCD_func__4193 get_end_index;
_BCD_func__4193 get_start_index;
_BCD_func__4194 is_valid;
_BCD_func__4193 get_n_anchors;
_BCD_func__4195 link_state;
_BCD_func__4194 is_selected_link;
_BCD_func__4196 link_activated;
_BCD_func__2817 pad1;
}
struct _AtkHyperlink {
_GObject parent;
}
struct _AtkGObjectAccessibleClass {
_AtkObjectClass parent_class;
_BCD_func__2817 pad1;
_BCD_func__2817 pad2;
}
struct _AtkGObjectAccessible {
_AtkObject parent;
}
struct _AtkEditableTextIface {
_GTypeInterface parent_interface;
_BCD_func__4201 set_run_attributes;
_BCD_func__4202 set_text_contents;
_BCD_func__4203 insert_text;
_BCD_func__4204 copy_text;
_BCD_func__4204 cut_text;
_BCD_func__4204 delete_text;
_BCD_func__4205 paste_text;
_BCD_func__2817 pad1;
_BCD_func__2817 pad2;
}
struct _AtkTextRange {
_AtkTextRectangle bounds;
gint start_offset;
gint end_offset;
char * content;
}
struct _AtkTextRectangle {
gint x;
gint y;
gint width;
gint height;
}
struct _AtkTextIface {
_GTypeInterface parent;
_BCD_func__4209 get_text;
_BCD_func__4210 get_text_after_offset;
_BCD_func__4210 get_text_at_offset;
_BCD_func__4211 get_character_at_offset;
_BCD_func__4210 get_text_before_offset;
_BCD_func__4212 get_caret_offset;
_BCD_func__4213 get_run_attributes;
_BCD_func__4214 get_default_attributes;
_BCD_func__4215 get_character_extents;
_BCD_func__4212 get_character_count;
_BCD_func__4216 get_offset_at_point;
_BCD_func__4212 get_n_selections;
_BCD_func__4217 get_selection;
_BCD_func__4218 add_selection;
_BCD_func__4219 remove_selection;
_BCD_func__4220 set_selection;
_BCD_func__4219 set_caret_offset;
_BCD_func__4221 text_changed;
_BCD_func__4222 text_caret_moved;
_BCD_func__4223 text_selection_changed;
_BCD_func__4223 text_attributes_changed;
_BCD_func__4224 get_range_extents;
_BCD_func__4225 get_bounded_ranges;
_BCD_func__2817 pad4;
}
struct _AtkDocumentIface {
_GTypeInterface parent;
_BCD_func__4227 get_document_type;
_BCD_func__4228 get_document;
_BCD_func__4227 get_document_locale;
_BCD_func__4229 get_document_attributes;
_BCD_func__4230 get_document_attribute_value;
_BCD_func__4231 set_document_attribute;
_BCD_func__2817 pad1;
_BCD_func__2817 pad2;
_BCD_func__2817 pad3;
_BCD_func__2817 pad4;
}
struct _AtkRectangle {
gint x;
gint y;
gint width;
gint height;
}
struct _AtkComponentIface {
_GTypeInterface parent;
_BCD_func__4234 add_focus_handler;
_BCD_func__4235 contains;
_BCD_func__4236 ref_accessible_at_point;
_BCD_func__4237 get_extents;
_BCD_func__4238 get_position;
_BCD_func__4239 get_size;
_BCD_func__4240 grab_focus;
_BCD_func__4241 remove_focus_handler;
_BCD_func__4242 set_extents;
_BCD_func__4235 set_position;
_BCD_func__4243 set_size;
_BCD_func__4244 get_layer;
_BCD_func__4245 get_mdi_zorder;
_BCD_func__4246 bounds_changed;
_BCD_func__4247 get_alpha;
}
struct _AtkKeyEventStruct {
gint type;
guint state;
guint keyval;
gint length;
char * string;
ushort keycode;
guint32 timestamp;
}
struct _AtkUtilClass {
_GObjectClass parent;
_BCD_func__4250 add_global_event_listener;
_BCD_func__4251 remove_global_event_listener;
_BCD_func__4252 add_key_event_listener;
_BCD_func__4251 remove_key_event_listener;
_BCD_func__4253 get_root;
_BCD_func__4254 get_toolkit_name;
_BCD_func__4254 get_toolkit_version;
}
struct _AtkUtil {
_GObject parent;
}
struct _AtkActionIface {
_GTypeInterface parent;
_BCD_func__4257 do_action;
_BCD_func__4258 get_n_actions;
_BCD_func__4259 get_description;
_BCD_func__4259 get_name;
_BCD_func__4259 get_keybinding;
_BCD_func__4260 set_description;
_BCD_func__4259 get_localized_name;
_BCD_func__2817 pad2;
}
struct _AtkPropertyValues {
char * property_name;
_GValue old_value;
_GValue new_value;
}
struct _AtkStateSet {
_GObject parent;
}
struct _AtkRelationSet {
_GObject parent;
_GPtrArray * relations;
}
struct _AtkObjectClass {
_GObjectClass parent;
_BCD_func__4265 get_name;
_BCD_func__4265 get_description;
_BCD_func__4266 get_parent;
_BCD_func__4267 get_n_children;
_BCD_func__4268 ref_child;
_BCD_func__4267 get_index_in_parent;
_BCD_func__4269 ref_relation_set;
_BCD_func__4270 get_role;
_BCD_func__4271 get_layer;
_BCD_func__4267 get_mdi_zorder;
_BCD_func__4272 ref_state_set;
_BCD_func__4273 set_name;
_BCD_func__4273 set_description;
_BCD_func__4274 set_parent;
_BCD_func__4275 set_role;
_BCD_func__4276 connect_property_change_handler;
_BCD_func__4277 remove_property_change_handler;
_BCD_func__4278 initialize;
_BCD_func__4279 children_changed;
_BCD_func__2758 focus_event;
_BCD_func__2816 property_change;
_BCD_func__4280 state_change;
_BCD_func__2779 visible_data_changed;
_BCD_func__4281 active_descendant_changed;
_BCD_func__4282 get_attributes;
_BCD_func__2817 pad1;
_BCD_func__2817 pad2;
}
struct _AtkObject {
_GObject parent;
char * description;
char * name;
_AtkObject * accessible_parent;
gint role;
_AtkRelationSet * relation_set;
gint layer;
}
struct _AtkImplementorIface {
_GTypeInterface parent;
_BCD_func__4285 ref_accessible;
}
struct _AtkAttribute {
char * name;
char * value;
}
version(DYNLINK){
mixin(gshared!(
"extern (C) void function(void *, _GValue *)atk_value_get_minimum_increment;
extern (C) gint function(void *, _GValue *)atk_value_set_current_value;
extern (C) void function(void *, _GValue *)atk_value_get_minimum_value;
extern (C) void function(void *, _GValue *)atk_value_get_maximum_value;
extern (C) void function(void *, _GValue *)atk_value_get_current_value;
extern (C) GType function()atk_value_get_type;
extern (C) _AtkMisc * function()atk_misc_get_instance;
extern (C) void function(_AtkMisc *)atk_misc_threads_leave;
extern (C) void function(_AtkMisc *)atk_misc_threads_enter;
extern (C) GType function()atk_misc_get_type;
extern (C) extern _AtkMisc ** atk_misc_instance;
extern (C) gint function(void *, gint)atk_table_remove_column_selection;
extern (C) gint function(void *, gint)atk_table_add_column_selection;
extern (C) gint function(void *, gint)atk_table_remove_row_selection;
extern (C) gint function(void *, gint)atk_table_add_row_selection;
extern (C) gint function(void *, gint, gint)atk_table_is_selected;
extern (C) gint function(void *, gint)atk_table_is_row_selected;
extern (C) gint function(void *, gint)atk_table_is_column_selected;
extern (C) gint function(void *, gint * *)atk_table_get_selected_rows;
extern (C) gint function(void *, gint * *)atk_table_get_selected_columns;
extern (C) void function(void *, _AtkObject *)atk_table_set_summary;
extern (C) void function(void *, gint, _AtkObject *)atk_table_set_row_header;
extern (C) void function(void *, gint, char *)atk_table_set_row_description;
extern (C) void function(void *, gint, _AtkObject *)atk_table_set_column_header;
extern (C) void function(void *, gint, char *)atk_table_set_column_description;
extern (C) void function(void *, _AtkObject *)atk_table_set_caption;
extern (C) _AtkObject * function(void *)atk_table_get_summary;
extern (C) _AtkObject * function(void *, gint)atk_table_get_row_header;
extern (C) char * function(void *, gint)atk_table_get_row_description;
extern (C) _AtkObject * function(void *, gint)atk_table_get_column_header;
extern (C) char * function(void *, gint)atk_table_get_column_description;
extern (C) _AtkObject * function(void *)atk_table_get_caption;
extern (C) gint function(void *, gint, gint)atk_table_get_row_extent_at;
extern (C) gint function(void *, gint, gint)atk_table_get_column_extent_at;
extern (C) gint function(void *)atk_table_get_n_rows;
extern (C) gint function(void *)atk_table_get_n_columns;
extern (C) gint function(void *, gint)atk_table_get_row_at_index;
extern (C) gint function(void *, gint)atk_table_get_column_at_index;
extern (C) gint function(void *, gint, gint)atk_table_get_index_at;
extern (C) _AtkObject * function(void *, gint, gint)atk_table_ref_at;
extern (C) GType function()atk_table_get_type;
extern (C) char * function(void *, char *)atk_streamable_content_get_uri;
extern (C) _GIOChannel * function(void *, char *)atk_streamable_content_get_stream;
extern (C) char * function(void *, gint)atk_streamable_content_get_mime_type;
extern (C) gint function(void *)atk_streamable_content_get_n_mime_types;
extern (C) GType function()atk_streamable_content_get_type;
extern (C) _AtkStateSet * function(_AtkStateSet *, _AtkStateSet *)atk_state_set_xor_sets;
extern (C) _AtkStateSet * function(_AtkStateSet *, _AtkStateSet *)atk_state_set_or_sets;
extern (C) _AtkStateSet * function(_AtkStateSet *, _AtkStateSet *)atk_state_set_and_sets;
extern (C) gint function(_AtkStateSet *, gint)atk_state_set_remove_state;
extern (C) gint function(_AtkStateSet *, gint *, gint)atk_state_set_contains_states;
extern (C) gint function(_AtkStateSet *, gint)atk_state_set_contains_state;
extern (C) void function(_AtkStateSet *)atk_state_set_clear_states;
extern (C) void function(_AtkStateSet *, gint *, gint)atk_state_set_add_states;
extern (C) gint function(_AtkStateSet *, gint)atk_state_set_add_state;
extern (C) gint function(_AtkStateSet *)atk_state_set_is_empty;
extern (C) _AtkStateSet * function()atk_state_set_new;
extern (C) GType function()atk_state_set_get_type;
extern (C) gint function(void *)atk_selection_select_all_selection;
extern (C) gint function(void *, gint)atk_selection_remove_selection;
extern (C) gint function(void *, gint)atk_selection_is_child_selected;
extern (C) gint function(void *)atk_selection_get_selection_count;
extern (C) _AtkObject * function(void *, gint)atk_selection_ref_selection;
extern (C) gint function(void *)atk_selection_clear_selection;
extern (C) gint function(void *, gint)atk_selection_add_selection;
extern (C) GType function()atk_selection_get_type;
extern (C) void function(_AtkRelationSet *, gint, _AtkObject *)atk_relation_set_add_relation_by_type;
extern (C) _AtkRelation * function(_AtkRelationSet *, gint)atk_relation_set_get_relation_by_type;
extern (C) _AtkRelation * function(_AtkRelationSet *, gint)atk_relation_set_get_relation;
extern (C) gint function(_AtkRelationSet *)atk_relation_set_get_n_relations;
extern (C) void function(_AtkRelationSet *, _AtkRelation *)atk_relation_set_add;
extern (C) void function(_AtkRelationSet *, _AtkRelation *)atk_relation_set_remove;
extern (C) gint function(_AtkRelationSet *, gint)atk_relation_set_contains;
extern (C) _AtkRelationSet * function()atk_relation_set_new;
extern (C) GType function()atk_relation_set_get_type;
extern (C) void function(_AtkRelation *, _AtkObject *)atk_relation_add_target;
extern (C) _GPtrArray * function(_AtkRelation *)atk_relation_get_target;
extern (C) gint function(_AtkRelation *)atk_relation_get_relation_type;
extern (C) _AtkRelation * function(_AtkObject * *, gint, gint)atk_relation_new;
extern (C) gint function(char *)atk_relation_type_for_name;
extern (C) char * function(gint)atk_relation_type_get_name;
extern (C) gint function(char *)atk_relation_type_register;
extern (C) GType function()atk_relation_get_type;
extern (C) _AtkRegistry * function()atk_get_default_registry;
extern (C) _AtkObjectFactory * function(_AtkRegistry *, GType)atk_registry_get_factory;
extern (C) GType function(_AtkRegistry *, GType)atk_registry_get_factory_type;
extern (C) void function(_AtkRegistry *, GType, GType)atk_registry_set_factory_type;
extern (C) GType function()atk_registry_get_type;
extern (C) _AtkObjectFactory * function()atk_no_op_object_factory_new;
extern (C) GType function()atk_no_op_object_factory_get_type;
extern (C) GType function(_AtkObjectFactory *)atk_object_factory_get_accessible_type;
extern (C) void function(_AtkObjectFactory *)atk_object_factory_invalidate;
extern (C) _AtkObject * function(_AtkObjectFactory *, _GObject *)atk_object_factory_create_accessible;
extern (C) GType function()atk_object_factory_get_type;
extern (C) _AtkObject * function(_GObject *)atk_no_op_object_new;
extern (C) GType function()atk_no_op_object_get_type;
extern (C) char * function(void *)atk_image_get_image_locale;
extern (C) void function(void *, gint *, gint *, gint)atk_image_get_image_position;
extern (C) gint function(void *, char *)atk_image_set_image_description;
extern (C) void function(void *, gint *, gint *)atk_image_get_image_size;
extern (C) char * function(void *)atk_image_get_image_description;
extern (C) GType function()atk_image_get_type;
extern (C) gint function(void *, gint)atk_hypertext_get_link_index;
extern (C) gint function(void *)atk_hypertext_get_n_links;
extern (C) _AtkHyperlink * function(void *, gint)atk_hypertext_get_link;
extern (C) GType function()atk_hypertext_get_type;
extern (C) _AtkHyperlink * function(void *)atk_hyperlink_impl_get_hyperlink;
extern (C) GType function()atk_hyperlink_impl_get_type;
extern (C) gint function(_AtkHyperlink *)atk_hyperlink_is_selected_link;
extern (C) gint function(_AtkHyperlink *)atk_hyperlink_get_n_anchors;
extern (C) gint function(_AtkHyperlink *)atk_hyperlink_is_inline;
extern (C) gint function(_AtkHyperlink *)atk_hyperlink_is_valid;
extern (C) gint function(_AtkHyperlink *)atk_hyperlink_get_start_index;
extern (C) gint function(_AtkHyperlink *)atk_hyperlink_get_end_index;
extern (C) _AtkObject * function(_AtkHyperlink *, gint)atk_hyperlink_get_object;
extern (C) char * function(_AtkHyperlink *, gint)atk_hyperlink_get_uri;
extern (C) GType function()atk_hyperlink_get_type;
extern (C) _GObject * function(_AtkGObjectAccessible *)atk_gobject_accessible_get_object;
extern (C) _AtkObject * function(_GObject *)atk_gobject_accessible_for_object;
extern (C) GType function()atk_gobject_accessible_get_type;
extern (C) void function(void *, gint)atk_editable_text_paste_text;
extern (C) void function(void *, gint, gint)atk_editable_text_delete_text;
extern (C) void function(void *, gint, gint)atk_editable_text_cut_text;
extern (C) void function(void *, gint, gint)atk_editable_text_copy_text;
extern (C) void function(void *, char *, gint, gint *)atk_editable_text_insert_text;
extern (C) void function(void *, char *)atk_editable_text_set_text_contents;
extern (C) gint function(void *, _GSList *, gint, gint)atk_editable_text_set_run_attributes;
extern (C) GType function()atk_editable_text_get_type;
extern (C) char * function(gint, gint)atk_text_attribute_get_value;
extern (C) gint function(char *)atk_text_attribute_for_name;
extern (C) char * function(gint)atk_text_attribute_get_name;
extern (C) void function(_GSList *)atk_attribute_set_free;
extern (C) void function(_AtkTextRange * *)atk_text_free_ranges;
extern (C) _AtkTextRange * * function(void *, _AtkTextRectangle *, gint, gint, gint)atk_text_get_bounded_ranges;
extern (C) void function(void *, gint, gint, gint, _AtkTextRectangle *)atk_text_get_range_extents;
extern (C) gint function(void *, gint)atk_text_set_caret_offset;
extern (C) gint function(void *, gint, gint, gint)atk_text_set_selection;
extern (C) gint function(void *, gint)atk_text_remove_selection;
extern (C) gint function(void *, gint, gint)atk_text_add_selection;
extern (C) char * function(void *, gint, gint *, gint *)atk_text_get_selection;
extern (C) gint function(void *)atk_text_get_n_selections;
extern (C) gint function(void *, gint, gint, gint)atk_text_get_offset_at_point;
extern (C) gint function(void *)atk_text_get_character_count;
extern (C) _GSList * function(void *)atk_text_get_default_attributes;
extern (C) _GSList * function(void *, gint, gint *, gint *)atk_text_get_run_attributes;
extern (C) void function(void *, gint, gint *, gint *, gint *, gint *, gint)atk_text_get_character_extents;
extern (C) gint function(void *)atk_text_get_caret_offset;
extern (C) char * function(void *, gint, gint, gint *, gint *)atk_text_get_text_before_offset;
extern (C) char * function(void *, gint, gint, gint *, gint *)atk_text_get_text_at_offset;
extern (C) char * function(void *, gint, gint, gint *, gint *)atk_text_get_text_after_offset;
extern (C) gunichar function(void *, gint)atk_text_get_character_at_offset;
extern (C) char * function(void *, gint, gint)atk_text_get_text;
extern (C) GType function()atk_text_get_type;
extern (C) gint function(char *)atk_text_attribute_register;
extern (C) gint function(void *, char *, char *)atk_document_set_attribute_value;
extern (C) char * function(void *, char *)atk_document_get_attribute_value;
extern (C) _GSList * function(void *)atk_document_get_attributes;
extern (C) char * function(void *)atk_document_get_locale;
extern (C) void * function(void *)atk_document_get_document;
extern (C) char * function(void *)atk_document_get_document_type;
extern (C) GType function()atk_document_get_type;
extern (C) double function(void *)atk_component_get_alpha;
extern (C) gint function(void *, gint, gint)atk_component_set_size;
extern (C) gint function(void *, gint, gint, gint)atk_component_set_position;
extern (C) gint function(void *, gint, gint, gint, gint, gint)atk_component_set_extents;
extern (C) void function(void *, guint)atk_component_remove_focus_handler;
extern (C) gint function(void *)atk_component_grab_focus;
extern (C) gint function(void *)atk_component_get_mdi_zorder;
extern (C) gint function(void *)atk_component_get_layer;
extern (C) void function(void *, gint *, gint *)atk_component_get_size;
extern (C) void function(void *, gint *, gint *, gint)atk_component_get_position;
extern (C) void function(void *, gint *, gint *, gint *, gint *, gint)atk_component_get_extents;
extern (C) _AtkObject * function(void *, gint, gint, gint)atk_component_ref_accessible_at_point;
extern (C) gint function(void *, gint, gint, gint)atk_component_contains;
extern (C) guint function(void *, _BCD_func__2758)atk_component_add_focus_handler;
extern (C) GType function()atk_component_get_type;
extern (C) GType function()atk_rectangle_get_type;
extern (C) char * function()atk_get_version;
extern (C) char * function()atk_get_toolkit_version;
extern (C) char * function()atk_get_toolkit_name;
extern (C) _AtkObject * function()atk_get_focus_object;
extern (C) _AtkObject * function()atk_get_root;
extern (C) void function(guint)atk_remove_key_event_listener;
extern (C) guint function(_BCD_func__2777, void *)atk_add_key_event_listener;
extern (C) void function(guint)atk_remove_global_event_listener;
extern (C) guint function(_BCD_func__3077, char *)atk_add_global_event_listener;
extern (C) void function(_AtkObject *)atk_focus_tracker_notify;
extern (C) void function(_BCD_func__2778)atk_focus_tracker_init;
extern (C) void function(guint)atk_remove_focus_tracker;
extern (C) guint function(_BCD_func__2779)atk_add_focus_tracker;
extern (C) GType function()atk_util_get_type;
extern (C) char * function(void *, gint)atk_action_get_localized_name;
extern (C) gint function(void *, gint, char *)atk_action_set_description;
extern (C) char * function(void *, gint)atk_action_get_keybinding;
extern (C) char * function(void *, gint)atk_action_get_name;
extern (C) char * function(void *, gint)atk_action_get_description;
extern (C) gint function(void *)atk_action_get_n_actions;
extern (C) gint function(void *, gint)atk_action_do_action;
extern (C) GType function()atk_action_get_type;
extern (C) char * function(gint)atk_role_get_localized_name;
extern (C) gint function(_AtkObject *, gint, _AtkObject *)atk_object_remove_relationship;
extern (C) gint function(_AtkObject *, gint, _AtkObject *)atk_object_add_relationship;
extern (C) gint function(char *)atk_role_for_name;
extern (C) char * function(gint)atk_role_get_name;
extern (C) void function(_AtkObject *, void *)atk_object_initialize;
extern (C) void function(_AtkObject *, ulong, gint)atk_object_notify_state_change;
extern (C) void function(_AtkObject *, guint)atk_object_remove_property_change_handler;
extern (C) guint function(_AtkObject *, _BCD_func__2816 *)atk_object_connect_property_change_handler;
extern (C) void function(_AtkObject *, gint)atk_object_set_role;
extern (C) void function(_AtkObject *, _AtkObject *)atk_object_set_parent;
extern (C) void function(_AtkObject *, char *)atk_object_set_description;
extern (C) void function(_AtkObject *, char *)atk_object_set_name;
extern (C) gint function(_AtkObject *)atk_object_get_index_in_parent;
extern (C) _AtkStateSet * function(_AtkObject *)atk_object_ref_state_set;
extern (C) _GSList * function(_AtkObject *)atk_object_get_attributes;
extern (C) gint function(_AtkObject *)atk_object_get_mdi_zorder;
extern (C) gint function(_AtkObject *)atk_object_get_layer;
extern (C) gint function(_AtkObject *)atk_object_get_role;
extern (C) _AtkRelationSet * function(_AtkObject *)atk_object_ref_relation_set;
extern (C) _AtkObject * function(_AtkObject *, gint)atk_object_ref_accessible_child;
extern (C) gint function(_AtkObject *)atk_object_get_n_accessible_children;
extern (C) _AtkObject * function(_AtkObject *)atk_object_get_parent;
extern (C) char * function(_AtkObject *)atk_object_get_description;
extern (C) char * function(_AtkObject *)atk_object_get_name;
extern (C) _AtkObject * function(void *)atk_implementor_ref_accessible;
extern (C) GType function()atk_implementor_get_type;
extern (C) GType function()atk_object_get_type;
extern (C) gint function(char *)atk_role_register;
extern (C) gint function(char *)atk_state_type_for_name;
extern (C) char * function(gint)atk_state_type_get_name;
extern (C) gint function(char *)atk_state_type_register;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("atk_value_get_minimum_increment",  cast(void**)& atk_value_get_minimum_increment),
        Symbol("atk_value_set_current_value",  cast(void**)& atk_value_set_current_value),
        Symbol("atk_value_get_minimum_value",  cast(void**)& atk_value_get_minimum_value),
        Symbol("atk_value_get_maximum_value",  cast(void**)& atk_value_get_maximum_value),
        Symbol("atk_value_get_current_value",  cast(void**)& atk_value_get_current_value),
        Symbol("atk_value_get_type",  cast(void**)& atk_value_get_type),
        Symbol("atk_misc_get_instance",  cast(void**)& atk_misc_get_instance),
        Symbol("atk_misc_threads_leave",  cast(void**)& atk_misc_threads_leave),
        Symbol("atk_misc_threads_enter",  cast(void**)& atk_misc_threads_enter),
        Symbol("atk_misc_get_type",  cast(void**)& atk_misc_get_type),
        Symbol("atk_misc_instance",  cast(void**)& atk_misc_instance),
        Symbol("atk_table_remove_column_selection",  cast(void**)& atk_table_remove_column_selection),
        Symbol("atk_table_add_column_selection",  cast(void**)& atk_table_add_column_selection),
        Symbol("atk_table_remove_row_selection",  cast(void**)& atk_table_remove_row_selection),
        Symbol("atk_table_add_row_selection",  cast(void**)& atk_table_add_row_selection),
        Symbol("atk_table_is_selected",  cast(void**)& atk_table_is_selected),
        Symbol("atk_table_is_row_selected",  cast(void**)& atk_table_is_row_selected),
        Symbol("atk_table_is_column_selected",  cast(void**)& atk_table_is_column_selected),
        Symbol("atk_table_get_selected_rows",  cast(void**)& atk_table_get_selected_rows),
        Symbol("atk_table_get_selected_columns",  cast(void**)& atk_table_get_selected_columns),
        Symbol("atk_table_set_summary",  cast(void**)& atk_table_set_summary),
        Symbol("atk_table_set_row_header",  cast(void**)& atk_table_set_row_header),
        Symbol("atk_table_set_row_description",  cast(void**)& atk_table_set_row_description),
        Symbol("atk_table_set_column_header",  cast(void**)& atk_table_set_column_header),
        Symbol("atk_table_set_column_description",  cast(void**)& atk_table_set_column_description),
        Symbol("atk_table_set_caption",  cast(void**)& atk_table_set_caption),
        Symbol("atk_table_get_summary",  cast(void**)& atk_table_get_summary),
        Symbol("atk_table_get_row_header",  cast(void**)& atk_table_get_row_header),
        Symbol("atk_table_get_row_description",  cast(void**)& atk_table_get_row_description),
        Symbol("atk_table_get_column_header",  cast(void**)& atk_table_get_column_header),
        Symbol("atk_table_get_column_description",  cast(void**)& atk_table_get_column_description),
        Symbol("atk_table_get_caption",  cast(void**)& atk_table_get_caption),
        Symbol("atk_table_get_row_extent_at",  cast(void**)& atk_table_get_row_extent_at),
        Symbol("atk_table_get_column_extent_at",  cast(void**)& atk_table_get_column_extent_at),
        Symbol("atk_table_get_n_rows",  cast(void**)& atk_table_get_n_rows),
        Symbol("atk_table_get_n_columns",  cast(void**)& atk_table_get_n_columns),
        Symbol("atk_table_get_row_at_index",  cast(void**)& atk_table_get_row_at_index),
        Symbol("atk_table_get_column_at_index",  cast(void**)& atk_table_get_column_at_index),
        Symbol("atk_table_get_index_at",  cast(void**)& atk_table_get_index_at),
        Symbol("atk_table_ref_at",  cast(void**)& atk_table_ref_at),
        Symbol("atk_table_get_type",  cast(void**)& atk_table_get_type),
        Symbol("atk_streamable_content_get_uri",  cast(void**)& atk_streamable_content_get_uri),
        Symbol("atk_streamable_content_get_stream",  cast(void**)& atk_streamable_content_get_stream),
        Symbol("atk_streamable_content_get_mime_type",  cast(void**)& atk_streamable_content_get_mime_type),
        Symbol("atk_streamable_content_get_n_mime_types",  cast(void**)& atk_streamable_content_get_n_mime_types),
        Symbol("atk_streamable_content_get_type",  cast(void**)& atk_streamable_content_get_type),
        Symbol("atk_state_set_xor_sets",  cast(void**)& atk_state_set_xor_sets),
        Symbol("atk_state_set_or_sets",  cast(void**)& atk_state_set_or_sets),
        Symbol("atk_state_set_and_sets",  cast(void**)& atk_state_set_and_sets),
        Symbol("atk_state_set_remove_state",  cast(void**)& atk_state_set_remove_state),
        Symbol("atk_state_set_contains_states",  cast(void**)& atk_state_set_contains_states),
        Symbol("atk_state_set_contains_state",  cast(void**)& atk_state_set_contains_state),
        Symbol("atk_state_set_clear_states",  cast(void**)& atk_state_set_clear_states),
        Symbol("atk_state_set_add_states",  cast(void**)& atk_state_set_add_states),
        Symbol("atk_state_set_add_state",  cast(void**)& atk_state_set_add_state),
        Symbol("atk_state_set_is_empty",  cast(void**)& atk_state_set_is_empty),
        Symbol("atk_state_set_new",  cast(void**)& atk_state_set_new),
        Symbol("atk_state_set_get_type",  cast(void**)& atk_state_set_get_type),
        Symbol("atk_selection_select_all_selection",  cast(void**)& atk_selection_select_all_selection),
        Symbol("atk_selection_remove_selection",  cast(void**)& atk_selection_remove_selection),
        Symbol("atk_selection_is_child_selected",  cast(void**)& atk_selection_is_child_selected),
        Symbol("atk_selection_get_selection_count",  cast(void**)& atk_selection_get_selection_count),
        Symbol("atk_selection_ref_selection",  cast(void**)& atk_selection_ref_selection),
        Symbol("atk_selection_clear_selection",  cast(void**)& atk_selection_clear_selection),
        Symbol("atk_selection_add_selection",  cast(void**)& atk_selection_add_selection),
        Symbol("atk_selection_get_type",  cast(void**)& atk_selection_get_type),
        Symbol("atk_relation_set_add_relation_by_type",  cast(void**)& atk_relation_set_add_relation_by_type),
        Symbol("atk_relation_set_get_relation_by_type",  cast(void**)& atk_relation_set_get_relation_by_type),
        Symbol("atk_relation_set_get_relation",  cast(void**)& atk_relation_set_get_relation),
        Symbol("atk_relation_set_get_n_relations",  cast(void**)& atk_relation_set_get_n_relations),
        Symbol("atk_relation_set_add",  cast(void**)& atk_relation_set_add),
        Symbol("atk_relation_set_remove",  cast(void**)& atk_relation_set_remove),
        Symbol("atk_relation_set_contains",  cast(void**)& atk_relation_set_contains),
        Symbol("atk_relation_set_new",  cast(void**)& atk_relation_set_new),
        Symbol("atk_relation_set_get_type",  cast(void**)& atk_relation_set_get_type),
        Symbol("atk_relation_add_target",  cast(void**)& atk_relation_add_target),
        Symbol("atk_relation_get_target",  cast(void**)& atk_relation_get_target),
        Symbol("atk_relation_get_relation_type",  cast(void**)& atk_relation_get_relation_type),
        Symbol("atk_relation_new",  cast(void**)& atk_relation_new),
        Symbol("atk_relation_type_for_name",  cast(void**)& atk_relation_type_for_name),
        Symbol("atk_relation_type_get_name",  cast(void**)& atk_relation_type_get_name),
        Symbol("atk_relation_type_register",  cast(void**)& atk_relation_type_register),
        Symbol("atk_relation_get_type",  cast(void**)& atk_relation_get_type),
        Symbol("atk_get_default_registry",  cast(void**)& atk_get_default_registry),
        Symbol("atk_registry_get_factory",  cast(void**)& atk_registry_get_factory),
        Symbol("atk_registry_get_factory_type",  cast(void**)& atk_registry_get_factory_type),
        Symbol("atk_registry_set_factory_type",  cast(void**)& atk_registry_set_factory_type),
        Symbol("atk_registry_get_type",  cast(void**)& atk_registry_get_type),
        Symbol("atk_no_op_object_factory_new",  cast(void**)& atk_no_op_object_factory_new),
        Symbol("atk_no_op_object_factory_get_type",  cast(void**)& atk_no_op_object_factory_get_type),
        Symbol("atk_object_factory_get_accessible_type",  cast(void**)& atk_object_factory_get_accessible_type),
        Symbol("atk_object_factory_invalidate",  cast(void**)& atk_object_factory_invalidate),
        Symbol("atk_object_factory_create_accessible",  cast(void**)& atk_object_factory_create_accessible),
        Symbol("atk_object_factory_get_type",  cast(void**)& atk_object_factory_get_type),
        Symbol("atk_no_op_object_new",  cast(void**)& atk_no_op_object_new),
        Symbol("atk_no_op_object_get_type",  cast(void**)& atk_no_op_object_get_type),
        Symbol("atk_image_get_image_locale",  cast(void**)& atk_image_get_image_locale),
        Symbol("atk_image_get_image_position",  cast(void**)& atk_image_get_image_position),
        Symbol("atk_image_set_image_description",  cast(void**)& atk_image_set_image_description),
        Symbol("atk_image_get_image_size",  cast(void**)& atk_image_get_image_size),
        Symbol("atk_image_get_image_description",  cast(void**)& atk_image_get_image_description),
        Symbol("atk_image_get_type",  cast(void**)& atk_image_get_type),
        Symbol("atk_hypertext_get_link_index",  cast(void**)& atk_hypertext_get_link_index),
        Symbol("atk_hypertext_get_n_links",  cast(void**)& atk_hypertext_get_n_links),
        Symbol("atk_hypertext_get_link",  cast(void**)& atk_hypertext_get_link),
        Symbol("atk_hypertext_get_type",  cast(void**)& atk_hypertext_get_type),
        Symbol("atk_hyperlink_impl_get_hyperlink",  cast(void**)& atk_hyperlink_impl_get_hyperlink),
        Symbol("atk_hyperlink_impl_get_type",  cast(void**)& atk_hyperlink_impl_get_type),
        Symbol("atk_hyperlink_is_selected_link",  cast(void**)& atk_hyperlink_is_selected_link),
        Symbol("atk_hyperlink_get_n_anchors",  cast(void**)& atk_hyperlink_get_n_anchors),
        Symbol("atk_hyperlink_is_inline",  cast(void**)& atk_hyperlink_is_inline),
        Symbol("atk_hyperlink_is_valid",  cast(void**)& atk_hyperlink_is_valid),
        Symbol("atk_hyperlink_get_start_index",  cast(void**)& atk_hyperlink_get_start_index),
        Symbol("atk_hyperlink_get_end_index",  cast(void**)& atk_hyperlink_get_end_index),
        Symbol("atk_hyperlink_get_object",  cast(void**)& atk_hyperlink_get_object),
        Symbol("atk_hyperlink_get_uri",  cast(void**)& atk_hyperlink_get_uri),
        Symbol("atk_hyperlink_get_type",  cast(void**)& atk_hyperlink_get_type),
        Symbol("atk_gobject_accessible_get_object",  cast(void**)& atk_gobject_accessible_get_object),
        Symbol("atk_gobject_accessible_for_object",  cast(void**)& atk_gobject_accessible_for_object),
        Symbol("atk_gobject_accessible_get_type",  cast(void**)& atk_gobject_accessible_get_type),
        Symbol("atk_editable_text_paste_text",  cast(void**)& atk_editable_text_paste_text),
        Symbol("atk_editable_text_delete_text",  cast(void**)& atk_editable_text_delete_text),
        Symbol("atk_editable_text_cut_text",  cast(void**)& atk_editable_text_cut_text),
        Symbol("atk_editable_text_copy_text",  cast(void**)& atk_editable_text_copy_text),
        Symbol("atk_editable_text_insert_text",  cast(void**)& atk_editable_text_insert_text),
        Symbol("atk_editable_text_set_text_contents",  cast(void**)& atk_editable_text_set_text_contents),
        Symbol("atk_editable_text_set_run_attributes",  cast(void**)& atk_editable_text_set_run_attributes),
        Symbol("atk_editable_text_get_type",  cast(void**)& atk_editable_text_get_type),
        Symbol("atk_text_attribute_get_value",  cast(void**)& atk_text_attribute_get_value),
        Symbol("atk_text_attribute_for_name",  cast(void**)& atk_text_attribute_for_name),
        Symbol("atk_text_attribute_get_name",  cast(void**)& atk_text_attribute_get_name),
        Symbol("atk_attribute_set_free",  cast(void**)& atk_attribute_set_free),
        Symbol("atk_text_free_ranges",  cast(void**)& atk_text_free_ranges),
        Symbol("atk_text_get_bounded_ranges",  cast(void**)& atk_text_get_bounded_ranges),
        Symbol("atk_text_get_range_extents",  cast(void**)& atk_text_get_range_extents),
        Symbol("atk_text_set_caret_offset",  cast(void**)& atk_text_set_caret_offset),
        Symbol("atk_text_set_selection",  cast(void**)& atk_text_set_selection),
        Symbol("atk_text_remove_selection",  cast(void**)& atk_text_remove_selection),
        Symbol("atk_text_add_selection",  cast(void**)& atk_text_add_selection),
        Symbol("atk_text_get_selection",  cast(void**)& atk_text_get_selection),
        Symbol("atk_text_get_n_selections",  cast(void**)& atk_text_get_n_selections),
        Symbol("atk_text_get_offset_at_point",  cast(void**)& atk_text_get_offset_at_point),
        Symbol("atk_text_get_character_count",  cast(void**)& atk_text_get_character_count),
        Symbol("atk_text_get_default_attributes",  cast(void**)& atk_text_get_default_attributes),
        Symbol("atk_text_get_run_attributes",  cast(void**)& atk_text_get_run_attributes),
        Symbol("atk_text_get_character_extents",  cast(void**)& atk_text_get_character_extents),
        Symbol("atk_text_get_caret_offset",  cast(void**)& atk_text_get_caret_offset),
        Symbol("atk_text_get_text_before_offset",  cast(void**)& atk_text_get_text_before_offset),
        Symbol("atk_text_get_text_at_offset",  cast(void**)& atk_text_get_text_at_offset),
        Symbol("atk_text_get_text_after_offset",  cast(void**)& atk_text_get_text_after_offset),
        Symbol("atk_text_get_character_at_offset",  cast(void**)& atk_text_get_character_at_offset),
        Symbol("atk_text_get_text",  cast(void**)& atk_text_get_text),
        Symbol("atk_text_get_type",  cast(void**)& atk_text_get_type),
        Symbol("atk_text_attribute_register",  cast(void**)& atk_text_attribute_register),
        Symbol("atk_document_set_attribute_value",  cast(void**)& atk_document_set_attribute_value),
        Symbol("atk_document_get_attribute_value",  cast(void**)& atk_document_get_attribute_value),
        Symbol("atk_document_get_attributes",  cast(void**)& atk_document_get_attributes),
        Symbol("atk_document_get_locale",  cast(void**)& atk_document_get_locale),
        Symbol("atk_document_get_document",  cast(void**)& atk_document_get_document),
        Symbol("atk_document_get_document_type",  cast(void**)& atk_document_get_document_type),
        Symbol("atk_document_get_type",  cast(void**)& atk_document_get_type),
        Symbol("atk_component_get_alpha",  cast(void**)& atk_component_get_alpha),
        Symbol("atk_component_set_size",  cast(void**)& atk_component_set_size),
        Symbol("atk_component_set_position",  cast(void**)& atk_component_set_position),
        Symbol("atk_component_set_extents",  cast(void**)& atk_component_set_extents),
        Symbol("atk_component_remove_focus_handler",  cast(void**)& atk_component_remove_focus_handler),
        Symbol("atk_component_grab_focus",  cast(void**)& atk_component_grab_focus),
        Symbol("atk_component_get_mdi_zorder",  cast(void**)& atk_component_get_mdi_zorder),
        Symbol("atk_component_get_layer",  cast(void**)& atk_component_get_layer),
        Symbol("atk_component_get_size",  cast(void**)& atk_component_get_size),
        Symbol("atk_component_get_position",  cast(void**)& atk_component_get_position),
        Symbol("atk_component_get_extents",  cast(void**)& atk_component_get_extents),
        Symbol("atk_component_ref_accessible_at_point",  cast(void**)& atk_component_ref_accessible_at_point),
        Symbol("atk_component_contains",  cast(void**)& atk_component_contains),
        Symbol("atk_component_add_focus_handler",  cast(void**)& atk_component_add_focus_handler),
        Symbol("atk_component_get_type",  cast(void**)& atk_component_get_type),
        Symbol("atk_rectangle_get_type",  cast(void**)& atk_rectangle_get_type),
        Symbol("atk_get_version",  cast(void**)& atk_get_version),
        Symbol("atk_get_toolkit_version",  cast(void**)& atk_get_toolkit_version),
        Symbol("atk_get_toolkit_name",  cast(void**)& atk_get_toolkit_name),
        Symbol("atk_get_focus_object",  cast(void**)& atk_get_focus_object),
        Symbol("atk_get_root",  cast(void**)& atk_get_root),
        Symbol("atk_remove_key_event_listener",  cast(void**)& atk_remove_key_event_listener),
        Symbol("atk_add_key_event_listener",  cast(void**)& atk_add_key_event_listener),
        Symbol("atk_remove_global_event_listener",  cast(void**)& atk_remove_global_event_listener),
        Symbol("atk_add_global_event_listener",  cast(void**)& atk_add_global_event_listener),
        Symbol("atk_focus_tracker_notify",  cast(void**)& atk_focus_tracker_notify),
        Symbol("atk_focus_tracker_init",  cast(void**)& atk_focus_tracker_init),
        Symbol("atk_remove_focus_tracker",  cast(void**)& atk_remove_focus_tracker),
        Symbol("atk_add_focus_tracker",  cast(void**)& atk_add_focus_tracker),
        Symbol("atk_util_get_type",  cast(void**)& atk_util_get_type),
        Symbol("atk_action_get_localized_name",  cast(void**)& atk_action_get_localized_name),
        Symbol("atk_action_set_description",  cast(void**)& atk_action_set_description),
        Symbol("atk_action_get_keybinding",  cast(void**)& atk_action_get_keybinding),
        Symbol("atk_action_get_name",  cast(void**)& atk_action_get_name),
        Symbol("atk_action_get_description",  cast(void**)& atk_action_get_description),
        Symbol("atk_action_get_n_actions",  cast(void**)& atk_action_get_n_actions),
        Symbol("atk_action_do_action",  cast(void**)& atk_action_do_action),
        Symbol("atk_action_get_type",  cast(void**)& atk_action_get_type),
        Symbol("atk_role_get_localized_name",  cast(void**)& atk_role_get_localized_name),
        Symbol("atk_object_remove_relationship",  cast(void**)& atk_object_remove_relationship),
        Symbol("atk_object_add_relationship",  cast(void**)& atk_object_add_relationship),
        Symbol("atk_role_for_name",  cast(void**)& atk_role_for_name),
        Symbol("atk_role_get_name",  cast(void**)& atk_role_get_name),
        Symbol("atk_object_initialize",  cast(void**)& atk_object_initialize),
        Symbol("atk_object_notify_state_change",  cast(void**)& atk_object_notify_state_change),
        Symbol("atk_object_remove_property_change_handler",  cast(void**)& atk_object_remove_property_change_handler),
        Symbol("atk_object_connect_property_change_handler",  cast(void**)& atk_object_connect_property_change_handler),
        Symbol("atk_object_set_role",  cast(void**)& atk_object_set_role),
        Symbol("atk_object_set_parent",  cast(void**)& atk_object_set_parent),
        Symbol("atk_object_set_description",  cast(void**)& atk_object_set_description),
        Symbol("atk_object_set_name",  cast(void**)& atk_object_set_name),
        Symbol("atk_object_get_index_in_parent",  cast(void**)& atk_object_get_index_in_parent),
        Symbol("atk_object_ref_state_set",  cast(void**)& atk_object_ref_state_set),
        Symbol("atk_object_get_attributes",  cast(void**)& atk_object_get_attributes),
        Symbol("atk_object_get_mdi_zorder",  cast(void**)& atk_object_get_mdi_zorder),
        Symbol("atk_object_get_layer",  cast(void**)& atk_object_get_layer),
        Symbol("atk_object_get_role",  cast(void**)& atk_object_get_role),
        Symbol("atk_object_ref_relation_set",  cast(void**)& atk_object_ref_relation_set),
        Symbol("atk_object_ref_accessible_child",  cast(void**)& atk_object_ref_accessible_child),
        Symbol("atk_object_get_n_accessible_children",  cast(void**)& atk_object_get_n_accessible_children),
        Symbol("atk_object_get_parent",  cast(void**)& atk_object_get_parent),
        Symbol("atk_object_get_description",  cast(void**)& atk_object_get_description),
        Symbol("atk_object_get_name",  cast(void**)& atk_object_get_name),
        Symbol("atk_implementor_ref_accessible",  cast(void**)& atk_implementor_ref_accessible),
        Symbol("atk_implementor_get_type",  cast(void**)& atk_implementor_get_type),
        Symbol("atk_object_get_type",  cast(void**)& atk_object_get_type),
        Symbol("atk_role_register",  cast(void**)& atk_role_register),
        Symbol("atk_state_type_for_name",  cast(void**)& atk_state_type_for_name),
        Symbol("atk_state_type_get_name",  cast(void**)& atk_state_type_get_name),
        Symbol("atk_state_type_register",  cast(void**)& atk_state_type_register)
    ];
}

} else { // version(DYNLINK)
extern (C) void atk_value_get_minimum_increment(void *, _GValue *);
extern (C) gint atk_value_set_current_value(void *, _GValue *);
extern (C) void atk_value_get_minimum_value(void *, _GValue *);
extern (C) void atk_value_get_maximum_value(void *, _GValue *);
extern (C) void atk_value_get_current_value(void *, _GValue *);
extern (C) GType atk_value_get_type();
extern (C) _AtkMisc * atk_misc_get_instance();
extern (C) void atk_misc_threads_leave(_AtkMisc *);
extern (C) void atk_misc_threads_enter(_AtkMisc *);
extern (C) GType atk_misc_get_type();
extern (C) extern _AtkMisc * atk_misc_instance;
extern (C) gint atk_table_remove_column_selection(void *, gint);
extern (C) gint atk_table_add_column_selection(void *, gint);
extern (C) gint atk_table_remove_row_selection(void *, gint);
extern (C) gint atk_table_add_row_selection(void *, gint);
extern (C) gint atk_table_is_selected(void *, gint, gint);
extern (C) gint atk_table_is_row_selected(void *, gint);
extern (C) gint atk_table_is_column_selected(void *, gint);
extern (C) gint atk_table_get_selected_rows(void *, gint * *);
extern (C) gint atk_table_get_selected_columns(void *, gint * *);
extern (C) void atk_table_set_summary(void *, _AtkObject *);
extern (C) void atk_table_set_row_header(void *, gint, _AtkObject *);
extern (C) void atk_table_set_row_description(void *, gint, char *);
extern (C) void atk_table_set_column_header(void *, gint, _AtkObject *);
extern (C) void atk_table_set_column_description(void *, gint, char *);
extern (C) void atk_table_set_caption(void *, _AtkObject *);
extern (C) _AtkObject * atk_table_get_summary(void *);
extern (C) _AtkObject * atk_table_get_row_header(void *, gint);
extern (C) char * atk_table_get_row_description(void *, gint);
extern (C) _AtkObject * atk_table_get_column_header(void *, gint);
extern (C) char * atk_table_get_column_description(void *, gint);
extern (C) _AtkObject * atk_table_get_caption(void *);
extern (C) gint atk_table_get_row_extent_at(void *, gint, gint);
extern (C) gint atk_table_get_column_extent_at(void *, gint, gint);
extern (C) gint atk_table_get_n_rows(void *);
extern (C) gint atk_table_get_n_columns(void *);
extern (C) gint atk_table_get_row_at_index(void *, gint);
extern (C) gint atk_table_get_column_at_index(void *, gint);
extern (C) gint atk_table_get_index_at(void *, gint, gint);
extern (C) _AtkObject * atk_table_ref_at(void *, gint, gint);
extern (C) GType atk_table_get_type();
extern (C) char * atk_streamable_content_get_uri(void *, char *);
extern (C) _GIOChannel * atk_streamable_content_get_stream(void *, char *);
extern (C) char * atk_streamable_content_get_mime_type(void *, gint);
extern (C) gint atk_streamable_content_get_n_mime_types(void *);
extern (C) GType atk_streamable_content_get_type();
extern (C) _AtkStateSet * atk_state_set_xor_sets(_AtkStateSet *, _AtkStateSet *);
extern (C) _AtkStateSet * atk_state_set_or_sets(_AtkStateSet *, _AtkStateSet *);
extern (C) _AtkStateSet * atk_state_set_and_sets(_AtkStateSet *, _AtkStateSet *);
extern (C) gint atk_state_set_remove_state(_AtkStateSet *, gint);
extern (C) gint atk_state_set_contains_states(_AtkStateSet *, gint *, gint);
extern (C) gint atk_state_set_contains_state(_AtkStateSet *, gint);
extern (C) void atk_state_set_clear_states(_AtkStateSet *);
extern (C) void atk_state_set_add_states(_AtkStateSet *, gint *, gint);
extern (C) gint atk_state_set_add_state(_AtkStateSet *, gint);
extern (C) gint atk_state_set_is_empty(_AtkStateSet *);
extern (C) _AtkStateSet * atk_state_set_new();
extern (C) GType atk_state_set_get_type();
extern (C) gint atk_selection_select_all_selection(void *);
extern (C) gint atk_selection_remove_selection(void *, gint);
extern (C) gint atk_selection_is_child_selected(void *, gint);
extern (C) gint atk_selection_get_selection_count(void *);
extern (C) _AtkObject * atk_selection_ref_selection(void *, gint);
extern (C) gint atk_selection_clear_selection(void *);
extern (C) gint atk_selection_add_selection(void *, gint);
extern (C) GType atk_selection_get_type();
extern (C) void atk_relation_set_add_relation_by_type(_AtkRelationSet *, gint, _AtkObject *);
extern (C) _AtkRelation * atk_relation_set_get_relation_by_type(_AtkRelationSet *, gint);
extern (C) _AtkRelation * atk_relation_set_get_relation(_AtkRelationSet *, gint);
extern (C) gint atk_relation_set_get_n_relations(_AtkRelationSet *);
extern (C) void atk_relation_set_add(_AtkRelationSet *, _AtkRelation *);
extern (C) void atk_relation_set_remove(_AtkRelationSet *, _AtkRelation *);
extern (C) gint atk_relation_set_contains(_AtkRelationSet *, gint);
extern (C) _AtkRelationSet * atk_relation_set_new();
extern (C) GType atk_relation_set_get_type();
extern (C) void atk_relation_add_target(_AtkRelation *, _AtkObject *);
extern (C) _GPtrArray * atk_relation_get_target(_AtkRelation *);
extern (C) gint atk_relation_get_relation_type(_AtkRelation *);
extern (C) _AtkRelation * atk_relation_new(_AtkObject * *, gint, gint);
extern (C) gint atk_relation_type_for_name(char *);
extern (C) char * atk_relation_type_get_name(gint);
extern (C) gint atk_relation_type_register(char *);
extern (C) GType atk_relation_get_type();
extern (C) _AtkRegistry * atk_get_default_registry();
extern (C) _AtkObjectFactory * atk_registry_get_factory(_AtkRegistry *, GType);
extern (C) GType atk_registry_get_factory_type(_AtkRegistry *, GType);
extern (C) void atk_registry_set_factory_type(_AtkRegistry *, GType, GType);
extern (C) GType atk_registry_get_type();
extern (C) _AtkObjectFactory * atk_no_op_object_factory_new();
extern (C) GType atk_no_op_object_factory_get_type();
extern (C) GType atk_object_factory_get_accessible_type(_AtkObjectFactory *);
extern (C) void atk_object_factory_invalidate(_AtkObjectFactory *);
extern (C) _AtkObject * atk_object_factory_create_accessible(_AtkObjectFactory *, _GObject *);
extern (C) GType atk_object_factory_get_type();
extern (C) _AtkObject * atk_no_op_object_new(_GObject *);
extern (C) GType atk_no_op_object_get_type();
extern (C) char * atk_image_get_image_locale(void *);
extern (C) void atk_image_get_image_position(void *, gint *, gint *, gint);
extern (C) gint atk_image_set_image_description(void *, char *);
extern (C) void atk_image_get_image_size(void *, gint *, gint *);
extern (C) char * atk_image_get_image_description(void *);
extern (C) GType atk_image_get_type();
extern (C) gint atk_hypertext_get_link_index(void *, gint);
extern (C) gint atk_hypertext_get_n_links(void *);
extern (C) _AtkHyperlink * atk_hypertext_get_link(void *, gint);
extern (C) GType atk_hypertext_get_type();
extern (C) _AtkHyperlink * atk_hyperlink_impl_get_hyperlink(void *);
extern (C) GType atk_hyperlink_impl_get_type();
extern (C) gint atk_hyperlink_is_selected_link(_AtkHyperlink *);
extern (C) gint atk_hyperlink_get_n_anchors(_AtkHyperlink *);
extern (C) gint atk_hyperlink_is_inline(_AtkHyperlink *);
extern (C) gint atk_hyperlink_is_valid(_AtkHyperlink *);
extern (C) gint atk_hyperlink_get_start_index(_AtkHyperlink *);
extern (C) gint atk_hyperlink_get_end_index(_AtkHyperlink *);
extern (C) _AtkObject * atk_hyperlink_get_object(_AtkHyperlink *, gint);
extern (C) char * atk_hyperlink_get_uri(_AtkHyperlink *, gint);
extern (C) GType atk_hyperlink_get_type();
extern (C) _GObject * atk_gobject_accessible_get_object(_AtkGObjectAccessible *);
extern (C) _AtkObject * atk_gobject_accessible_for_object(_GObject *);
extern (C) GType atk_gobject_accessible_get_type();
extern (C) void atk_editable_text_paste_text(void *, gint);
extern (C) void atk_editable_text_delete_text(void *, gint, gint);
extern (C) void atk_editable_text_cut_text(void *, gint, gint);
extern (C) void atk_editable_text_copy_text(void *, gint, gint);
extern (C) void atk_editable_text_insert_text(void *, char *, gint, gint *);
extern (C) void atk_editable_text_set_text_contents(void *, char *);
extern (C) gint atk_editable_text_set_run_attributes(void *, _GSList *, gint, gint);
extern (C) GType atk_editable_text_get_type();
extern (C) char * atk_text_attribute_get_value(gint, gint);
extern (C) gint atk_text_attribute_for_name(char *);
extern (C) char * atk_text_attribute_get_name(gint);
extern (C) void atk_attribute_set_free(_GSList *);
extern (C) void atk_text_free_ranges(_AtkTextRange * *);
extern (C) _AtkTextRange * * atk_text_get_bounded_ranges(void *, _AtkTextRectangle *, gint, gint, gint);
extern (C) void atk_text_get_range_extents(void *, gint, gint, gint, _AtkTextRectangle *);
extern (C) gint atk_text_set_caret_offset(void *, gint);
extern (C) gint atk_text_set_selection(void *, gint, gint, gint);
extern (C) gint atk_text_remove_selection(void *, gint);
extern (C) gint atk_text_add_selection(void *, gint, gint);
extern (C) char * atk_text_get_selection(void *, gint, gint *, gint *);
extern (C) gint atk_text_get_n_selections(void *);
extern (C) gint atk_text_get_offset_at_point(void *, gint, gint, gint);
extern (C) gint atk_text_get_character_count(void *);
extern (C) _GSList * atk_text_get_default_attributes(void *);
extern (C) _GSList * atk_text_get_run_attributes(void *, gint, gint *, gint *);
extern (C) void atk_text_get_character_extents(void *, gint, gint *, gint *, gint *, gint *, gint);
extern (C) gint atk_text_get_caret_offset(void *);
extern (C) char * atk_text_get_text_before_offset(void *, gint, gint, gint *, gint *);
extern (C) char * atk_text_get_text_at_offset(void *, gint, gint, gint *, gint *);
extern (C) char * atk_text_get_text_after_offset(void *, gint, gint, gint *, gint *);
extern (C) gunichar atk_text_get_character_at_offset(void *, gint);
extern (C) char * atk_text_get_text(void *, gint, gint);
extern (C) GType atk_text_get_type();
extern (C) gint atk_text_attribute_register(char *);
extern (C) gint atk_document_set_attribute_value(void *, char *, char *);
extern (C) char * atk_document_get_attribute_value(void *, char *);
extern (C) _GSList * atk_document_get_attributes(void *);
extern (C) char * atk_document_get_locale(void *);
extern (C) void * atk_document_get_document(void *);
extern (C) char * atk_document_get_document_type(void *);
extern (C) GType atk_document_get_type();
extern (C) double atk_component_get_alpha(void *);
extern (C) gint atk_component_set_size(void *, gint, gint);
extern (C) gint atk_component_set_position(void *, gint, gint, gint);
extern (C) gint atk_component_set_extents(void *, gint, gint, gint, gint, gint);
extern (C) void atk_component_remove_focus_handler(void *, guint);
extern (C) gint atk_component_grab_focus(void *);
extern (C) gint atk_component_get_mdi_zorder(void *);
extern (C) gint atk_component_get_layer(void *);
extern (C) void atk_component_get_size(void *, gint *, gint *);
extern (C) void atk_component_get_position(void *, gint *, gint *, gint);
extern (C) void atk_component_get_extents(void *, gint *, gint *, gint *, gint *, gint);
extern (C) _AtkObject * atk_component_ref_accessible_at_point(void *, gint, gint, gint);
extern (C) gint atk_component_contains(void *, gint, gint, gint);
extern (C) guint atk_component_add_focus_handler(void *, _BCD_func__2758);
extern (C) GType atk_component_get_type();
extern (C) GType atk_rectangle_get_type();
extern (C) char * atk_get_version();
extern (C) char * atk_get_toolkit_version();
extern (C) char * atk_get_toolkit_name();
extern (C) _AtkObject * atk_get_focus_object();
extern (C) _AtkObject * atk_get_root();
extern (C) void atk_remove_key_event_listener(guint);
extern (C) guint atk_add_key_event_listener(_BCD_func__2777, void *);
extern (C) void atk_remove_global_event_listener(guint);
extern (C) guint atk_add_global_event_listener(_BCD_func__3077, char *);
extern (C) void atk_focus_tracker_notify(_AtkObject *);
extern (C) void atk_focus_tracker_init(_BCD_func__2778);
extern (C) void atk_remove_focus_tracker(guint);
extern (C) guint atk_add_focus_tracker(_BCD_func__2779);
extern (C) GType atk_util_get_type();
extern (C) char * atk_action_get_localized_name(void *, gint);
extern (C) gint atk_action_set_description(void *, gint, char *);
extern (C) char * atk_action_get_keybinding(void *, gint);
extern (C) char * atk_action_get_name(void *, gint);
extern (C) char * atk_action_get_description(void *, gint);
extern (C) gint atk_action_get_n_actions(void *);
extern (C) gint atk_action_do_action(void *, gint);
extern (C) GType atk_action_get_type();
extern (C) char * atk_role_get_localized_name(gint);
extern (C) gint atk_object_remove_relationship(_AtkObject *, gint, _AtkObject *);
extern (C) gint atk_object_add_relationship(_AtkObject *, gint, _AtkObject *);
extern (C) gint atk_role_for_name(char *);
extern (C) char * atk_role_get_name(gint);
extern (C) void atk_object_initialize(_AtkObject *, void *);
extern (C) void atk_object_notify_state_change(_AtkObject *, ulong, gint);
extern (C) void atk_object_remove_property_change_handler(_AtkObject *, guint);
extern (C) guint atk_object_connect_property_change_handler(_AtkObject *, _BCD_func__2816 *);
extern (C) void atk_object_set_role(_AtkObject *, gint);
extern (C) void atk_object_set_parent(_AtkObject *, _AtkObject *);
extern (C) void atk_object_set_description(_AtkObject *, char *);
extern (C) void atk_object_set_name(_AtkObject *, char *);
extern (C) gint atk_object_get_index_in_parent(_AtkObject *);
extern (C) _AtkStateSet * atk_object_ref_state_set(_AtkObject *);
extern (C) _GSList * atk_object_get_attributes(_AtkObject *);
extern (C) gint atk_object_get_mdi_zorder(_AtkObject *);
extern (C) gint atk_object_get_layer(_AtkObject *);
extern (C) gint atk_object_get_role(_AtkObject *);
extern (C) _AtkRelationSet * atk_object_ref_relation_set(_AtkObject *);
extern (C) _AtkObject * atk_object_ref_accessible_child(_AtkObject *, gint);
extern (C) gint atk_object_get_n_accessible_children(_AtkObject *);
extern (C) _AtkObject * atk_object_get_parent(_AtkObject *);
extern (C) char * atk_object_get_description(_AtkObject *);
extern (C) char * atk_object_get_name(_AtkObject *);
extern (C) _AtkObject * atk_implementor_ref_accessible(void *);
extern (C) GType atk_implementor_get_type();
extern (C) GType atk_object_get_type();
extern (C) gint atk_role_register(char *);
extern (C) gint atk_state_type_for_name(char *);
extern (C) char * atk_state_type_get_name(gint);
extern (C) gint atk_state_type_register(char *);
} // version(DYNLINK)

