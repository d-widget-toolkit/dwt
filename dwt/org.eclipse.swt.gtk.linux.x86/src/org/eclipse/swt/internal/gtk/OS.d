/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others. All rights reserved.
 * The contents of this file are made available under the terms
 * of the GNU Lesser General Public License (LGPL) Version 2.1 that
 * accompanies this distribution (lgpl-v21.txt).  The LGPL is also
 * available at http://www.gnu.org/licenses/lgpl.html.  If the version
 * of the LGPL at http://www.gnu.org is different to the version of
 * the LGPL accompanying this distribution and there is any conflict
 * between the two license versions, the terms of the LGPL accompanying
 * this distribution shall govern.
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *     John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.internal.gtk.OS;

import java.lang.all;

import org.eclipse.swt.internal.Platform;
version(Tango){
    import tango.core.Traits;
    import tango.stdc.locale;
    import tango.stdc.posix.stdlib : realpath;
    static import tango.stdc.string;
} else { // Phobos
    import std.traits;
    import core.sys.posix.stdlib : realpath;
    import core.stdc.locale;
    static import core.stdc.string;
}

import  org.eclipse.swt.internal.c.gtk,
        org.eclipse.swt.internal.c.gdk,
        org.eclipse.swt.internal.c.gdkx,
        org.eclipse.swt.internal.c.atk,
        org.eclipse.swt.internal.c.cairo,
        org.eclipse.swt.internal.c.pango,
        org.eclipse.swt.internal.c.pangocairo,
        org.eclipse.swt.internal.c.gtk_unix_print_2_0,
        org.eclipse.swt.internal.c.Xlib,
        org.eclipse.swt.internal.c.XTest,
        org.eclipse.swt.internal.c.Xrender,
        org.eclipse.swt.internal.c.glib_object;

//version=GTK_DYN_LINK;

public alias org.eclipse.swt.internal.c.glib_object.GPollFD GPollFD;
public alias org.eclipse.swt.internal.c.glib_object.GClosure GClosure;
public alias org.eclipse.swt.internal.c.glib_object.GList GList;
public alias org.eclipse.swt.internal.c.glib_object.gpointer gpointer;
public alias org.eclipse.swt.internal.c.glib_object.GObject GObject;
public alias org.eclipse.swt.internal.c.glib_object.GTypeInfo GTypeInfo;
public alias org.eclipse.swt.internal.c.glib_object.GCallback GCallback;
public alias org.eclipse.swt.internal.c.glib_object.GClosureNotify GClosureNotify;
public alias org.eclipse.swt.internal.c.glib_object.GPollFunc GPollFunc;
public alias org.eclipse.swt.internal.c.glib_object.GTypeInstance GTypeInstance;
public alias org.eclipse.swt.internal.c.glib_object.GObjectClass GObjectClass;
public alias org.eclipse.swt.internal.c.glib_object.GTypeClass GTypeClass;
public alias org.eclipse.swt.internal.c.glib_object.GInterfaceInfo GInterfaceInfo;
public alias org.eclipse.swt.internal.c.glib_object.GTypeQuery GTypeQuery;
public alias org.eclipse.swt.internal.c.glib_object.GError GError;
public alias org.eclipse.swt.internal.c.glib_object.GSignalEmissionHook GSignalEmissionHook;
public alias org.eclipse.swt.internal.c.glib_object.GSignalInvocationHint GSignalInvocationHint;
public alias org.eclipse.swt.internal.c.glib_object.GValue GValue;

public alias org.eclipse.swt.internal.c.gdk.GdkBitmap GdkBitmap;
public alias org.eclipse.swt.internal.c.gdk.GdkColor GdkColor;
public alias org.eclipse.swt.internal.c.gdk.GdkCursor GdkCursor;
public alias org.eclipse.swt.internal.c.gdk.GdkDisplay GdkDisplay;
public alias org.eclipse.swt.internal.c.gdk.GdkDragContext GdkDragContext;
public alias org.eclipse.swt.internal.c.gdk.GdkDrawable GdkDrawable;
public alias org.eclipse.swt.internal.c.gdk.GdkEvent GdkEvent;
public alias org.eclipse.swt.internal.c.gdk.GdkEventAny GdkEventAny;
public alias org.eclipse.swt.internal.c.gdk.GdkEventButton GdkEventButton;
public alias org.eclipse.swt.internal.c.gdk.GdkEventCrossing GdkEventCrossing;
public alias org.eclipse.swt.internal.c.gdk.GdkEventExpose GdkEventExpose;
public alias org.eclipse.swt.internal.c.gdk.GdkEventFocus GdkEventFocus;
public alias org.eclipse.swt.internal.c.gdk.GdkEventKey GdkEventKey;
public alias org.eclipse.swt.internal.c.gdk.GdkEventMotion GdkEventMotion;
public alias org.eclipse.swt.internal.c.gdk.GdkEventScroll GdkEventScroll;
public alias org.eclipse.swt.internal.c.gdk.GdkEventVisibility GdkEventVisibility;
public alias org.eclipse.swt.internal.c.gdk.GdkEventWindowState GdkEventWindowState;
public alias org.eclipse.swt.internal.c.gdk.GdkGC GdkGC;
public alias org.eclipse.swt.internal.c.gdk.GdkGCValues GdkGCValues;
public alias org.eclipse.swt.internal.c.gdk.GdkGeometry GdkGeometry;
public alias org.eclipse.swt.internal.c.gdk.GdkImage GdkImage;
public alias org.eclipse.swt.internal.c.gdk.GdkPixbuf GdkPixbuf;
public alias org.eclipse.swt.internal.c.gdk.GdkPixmap GdkPixmap;
public alias org.eclipse.swt.internal.c.gdk.GdkPoint GdkPoint;
public alias org.eclipse.swt.internal.c.gdk.GdkRectangle GdkRectangle;
public alias org.eclipse.swt.internal.c.gdk.GdkRegion GdkRegion;
public alias org.eclipse.swt.internal.c.gdk.GdkWindow GdkWindow;
public alias org.eclipse.swt.internal.c.gdk.GdkWindowAttr GdkWindowAttr;
public alias org.eclipse.swt.internal.c.gdk.GdkXEvent GdkXEvent;

public alias org.eclipse.swt.internal.c.pango.PangoAttrColor PangoAttrColor;
public alias org.eclipse.swt.internal.c.pango.PangoAttribute PangoAttribute;
public alias org.eclipse.swt.internal.c.pango.PangoAttrList PangoAttrList;
public alias org.eclipse.swt.internal.c.pango.PangoAttrInt PangoAttrInt;
public alias org.eclipse.swt.internal.c.pango.PangoContext PangoContext;
public alias org.eclipse.swt.internal.c.pango.PangoFontDescription PangoFontDescription;
public alias org.eclipse.swt.internal.c.pango.PangoFontFace PangoFontFace;
public alias org.eclipse.swt.internal.c.pango.PangoFontFamily PangoFontFamily;
public alias org.eclipse.swt.internal.c.pango.PangoItem PangoItem;
public alias org.eclipse.swt.internal.c.pango.PangoLogAttr PangoLogAttr;
public alias org.eclipse.swt.internal.c.pango.PangoLayout PangoLayout;
public alias org.eclipse.swt.internal.c.pango.PangoLayoutLine PangoLayoutLine;
public alias org.eclipse.swt.internal.c.pango.PangoLayoutRun PangoLayoutRun;
public alias org.eclipse.swt.internal.c.pango.PangoRectangle PangoRectangle;
public alias org.eclipse.swt.internal.c.pango.PangoTabArray PangoTabArray;

public alias org.eclipse.swt.internal.c.cairo.cairo_t cairo_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_pattern_t cairo_pattern_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_surface_t cairo_surface_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_text_extents_t cairo_text_extents_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_font_extents_t cairo_font_extents_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_matrix_t cairo_matrix_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_path_t cairo_path_t;
public alias org.eclipse.swt.internal.c.cairo.cairo_path_data_t cairo_path_data_t;

public alias org.eclipse.swt.internal.c.gtk.GtkVSeparatorClass GtkVSeparatorClass;
public alias org.eclipse.swt.internal.c.gtk.GtkVSeparator GtkVSeparator;
public alias org.eclipse.swt.internal.c.gtk.GtkVScaleClass GtkVScaleClass;
public alias org.eclipse.swt.internal.c.gtk.GtkVScale GtkVScale;
public alias org.eclipse.swt.internal.c.gtk.GtkVRulerClass GtkVRulerClass;
public alias org.eclipse.swt.internal.c.gtk.GtkVRuler GtkVRuler;
public alias org.eclipse.swt.internal.c.gtk.GtkVPanedClass GtkVPanedClass;
public alias org.eclipse.swt.internal.c.gtk.GtkVPaned GtkVPaned;
public alias org.eclipse.swt.internal.c.gtk.GtkVolumeButtonClass GtkVolumeButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkVButtonBoxClass GtkVButtonBoxClass;
public alias org.eclipse.swt.internal.c.gtk.GtkVButtonBox GtkVButtonBox;
public alias org.eclipse.swt.internal.c.gtk.GtkUIManagerClass GtkUIManagerClass;
public alias org.eclipse.swt.internal.c.gtk.GtkUIManager GtkUIManager;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeStoreClass GtkTreeStoreClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeStore GtkTreeStore;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeModelSortClass GtkTreeModelSortClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeModelSort GtkTreeModelSort;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeDragDestIface GtkTreeDragDestIface;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeDragSourceIface GtkTreeDragSourceIface;
public alias org.eclipse.swt.internal.c.gtk.GtkToolbarClass GtkToolbarClass;
public alias org.eclipse.swt.internal.c.gtk.GtkToolbar GtkToolbar;
public alias org.eclipse.swt.internal.c.gtk.GtkToolbarChild GtkToolbarChild;
public alias org.eclipse.swt.internal.c.gtk.GtkTipsQueryClass GtkTipsQueryClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTipsQuery GtkTipsQuery;
public alias org.eclipse.swt.internal.c.gtk.GtkTextViewClass GtkTextViewClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTextView GtkTextView;
public alias org.eclipse.swt.internal.c.gtk.GtkTextBufferClass GtkTextBufferClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTextMarkClass GtkTextMarkClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTextMark GtkTextMark;
public alias org.eclipse.swt.internal.c.gtk.GtkTextTagTableClass GtkTextTagTableClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTearoffMenuItemClass GtkTearoffMenuItemClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTearoffMenuItem GtkTearoffMenuItem;
public alias org.eclipse.swt.internal.c.gtk.GtkTableRowCol GtkTableRowCol;
public alias org.eclipse.swt.internal.c.gtk.GtkTableChild GtkTableChild;
public alias org.eclipse.swt.internal.c.gtk.GtkTableClass GtkTableClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTable GtkTable;
public alias org.eclipse.swt.internal.c.gtk.GtkStockItem GtkStockItem;
public alias org.eclipse.swt.internal.c.gtk.GtkStatusIconClass GtkStatusIconClass;
public alias org.eclipse.swt.internal.c.gtk.GtkStatusIcon GtkStatusIcon;
public alias org.eclipse.swt.internal.c.gtk.GtkStatusbarClass GtkStatusbarClass;
public alias org.eclipse.swt.internal.c.gtk.GtkStatusbar GtkStatusbar;
public alias org.eclipse.swt.internal.c.gtk.GtkSpinButtonClass GtkSpinButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkSpinButton GtkSpinButton;
public alias org.eclipse.swt.internal.c.gtk.GtkSizeGroupClass GtkSizeGroupClass;
public alias org.eclipse.swt.internal.c.gtk.GtkSizeGroup GtkSizeGroup;
public alias org.eclipse.swt.internal.c.gtk.GtkSeparatorToolItemClass GtkSeparatorToolItemClass;
public alias org.eclipse.swt.internal.c.gtk.GtkSeparatorToolItem GtkSeparatorToolItem;
public alias org.eclipse.swt.internal.c.gtk.GtkSeparatorMenuItemClass GtkSeparatorMenuItemClass;
public alias org.eclipse.swt.internal.c.gtk.GtkSeparatorMenuItem GtkSeparatorMenuItem;
public alias org.eclipse.swt.internal.c.gtk.GtkScrolledWindowClass GtkScrolledWindowClass;
public alias org.eclipse.swt.internal.c.gtk.GtkScrolledWindow GtkScrolledWindow;
public alias org.eclipse.swt.internal.c.gtk.GtkViewportClass GtkViewportClass;
public alias org.eclipse.swt.internal.c.gtk.GtkViewport GtkViewport;
public alias org.eclipse.swt.internal.c.gtk.GtkScaleButtonClass GtkScaleButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkScaleButton GtkScaleButton;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentChooserWidgetClass GtkRecentChooserWidgetClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentChooserWidget GtkRecentChooserWidget;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentChooserMenuClass GtkRecentChooserMenuClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentChooserMenu GtkRecentChooserMenu;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentChooserDialogClass GtkRecentChooserDialogClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentChooserDialog GtkRecentChooserDialog;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentChooserIface GtkRecentChooserIface;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentFilterInfo GtkRecentFilterInfo;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentActionClass GtkRecentActionClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentAction GtkRecentAction;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentManagerClass GtkRecentManagerClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentManager GtkRecentManager;
public alias org.eclipse.swt.internal.c.gtk.GtkRecentData GtkRecentData;
public alias org.eclipse.swt.internal.c.gtk.GtkRadioToolButtonClass GtkRadioToolButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRadioToolButton GtkRadioToolButton;
public alias org.eclipse.swt.internal.c.gtk.GtkToggleToolButtonClass GtkToggleToolButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkToggleToolButton GtkToggleToolButton;
public alias org.eclipse.swt.internal.c.gtk.GtkRadioMenuItemClass GtkRadioMenuItemClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRadioMenuItem GtkRadioMenuItem;
public alias org.eclipse.swt.internal.c.gtk.GtkRadioButtonClass GtkRadioButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRadioButton GtkRadioButton;
public alias org.eclipse.swt.internal.c.gtk.GtkRadioActionClass GtkRadioActionClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRadioAction GtkRadioAction;
public alias org.eclipse.swt.internal.c.gtk.GtkToggleActionClass GtkToggleActionClass;
public alias org.eclipse.swt.internal.c.gtk.GtkToggleAction GtkToggleAction;
public alias org.eclipse.swt.internal.c.gtk.GtkProgressBarClass GtkProgressBarClass;
public alias org.eclipse.swt.internal.c.gtk.GtkProgressBar GtkProgressBar;
public alias org.eclipse.swt.internal.c.gtk.GtkProgressClass GtkProgressClass;
public alias org.eclipse.swt.internal.c.gtk.GtkProgress GtkProgress;
public alias org.eclipse.swt.internal.c.gtk.GtkPrintOperation GtkPrintOperation;
public alias org.eclipse.swt.internal.c.gtk.GtkPrintOperationClass GtkPrintOperationClass;
public alias org.eclipse.swt.internal.c.gtk.GtkPrintOperationPreviewIface GtkPrintOperationPreviewIface;
public alias org.eclipse.swt.internal.c.gtk.GtkPageRange GtkPageRange;
public alias org.eclipse.swt.internal.c.gtk.GtkPreviewClass GtkPreviewClass;
public alias org.eclipse.swt.internal.c.gtk.GtkPreviewInfo GtkPreviewInfo;
public alias org.eclipse.swt.internal.c.gtk.GtkPreview GtkPreview;
public alias org.eclipse.swt.internal.c.gtk.GtkPlugClass GtkPlugClass;
public alias org.eclipse.swt.internal.c.gtk.GtkPlug GtkPlug;
public alias org.eclipse.swt.internal.c.gtk.GtkSocketClass GtkSocketClass;
public alias org.eclipse.swt.internal.c.gtk.GtkSocket GtkSocket;
public alias org.eclipse.swt.internal.c.gtk.GtkPixmapClass GtkPixmapClass;
public alias org.eclipse.swt.internal.c.gtk.GtkPixmap GtkPixmap;
public alias org.eclipse.swt.internal.c.gtk.GtkOptionMenuClass GtkOptionMenuClass;
public alias org.eclipse.swt.internal.c.gtk.GtkOptionMenu GtkOptionMenu;
public alias org.eclipse.swt.internal.c.gtk.GtkOldEditableClass GtkOldEditableClass;
public alias org.eclipse.swt.internal.c.gtk.GtkOldEditable GtkOldEditable;
public alias org.eclipse.swt.internal.c.gtk.GtkNotebookClass GtkNotebookClass;
public alias org.eclipse.swt.internal.c.gtk.GtkNotebook GtkNotebook;
public alias org.eclipse.swt.internal.c.gtk.GtkMessageDialogClass GtkMessageDialogClass;
public alias org.eclipse.swt.internal.c.gtk.GtkMessageDialog GtkMessageDialog;
public alias org.eclipse.swt.internal.c.gtk.GtkMenuToolButton GtkMenuToolButton;
public alias org.eclipse.swt.internal.c.gtk.GtkMenuToolButtonClass GtkMenuToolButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkToolButtonClass GtkToolButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkToolButton GtkToolButton;
public alias org.eclipse.swt.internal.c.gtk.GtkToolItemClass GtkToolItemClass;
public alias org.eclipse.swt.internal.c.gtk.GtkToolItem GtkToolItem;
public alias org.eclipse.swt.internal.c.gtk.GtkTooltipsData GtkTooltipsData;
public alias org.eclipse.swt.internal.c.gtk.GtkTooltipsClass GtkTooltipsClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTooltips GtkTooltips;
public alias org.eclipse.swt.internal.c.gtk.GtkMenuBarClass GtkMenuBarClass;
public alias org.eclipse.swt.internal.c.gtk.GtkMenuBar GtkMenuBar;
public alias org.eclipse.swt.internal.c.gtk.GtkListClass GtkListClass;
public alias org.eclipse.swt.internal.c.gtk.GtkList GtkList;
public alias org.eclipse.swt.internal.c.gtk.GtkListItemClass GtkListItemClass;
public alias org.eclipse.swt.internal.c.gtk.GtkListItem GtkListItem;
public alias org.eclipse.swt.internal.c.gtk.GtkLinkButtonClass GtkLinkButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkLinkButton GtkLinkButton;
public alias org.eclipse.swt.internal.c.gtk.GtkLayoutClass GtkLayoutClass;
public alias org.eclipse.swt.internal.c.gtk.GtkLayout GtkLayout;
public alias org.eclipse.swt.internal.c.gtk.GtkInvisibleClass GtkInvisibleClass;
public alias org.eclipse.swt.internal.c.gtk.GtkInvisible GtkInvisible;
public alias org.eclipse.swt.internal.c.gtk.GtkInputDialogClass GtkInputDialogClass;
public alias org.eclipse.swt.internal.c.gtk.GtkInputDialog GtkInputDialog;
public alias org.eclipse.swt.internal.c.gtk.GtkIMMulticontextClass GtkIMMulticontextClass;
public alias org.eclipse.swt.internal.c.gtk.GtkIMMulticontext GtkIMMulticontext;
public alias org.eclipse.swt.internal.c.gtk.GtkIMContextSimpleClass GtkIMContextSimpleClass;
public alias org.eclipse.swt.internal.c.gtk.GtkIMContextSimple GtkIMContextSimple;
public alias org.eclipse.swt.internal.c.gtk.GtkImageMenuItemClass GtkImageMenuItemClass;
public alias org.eclipse.swt.internal.c.gtk.GtkImageMenuItem GtkImageMenuItem;
public alias org.eclipse.swt.internal.c.gtk.GtkIconViewClass GtkIconViewClass;
public alias org.eclipse.swt.internal.c.gtk.GtkIconView GtkIconView;
public alias org.eclipse.swt.internal.c.gtk.GtkIconThemeClass GtkIconThemeClass;
public alias org.eclipse.swt.internal.c.gtk.GtkIconTheme GtkIconTheme;
public alias org.eclipse.swt.internal.c.gtk.GtkIconFactoryClass GtkIconFactoryClass;
public alias org.eclipse.swt.internal.c.gtk.GtkHSeparatorClass GtkHSeparatorClass;
public alias org.eclipse.swt.internal.c.gtk.GtkHSeparator GtkHSeparator;
public alias org.eclipse.swt.internal.c.gtk.GtkSeparatorClass GtkSeparatorClass;
public alias org.eclipse.swt.internal.c.gtk.GtkSeparator GtkSeparator;
public alias org.eclipse.swt.internal.c.gtk.GtkHScaleClass GtkHScaleClass;
public alias org.eclipse.swt.internal.c.gtk.GtkHScale GtkHScale;
public alias org.eclipse.swt.internal.c.gtk.GtkScaleClass GtkScaleClass;
public alias org.eclipse.swt.internal.c.gtk.GtkScale GtkScale;
public alias org.eclipse.swt.internal.c.gtk.GtkHRulerClass GtkHRulerClass;
public alias org.eclipse.swt.internal.c.gtk.GtkHRuler GtkHRuler;
public alias org.eclipse.swt.internal.c.gtk.GtkRulerMetric GtkRulerMetric;
public alias org.eclipse.swt.internal.c.gtk.GtkRulerClass GtkRulerClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRuler GtkRuler;
public alias org.eclipse.swt.internal.c.gtk.GtkHPanedClass GtkHPanedClass;
public alias org.eclipse.swt.internal.c.gtk.GtkHPaned GtkHPaned;
public alias org.eclipse.swt.internal.c.gtk.GtkPanedClass GtkPanedClass;
public alias org.eclipse.swt.internal.c.gtk.GtkPaned GtkPaned;
public alias org.eclipse.swt.internal.c.gtk.GtkHButtonBoxClass GtkHButtonBoxClass;
public alias org.eclipse.swt.internal.c.gtk.GtkHButtonBox GtkHButtonBox;
public alias org.eclipse.swt.internal.c.gtk.GtkHandleBoxClass GtkHandleBoxClass;
public alias org.eclipse.swt.internal.c.gtk.GtkHandleBox GtkHandleBox;
public alias org.eclipse.swt.internal.c.gtk.GtkGammaCurveClass GtkGammaCurveClass;
public alias org.eclipse.swt.internal.c.gtk.GtkGammaCurve GtkGammaCurve;
public alias org.eclipse.swt.internal.c.gtk.GtkFontSelectionDialogClass GtkFontSelectionDialogClass;
public alias org.eclipse.swt.internal.c.gtk.GtkFontSelectionDialog GtkFontSelectionDialog;
public alias org.eclipse.swt.internal.c.gtk.GtkFontSelectionClass GtkFontSelectionClass;
public alias org.eclipse.swt.internal.c.gtk.GtkFontSelection GtkFontSelection;
public alias org.eclipse.swt.internal.c.gtk.GtkFontButtonClass GtkFontButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkFontButton GtkFontButton;
public alias org.eclipse.swt.internal.c.gtk.GtkFileChooserWidgetClass GtkFileChooserWidgetClass;
public alias org.eclipse.swt.internal.c.gtk.GtkFileChooserWidget GtkFileChooserWidget;
public alias org.eclipse.swt.internal.c.gtk.GtkFileChooserDialogClass GtkFileChooserDialogClass;
public alias org.eclipse.swt.internal.c.gtk.GtkFileChooserDialog GtkFileChooserDialog;
public alias org.eclipse.swt.internal.c.gtk.GtkFileChooserButtonClass GtkFileChooserButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkFileChooserButton GtkFileChooserButton;
public alias org.eclipse.swt.internal.c.gtk.GtkFileFilterInfo GtkFileFilterInfo;
public alias org.eclipse.swt.internal.c.gtk.GtkFileFilter GtkFileFilter;
public alias org.eclipse.swt.internal.c.gtk.GtkFixedChild GtkFixedChild;
public alias org.eclipse.swt.internal.c.gtk.GtkFixedClass GtkFixedClass;
public alias org.eclipse.swt.internal.c.gtk.GtkFixed GtkFixed;
public alias org.eclipse.swt.internal.c.gtk.GtkFileSelectionClass GtkFileSelectionClass;
public alias org.eclipse.swt.internal.c.gtk.GtkFileSelection GtkFileSelection;
public alias org.eclipse.swt.internal.c.gtk.GtkExpanderClass GtkExpanderClass;
public alias org.eclipse.swt.internal.c.gtk.GtkExpander GtkExpander;
public alias org.eclipse.swt.internal.c.gtk.GtkEventBoxClass GtkEventBoxClass;
public alias org.eclipse.swt.internal.c.gtk.GtkEventBox GtkEventBox;
public alias org.eclipse.swt.internal.c.gtk.GtkCurveClass GtkCurveClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCurve GtkCurve;
public alias org.eclipse.swt.internal.c.gtk.GtkDrawingAreaClass GtkDrawingAreaClass;
public alias org.eclipse.swt.internal.c.gtk.GtkDrawingArea GtkDrawingArea;
public alias org.eclipse.swt.internal.c.gtk.GtkCTreeNode GtkCTreeNode;
public alias org.eclipse.swt.internal.c.gtk.GtkCTreeRow GtkCTreeRow;
public alias org.eclipse.swt.internal.c.gtk.GtkCTreeClass GtkCTreeClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCTree GtkCTree;
public alias org.eclipse.swt.internal.c.gtk.GtkComboBoxEntryClass GtkComboBoxEntryClass;
public alias org.eclipse.swt.internal.c.gtk.GtkComboBoxEntry GtkComboBoxEntry;
public alias org.eclipse.swt.internal.c.gtk.GtkComboBoxClass GtkComboBoxClass;
public alias org.eclipse.swt.internal.c.gtk.GtkComboBox GtkComboBox;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeSelectionClass GtkTreeSelectionClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeSelection GtkTreeSelection;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeViewClass GtkTreeViewClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeView GtkTreeView;
public alias org.eclipse.swt.internal.c.gtk.GtkEntryClass GtkEntryClass;
public alias org.eclipse.swt.internal.c.gtk.GtkEntry GtkEntry;
public alias org.eclipse.swt.internal.c.gtk.GtkEntryCompletionClass GtkEntryCompletionClass;
public alias org.eclipse.swt.internal.c.gtk.GtkEntryCompletion GtkEntryCompletion;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeModelFilterClass GtkTreeModelFilterClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeModelFilter GtkTreeModelFilter;
public alias org.eclipse.swt.internal.c.gtk.GtkListStoreClass GtkListStoreClass;
public alias org.eclipse.swt.internal.c.gtk.GtkListStore GtkListStore;
public alias org.eclipse.swt.internal.c.gtk.GtkIMContextClass GtkIMContextClass;
public alias org.eclipse.swt.internal.c.gtk.GtkIMContext GtkIMContext;
public alias org.eclipse.swt.internal.c.gtk.GtkEditableClass GtkEditableClass;
public alias org.eclipse.swt.internal.c.gtk.GtkComboClass GtkComboClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCombo GtkCombo;
public alias org.eclipse.swt.internal.c.gtk.GtkHBoxClass GtkHBoxClass;
public alias org.eclipse.swt.internal.c.gtk.GtkHBox GtkHBox;
public alias org.eclipse.swt.internal.c.gtk.GtkColorSelectionDialogClass GtkColorSelectionDialogClass;
public alias org.eclipse.swt.internal.c.gtk.GtkColorSelectionDialog GtkColorSelectionDialog;
public alias org.eclipse.swt.internal.c.gtk.GtkColorSelectionClass GtkColorSelectionClass;
public alias org.eclipse.swt.internal.c.gtk.GtkColorSelection GtkColorSelection;
public alias org.eclipse.swt.internal.c.gtk.GtkVBoxClass GtkVBoxClass;
public alias org.eclipse.swt.internal.c.gtk.GtkVBox GtkVBox;
public alias org.eclipse.swt.internal.c.gtk.GtkColorButtonClass GtkColorButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkColorButton GtkColorButton;
public alias org.eclipse.swt.internal.c.gtk.GtkCListDestInfo GtkCListDestInfo;
public alias org.eclipse.swt.internal.c.gtk.GtkCListCellInfo GtkCListCellInfo;
public alias org.eclipse.swt.internal.c.gtk.GtkCellWidget GtkCellWidget;
public alias org.eclipse.swt.internal.c.gtk.GtkCellPixText GtkCellPixText;
public alias org.eclipse.swt.internal.c.gtk.GtkCellPixmap GtkCellPixmap;
public alias org.eclipse.swt.internal.c.gtk.GtkCellText GtkCellText;
public alias org.eclipse.swt.internal.c.gtk.GtkCell GtkCell;
public alias org.eclipse.swt.internal.c.gtk.GtkCListRow GtkCListRow;
public alias org.eclipse.swt.internal.c.gtk.GtkCListColumn GtkCListColumn;
public alias org.eclipse.swt.internal.c.gtk.GtkCListClass GtkCListClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCList GtkCList;
public alias org.eclipse.swt.internal.c.gtk.GtkVScrollbarClass GtkVScrollbarClass;
public alias org.eclipse.swt.internal.c.gtk.GtkVScrollbar GtkVScrollbar;
public alias org.eclipse.swt.internal.c.gtk.GtkHScrollbarClass GtkHScrollbarClass;
public alias org.eclipse.swt.internal.c.gtk.GtkHScrollbar GtkHScrollbar;
public alias org.eclipse.swt.internal.c.gtk.GtkScrollbarClass GtkScrollbarClass;
public alias org.eclipse.swt.internal.c.gtk.GtkScrollbar GtkScrollbar;
public alias org.eclipse.swt.internal.c.gtk.GtkRangeClass GtkRangeClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRange GtkRange;
public alias org.eclipse.swt.internal.c.gtk.GtkTargetPair GtkTargetPair;
public alias org.eclipse.swt.internal.c.gtk.GtkTargetEntry GtkTargetEntry;
public alias org.eclipse.swt.internal.c.gtk.GtkTargetList GtkTargetList;
public alias org.eclipse.swt.internal.c.gtk.GtkTextBuffer GtkTextBuffer;
public alias org.eclipse.swt.internal.c.gtk.GtkTextChildAnchorClass GtkTextChildAnchorClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTextChildAnchor GtkTextChildAnchor;
public alias org.eclipse.swt.internal.c.gtk.GtkTextAppearance GtkTextAppearance;
public alias org.eclipse.swt.internal.c.gtk.GtkTextTagClass GtkTextTagClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTextTag GtkTextTag;
public alias org.eclipse.swt.internal.c.gtk.GtkTextAttributes GtkTextAttributes;
public alias org.eclipse.swt.internal.c.gtk.GtkTextTagTable GtkTextTagTable;
public alias org.eclipse.swt.internal.c.gtk.GtkTextIter GtkTextIter;
public alias org.eclipse.swt.internal.c.gtk.GtkCheckMenuItemClass GtkCheckMenuItemClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCheckMenuItem GtkCheckMenuItem;
public alias org.eclipse.swt.internal.c.gtk.GtkMenuItemClass GtkMenuItemClass;
public alias org.eclipse.swt.internal.c.gtk.GtkMenuItem GtkMenuItem;
public alias org.eclipse.swt.internal.c.gtk.GtkItemClass GtkItemClass;
public alias org.eclipse.swt.internal.c.gtk.GtkItem GtkItem;
public alias org.eclipse.swt.internal.c.gtk.GtkCheckButtonClass GtkCheckButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCheckButton GtkCheckButton;
public alias org.eclipse.swt.internal.c.gtk.GtkToggleButtonClass GtkToggleButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkToggleButton GtkToggleButton;
public alias org.eclipse.swt.internal.c.gtk.GtkCellViewClass GtkCellViewClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCellView GtkCellView;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererToggleClass GtkCellRendererToggleClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererToggle GtkCellRendererToggle;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererSpinClass GtkCellRendererSpinClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererSpin GtkCellRendererSpin;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererProgressClass GtkCellRendererProgressClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererProgress GtkCellRendererProgress;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererPixbufClass GtkCellRendererPixbufClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererPixbuf GtkCellRendererPixbuf;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererComboClass GtkCellRendererComboClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererCombo GtkCellRendererCombo;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererAccelClass GtkCellRendererAccelClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererAccel GtkCellRendererAccel;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererTextClass GtkCellRendererTextClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererText GtkCellRendererText;
public alias org.eclipse.swt.internal.c.gtk.GtkCellLayoutIface GtkCellLayoutIface;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeViewColumnClass GtkTreeViewColumnClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeViewColumn GtkTreeViewColumn;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeSortableIface GtkTreeSortableIface;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeModelIface GtkTreeModelIface;
public alias org.eclipse.swt.internal.c.gtk.GtkTreeIter GtkTreeIter;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRendererClass GtkCellRendererClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCellRenderer GtkCellRenderer;
public alias org.eclipse.swt.internal.c.gtk.GtkCellEditableIface GtkCellEditableIface;
public alias org.eclipse.swt.internal.c.gtk.GtkCalendarClass GtkCalendarClass;
public alias org.eclipse.swt.internal.c.gtk.GtkCalendar GtkCalendar;
public alias org.eclipse.swt.internal.c.gtk.GtkButtonClass GtkButtonClass;
public alias org.eclipse.swt.internal.c.gtk.GtkButton GtkButton;
public alias org.eclipse.swt.internal.c.gtk.GtkImageIconNameData GtkImageIconNameData;
public alias org.eclipse.swt.internal.c.gtk.GtkImageAnimationData GtkImageAnimationData;
public alias org.eclipse.swt.internal.c.gtk.GtkImageIconSetData GtkImageIconSetData;
public alias org.eclipse.swt.internal.c.gtk.GtkImageStockData GtkImageStockData;
public alias org.eclipse.swt.internal.c.gtk.GtkImagePixbufData GtkImagePixbufData;
public alias org.eclipse.swt.internal.c.gtk.GtkImageImageData GtkImageImageData;
public alias org.eclipse.swt.internal.c.gtk.GtkImagePixmapData GtkImagePixmapData;
public alias org.eclipse.swt.internal.c.gtk.GtkImageClass GtkImageClass;
public alias org.eclipse.swt.internal.c.gtk.GtkImage GtkImage;
public alias org.eclipse.swt.internal.c.gtk.GtkBuildableIface GtkBuildableIface;
public alias org.eclipse.swt.internal.c.gtk.GtkBuilderClass GtkBuilderClass;
public alias org.eclipse.swt.internal.c.gtk.GtkBuilder GtkBuilder;
public alias org.eclipse.swt.internal.c.gtk.GtkBindingArg GtkBindingArg;
public alias org.eclipse.swt.internal.c.gtk.GtkBindingSignal GtkBindingSignal;
public alias org.eclipse.swt.internal.c.gtk.GtkBindingEntry GtkBindingEntry;
public alias org.eclipse.swt.internal.c.gtk.GtkBindingSet GtkBindingSet;
public alias org.eclipse.swt.internal.c.gtk.GtkButtonBoxClass GtkButtonBoxClass;
public alias org.eclipse.swt.internal.c.gtk.GtkButtonBox GtkButtonBox;
public alias org.eclipse.swt.internal.c.gtk.GtkBoxChild GtkBoxChild;
public alias org.eclipse.swt.internal.c.gtk.GtkBoxClass GtkBoxClass;
public alias org.eclipse.swt.internal.c.gtk.GtkBox GtkBox;
public alias org.eclipse.swt.internal.c.gtk.GtkAssistantClass GtkAssistantClass;
public alias org.eclipse.swt.internal.c.gtk.GtkAssistant GtkAssistant;
public alias org.eclipse.swt.internal.c.gtk.GtkAspectFrameClass GtkAspectFrameClass;
public alias org.eclipse.swt.internal.c.gtk.GtkAspectFrame GtkAspectFrame;
public alias org.eclipse.swt.internal.c.gtk.GtkFrameClass GtkFrameClass;
public alias org.eclipse.swt.internal.c.gtk.GtkFrame GtkFrame;
public alias org.eclipse.swt.internal.c.gtk.GtkArrowClass GtkArrowClass;
public alias org.eclipse.swt.internal.c.gtk.GtkArrow GtkArrow;
public alias org.eclipse.swt.internal.c.gtk.GtkAlignmentClass GtkAlignmentClass;
public alias org.eclipse.swt.internal.c.gtk.GtkAlignment GtkAlignment;
public alias org.eclipse.swt.internal.c.gtk.GtkRadioActionEntry GtkRadioActionEntry;
public alias org.eclipse.swt.internal.c.gtk.GtkToggleActionEntry GtkToggleActionEntry;
public alias org.eclipse.swt.internal.c.gtk.GtkActionEntry GtkActionEntry;
public alias org.eclipse.swt.internal.c.gtk.GtkActionGroupClass GtkActionGroupClass;
public alias org.eclipse.swt.internal.c.gtk.GtkActionGroup GtkActionGroup;
public alias org.eclipse.swt.internal.c.gtk.GtkItemFactoryItem GtkItemFactoryItem;
public alias org.eclipse.swt.internal.c.gtk.GtkItemFactoryEntry GtkItemFactoryEntry;
public alias org.eclipse.swt.internal.c.gtk.GtkItemFactoryClass GtkItemFactoryClass;
public alias org.eclipse.swt.internal.c.gtk.GtkItemFactory GtkItemFactory;
public alias org.eclipse.swt.internal.c.gtk.GtkActionClass GtkActionClass;
public alias org.eclipse.swt.internal.c.gtk.GtkAction GtkAction;
public alias org.eclipse.swt.internal.c.gtk.GtkAccessibleClass GtkAccessibleClass;
public alias org.eclipse.swt.internal.c.gtk.GtkAccessible GtkAccessible;
public alias org.eclipse.swt.internal.c.gtk.GtkAccelLabelClass GtkAccelLabelClass;
public alias org.eclipse.swt.internal.c.gtk.GtkAccelLabel GtkAccelLabel;
public alias org.eclipse.swt.internal.c.gtk.GtkLabelClass GtkLabelClass;
public alias org.eclipse.swt.internal.c.gtk.GtkLabel GtkLabel;
public alias org.eclipse.swt.internal.c.gtk.GtkMenuClass GtkMenuClass;
public alias org.eclipse.swt.internal.c.gtk.GtkMenu GtkMenu;
public alias org.eclipse.swt.internal.c.gtk.GtkMenuShellClass GtkMenuShellClass;
public alias org.eclipse.swt.internal.c.gtk.GtkMenuShell GtkMenuShell;
public alias org.eclipse.swt.internal.c.gtk.GtkMiscClass GtkMiscClass;
public alias org.eclipse.swt.internal.c.gtk.GtkMisc GtkMisc;
public alias org.eclipse.swt.internal.c.gtk.GtkAboutDialogClass GtkAboutDialogClass;
public alias org.eclipse.swt.internal.c.gtk.GtkAboutDialog GtkAboutDialog;
public alias org.eclipse.swt.internal.c.gtk.GtkDialogClass GtkDialogClass;
public alias org.eclipse.swt.internal.c.gtk.GtkDialog GtkDialog;
public alias org.eclipse.swt.internal.c.gtk.GtkWindowGroupClass GtkWindowGroupClass;
public alias org.eclipse.swt.internal.c.gtk.GtkWindowGroup GtkWindowGroup;
public alias org.eclipse.swt.internal.c.gtk.GtkWindowClass GtkWindowClass;
public alias org.eclipse.swt.internal.c.gtk.GtkBinClass GtkBinClass;
public alias org.eclipse.swt.internal.c.gtk.GtkBin GtkBin;
public alias org.eclipse.swt.internal.c.gtk.GtkContainerClass GtkContainerClass;
public alias org.eclipse.swt.internal.c.gtk.GtkContainer GtkContainer;
public alias org.eclipse.swt.internal.c.gtk.GtkWindow GtkWindow;
public alias org.eclipse.swt.internal.c.gtk.GtkWidgetShapeInfo GtkWidgetShapeInfo;
public alias org.eclipse.swt.internal.c.gtk.GtkWidgetAuxInfo GtkWidgetAuxInfo;
public alias org.eclipse.swt.internal.c.gtk.GtkWidgetClass GtkWidgetClass;
public alias org.eclipse.swt.internal.c.gtk.GtkSelectionData GtkSelectionData;
public alias org.eclipse.swt.internal.c.gtk.GtkRequisition GtkRequisition;
public alias org.eclipse.swt.internal.c.gtk.GtkSettingsValue GtkSettingsValue;
public alias org.eclipse.swt.internal.c.gtk.GtkSettingsClass GtkSettingsClass;
public alias org.eclipse.swt.internal.c.gtk.GtkRcStyleClass GtkRcStyleClass;
public alias org.eclipse.swt.internal.c.gtk.GtkIconFactory GtkIconFactory;
public alias org.eclipse.swt.internal.c.gtk.GtkWidget GtkWidget;
public alias org.eclipse.swt.internal.c.gtk.GtkSettings GtkSettings;
public alias org.eclipse.swt.internal.c.gtk.GtkRcProperty GtkRcProperty;
public alias org.eclipse.swt.internal.c.gtk.GtkRcStyle GtkRcStyle;
public alias org.eclipse.swt.internal.c.gtk.GtkStyleClass GtkStyleClass;
public alias org.eclipse.swt.internal.c.gtk.GtkStyle GtkStyle;
public alias org.eclipse.swt.internal.c.gtk.GtkBorder GtkBorder;
public alias org.eclipse.swt.internal.c.gtk.GtkAdjustmentClass GtkAdjustmentClass;
public alias org.eclipse.swt.internal.c.gtk.GtkAdjustment GtkAdjustment;
public alias org.eclipse.swt.internal.c.gtk.GtkObjectClass GtkObjectClass;
public alias org.eclipse.swt.internal.c.gtk.GtkTypeInfo GtkTypeInfo;
public alias org.eclipse.swt.internal.c.gtk.GtkObject GtkObject;
public alias org.eclipse.swt.internal.c.gtk.GtkArg GtkArg;
public alias org.eclipse.swt.internal.c.gtk.GtkAccelGroupEntry GtkAccelGroupEntry;
public alias org.eclipse.swt.internal.c.gtk.GtkAccelKey GtkAccelKey;
public alias org.eclipse.swt.internal.c.gtk.GtkAccelGroupClass GtkAccelGroupClass;
public alias org.eclipse.swt.internal.c.gtk.GtkAccelGroup GtkAccelGroup;
public alias org.eclipse.swt.internal.c.gtk.GtkClipboard GtkClipboard;

public alias org.eclipse.swt.internal.c.gtk.GtkTreeModel GtkTreeModel;
public alias org.eclipse.swt.internal.c.gtk.GtkTreePath GtkTreePath;
public alias org.eclipse.swt.internal.c.gtk.GtkEditable GtkEditable;
public alias org.eclipse.swt.internal.c.gtk.GtkCallback GtkCallback;
public alias org.eclipse.swt.internal.c.gtk.GtkAllocation GtkAllocation;
public alias org.eclipse.swt.internal.c.gtk.GtkPageSetup GtkPageSetup;


public alias org.eclipse.swt.internal.c.gtk_unix_print_2_0.GtkPrinter GtkPrinter;
public alias org.eclipse.swt.internal.c.gtk_unix_print_2_0.GtkPrintUnixDialog GtkPrintUnixDialog;
public alias org.eclipse.swt.internal.c.gtk_unix_print_2_0.GtkPrintJob GtkPrintJob;
public alias org.eclipse.swt.internal.c.gtk_unix_print_2_0.GtkPrintSettings GtkPrintSettings;
public alias org.eclipse.swt.internal.c.gtk_unix_print_2_0.GtkPaperSize GtkPaperSize;

public alias org.eclipse.swt.internal.c.Xlib.XErrorEvent XErrorEvent;
public alias org.eclipse.swt.internal.c.Xlib.XExposeEvent XExposeEvent;
public alias org.eclipse.swt.internal.c.Xlib.XVisibilityEvent XVisibilityEvent;
public alias org.eclipse.swt.internal.c.Xlib.XEvent XEvent;
public alias org.eclipse.swt.internal.c.Xlib.XRectangle XRectangle;
public alias org.eclipse.swt.internal.c.Xlib.XButtonEvent XButtonEvent;
public alias org.eclipse.swt.internal.c.Xlib.XWindowChanges XWindowChanges;
public alias org.eclipse.swt.internal.c.Xlib.XFocusChangeEvent XFocusChangeEvent;
public alias org.eclipse.swt.internal.c.Xlib.XClientMessageEvent XClientMessageEvent;

public alias org.eclipse.swt.internal.c.Xrender.XRenderPictureAttributes XRenderPictureAttributes;
public alias org.eclipse.swt.internal.c.Xrender.XTransform XTransform;


// function with variadic argument list
private void gtk_widget_style_get1( GtkWidget* widget, in char* firstPropertyName, gint* res ){
    gtk_widget_style_get( widget, firstPropertyName, res, null );
}
// function with variadic argument list
private void g_object_get1( void* obj, in char* firstPropertyName, gint* res ){
    g_object_get( obj, firstPropertyName, res, null );
}

private void g_object_set1( void* obj, in char* firstPropertyName, ptrdiff_t value ){
    g_object_set( obj, firstPropertyName, value, null );
}

private void g_object_set1_float( void* obj, in char* firstPropertyName, float value ){
    g_object_set( obj, firstPropertyName, value, null );
}

private void g_signal_emit_by_name0( void* instance, in char* detailed_signal ){
    g_signal_emit_by_name( instance, detailed_signal );
}

private void g_signal_emit_by_name1( void* instance, in char* detailed_signal, int value ){
    g_signal_emit_by_name( instance, detailed_signal, value );
}

private void g_signal_emit_by_name2( void* instance, in char* detailed_signal, int value1, int value2 ){
    g_signal_emit_by_name( instance, detailed_signal, value1, value2 );
}

private void g_signal_emit_by_name3( void* instance, in char* detailed_signal, int value1, int value2, int value3 ){
    g_signal_emit_by_name( instance, detailed_signal, value1, value2, value3 );
}

private void gdk_pixbuf_save_to_buffer0(GdkPixbuf *pixbuf, char **buffer, gsize *buffer_size,
   in char *type, GError **error ){
    gdk_pixbuf_save_to_bufferv( pixbuf, buffer, buffer_size, type, null, null, error );
}

private void gtk_list_store_set1(void* store , void* iter, gint column, void* value ){
    gtk_list_store_set( cast(GtkListStore *)store, cast(GtkTreeIter *)iter, column, value, -1 );
}

private void gtk_tree_model_get1(void* store , void* iter, gint column, void** value ){
    gtk_tree_model_get( cast(GtkTreeModel*) store, cast(GtkTreeIter *)iter, column, value, -1 );
}

private void gtk_tree_store_set1(void* tree_store, GtkTreeIter *iter, gint column, void* value ){
    gtk_tree_store_set( tree_store, iter, column, value, -1 );
}
private void gtk_cell_layout_set_attributes1( void *cell_layout, void* cell, in void* key, void* value ){
    gtk_cell_layout_set_attributes( cast(GtkCellLayout *)cell_layout, cast(GtkCellRenderer*)cell, key, value, null );
}
GtkWidget * gtk_file_chooser_dialog_new2(in char * title, aGtkWindow * parent, int action, in char * btn0_text, int btn0_id, in char * btn1_text, int btn1_id ){
    return gtk_file_chooser_dialog_new( title, parent, action, btn0_text, btn0_id, btn1_text, btn1_id, null );
}
// for linux always true, the other possibility would be GDK_WINDOWING_WIN32
private bool GDK_WINDOWING_X11(){
    return true;
}

private guint GDK_PIXMAP_XID(GdkDrawable* win){
    return gdk_x11_drawable_get_xid(win);
}

// macro
glong g_signal_connect( void* instance, in char* sig, GCallback handle, void* ptr ){
    return g_signal_connect_data( instance, sig, handle, ptr, cast(GClosureNotify) 0, cast(GConnectFlags)0 );
}
// macro
void gdk_cursor_destroy( GdkCursor* cursor ){
    gdk_cursor_unref(cursor);
}

gint g_thread_supported(){
    return g_threads_got_initialized;
}

private char* localeconv_decimal_point(){
    return localeconv().decimal_point;
}

// fontconfig.h
struct FcConfig{};
private extern(C) int FcConfigAppFontAddFile (FcConfig *config, in char  *file);


template NameOfFunc(alias f) {
    // Note: highly dependent on the .stringof formatting
    // the value begins with "& " which is why the first two chars are cut off

    // this is also used in org.eclipse.swt/internal/cairo/Cairo and org.eclipse.swt/internal/accessible/gtk/ATK
    version( LDC ){
        // stringof in LDC is "&foobar"
        static assert( (&f).stringof[0] == '&' );
        static assert( (&f).stringof[1] != ' ' );
        const char[] NameOfFunc = (&f).stringof[1 .. $];
    }
    else{
        // stringof in DMD is "& foobar"
        static assert( (&f).stringof[0] == '&' );
        static assert( (&f).stringof[1] == ' ' );
        const char[] NameOfFunc = (&f).stringof[2 .. $];
    }
}

template ForwardGtkOsCFunc( alias cFunc ) {
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
/+
// alternative template implementation, might be more stable
template ForwardGtkOsCFunc(char[] name) {
  alias typeof(mixin(name)) func;
  alias ParameterTupleOf!(func) Params;
  alias ReturnTypeOf!(func) Ret;
  mixin("public static Ret "~name~"( Params p ) {
    return ."~name~"(p);
  }");
}
+/
//import org.eclipse.swt.internal.*;

// for ctfe, save static ctor
private gint buildVERSION(gint major, gint minor, gint micro) {
    return (major << 16) + (minor << 8) + micro;
}
private gint GTK_VERSION(){
    version( GTK_DYN_LINK ) return buildVERSION(*gtk_major_version, *gtk_minor_version, *gtk_micro_version);
    else                    return buildVERSION( gtk_major_version,  gtk_minor_version,  gtk_micro_version);
}

public class OS : Platform {

    static this(){
        org.eclipse.swt.internal.c.gtk.loadLib();
        org.eclipse.swt.internal.c.pango.loadLib();
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 10, 0)){
//            org.eclipse.swt.internal.c.gtk_unix_print_2_0.loadLib();
        }
    }



    /** OS Constants */
    public static const bool IsAIX   = false;
    public static const bool IsSunOS = false;
    public static const bool IsLinux = true;
    public static const bool IsHPUX  = false;

    /** Constants */
    public static const int ATK_RELATION_LABELLED_BY = 4;
    public static const int G_SIGNAL_MATCH_DATA = 1 << 4;
    public static const int G_SIGNAL_MATCH_ID = 1 << 0;
    public static const int GDK_2BUTTON_PRESS = 0x5;
    public static const int GDK_3BUTTON_PRESS = 0x6;
    public static const int GDK_ACTION_COPY = 1 << 1;
    public static const int GDK_ACTION_MOVE = 1 << 2;
    public static const int GDK_ACTION_LINK = 1 << 3;
    public static const int GDK_Alt_L = 0xffe9;
    public static const int GDK_Alt_R = 0xffea;
    public static const int GDK_AND = 4;
    public static const int GDK_BackSpace = 0xff08;
    public static const int GDK_BOTTOM_LEFT_CORNER = 0xc;
    public static const int GDK_BOTTOM_RIGHT_CORNER = 0xe;
    public static const int GDK_BOTTOM_SIDE = 0x10;
    public static const int GDK_BUTTON1_MASK = 0x100;
    public static const int GDK_BUTTON2_MASK = 0x200;
    public static const int GDK_BUTTON3_MASK = 0x400;
    public static const int GDK_BUTTON_MOTION_MASK  = 1 << 4;
    public static const int GDK_BUTTON1_MOTION_MASK = 1 << 5;
    public static const int GDK_BUTTON2_MOTION_MASK = 1 << 6;
    public static const int GDK_BUTTON3_MOTION_MASK = 1 << 7;
    public static const int GDK_BUTTON_PRESS = 0x4;
    public static const int GDK_BUTTON_PRESS_MASK = 0x100;
    public static const int GDK_BUTTON_RELEASE = 0x7;
    public static const int GDK_BUTTON_RELEASE_MASK = 0x200;
    public static const int GDK_CAP_BUTT = 0x1;
    public static const int GDK_CAP_PROJECTING = 3;
    public static const int GDK_CAP_ROUND = 0x2;
    public static const int GDK_COLORSPACE_RGB = 0;
    public static const int GDK_CONFIGURE = 13;
    public static const int GDK_CONTROL_MASK = 0x4;
    public static const int GDK_COPY = 0x0;
    public static const int GDK_CROSS = 0x1e;
    public static const int GDK_CROSSING_NORMAL = 0;
    public static const int GDK_CROSSING_GRAB = 1;
    public static const int GDK_CROSSING_UNGRAB = 2;
    public static const int GDK_Break = 0xff6b;
    public static const int GDK_Cancel = 0xff69;
    public static const int GDK_Caps_Lock = 0xffE5;
    public static const int GDK_Clear = 0xff0B;
    public static const int GDK_Control_L = 0xffe3;
    public static const int GDK_Control_R = 0xffe4;
    public static const int GDK_CURRENT_TIME = 0x0;
    public static const int GDK_DECOR_BORDER = 0x2;
    public static const int GDK_DECOR_MAXIMIZE = 0x40;
    public static const int GDK_DECOR_MENU = 0x10;
    public static const int GDK_DECOR_MINIMIZE = 0x20;
    public static const int GDK_DECOR_RESIZEH = 0x4;
    public static const int GDK_DECOR_TITLE = 0x8;
    public static const int GDK_DOUBLE_ARROW = 0x2a;
    public static const int GDK_Delete = 0xffff;
    public static const int GDK_Down = 0xff54;
    public static const int GDK_ENTER_NOTIFY_MASK = 0x1000;
    public static const int GDK_ENTER_NOTIFY = 10;
    public static const int GDK_EVEN_ODD_RULE = 0;
    public static const int GTK_EXPANDER_COLAPSED = 0;
    public static const int GTK_EXPANDER_SEMI_COLLAPSED = 1;
    public static const int GTK_EXPANDER_SEMI_EXPANDED = 2;
    public static const int GTK_EXPANDER_EXPANDED = 3;
    public static const int GDK_EXPOSE = 2;
    public static const int GDK_EXPOSURE_MASK = 0x2;
    public static const int GDK_End = 0xff57;
    public static const int GDK_Escape = 0xff1b;
    public static const int GDK_F1 = 0xffbe;
    public static const int GDK_F10 = 0xffc7;
    public static const int GDK_F11 = 0xffc8;
    public static const int GDK_F12 = 0xffc9;
    public static const int GDK_F13 = 0xffca;
    public static const int GDK_F14 = 0xffcb;
    public static const int GDK_F15 = 0xffcc;
    public static const int GDK_F2 = 0xffbf;
    public static const int GDK_F3 = 0xffc0;
    public static const int GDK_F4 = 0xffc1;
    public static const int GDK_F5 = 0xffc2;
    public static const int GDK_F6 = 0xffc3;
    public static const int GDK_F7 = 0xffc4;
    public static const int GDK_F8 = 0xffc5;
    public static const int GDK_F9 = 0xffc6;
    public static const int GDK_FLEUR = 0x34;
    public static const int GDK_FOCUS_CHANGE = 0xc;
    public static const int GDK_FOCUS_CHANGE_MASK = 0x4000;
    public static const int GDK_GC_FOREGROUND = 0x1;
    public static const int GDK_GC_CLIP_MASK = 0x80;
    public static const int GDK_GC_CLIP_X_ORIGIN = 0x800;
    public static const int GDK_GC_CLIP_Y_ORIGIN = 0x1000;
    public static const int GDK_GC_LINE_WIDTH = 0x4000;
    public static const int GDK_GC_LINE_STYLE = 0x8000;
    public static const int GDK_GC_CAP_STYLE = 0x10000;
    public static const int GDK_GC_JOIN_STYLE = 0x20000;
    public static const int GDK_GRAB_SUCCESS = 0x0;
    public static const int GDK_HAND2 = 0x3c;
    public static const int GDK_Help = 0xFF6A;
    public static const int GDK_HINT_MIN_SIZE = 1 << 1;
    public static const int GDK_Home = 0xff50;
    public static const int GDK_INCLUDE_INFERIORS = 0x1;
    public static const int GDK_INPUT_ONLY = 1;
    public static const int GDK_INTERP_BILINEAR = 0x2;
    public static const int GDK_Insert = 0xff63;
    public static const int GDK_ISO_Left_Tab = 0xfe20;
    public static const int GDK_JOIN_MITER = 0x0;
    public static const int GDK_JOIN_ROUND = 0x1;
    public static const int GDK_JOIN_BEVEL = 0x2;
    public static const int GDK_KEY_PRESS = 0x8;
    public static const int GDK_KEY_PRESS_MASK = 0x400;
    public static const int GDK_KEY_RELEASE = 0x9;
    public static const int GDK_KEY_RELEASE_MASK = 0x800;
    public static const int GDK_KP_0 = 0xffb0;
    public static const int GDK_KP_1 = 0xffb1;
    public static const int GDK_KP_2 = 0xffb2;
    public static const int GDK_KP_3 = 0xffb3;
    public static const int GDK_KP_4 = 0xffb4;
    public static const int GDK_KP_5 = 0xffb5;
    public static const int GDK_KP_6 = 0xffb6;
    public static const int GDK_KP_7 = 0xffb7;
    public static const int GDK_KP_8 = 0xffb8;
    public static const int GDK_KP_9 = 0xffb9;
    public static const int GDK_KP_Add = 0xffab;
    public static const int GDK_KP_Decimal = 0xffae;
    public static const int GDK_KP_Delete = 0xFF9F;
    public static const int GDK_KP_Divide = 0xffaf;
    public static const int GDK_KP_Down = 0xFF99;
    public static const int GDK_KP_End = 0xFF9C;
    public static const int GDK_KP_Enter = 0xff8d;
    public static const int GDK_KP_Equal = 0xffbd;
    public static const int GDK_KP_Home = 0xFF95;
    public static const int GDK_KP_Insert = 0xFF9E;
    public static const int GDK_KP_Left = 0xFF96;
    public static const int GDK_KP_Multiply = 0xffaa;
    public static const int GDK_KP_Page_Down = 0xFF9B;
    public static const int GDK_KP_Page_Up = 0xFF9A;
    public static const int GDK_KP_Right = 0xFF98;
    public static const int GDK_KP_Subtract = 0xffad;
    public static const int GDK_KP_Up = 0xFF97;
    public static const int GDK_LEAVE_NOTIFY = 11;
    public static const int GDK_LEAVE_NOTIFY_MASK = 0x2000;
    public static const int GDK_LEFT_PTR = 0x44;
    public static const int GDK_LEFT_SIDE = 0x46;
    public static const int GDK_LINE_ON_OFF_DASH = 0x1;
    public static const int GDK_LINE_SOLID = 0x0;
    public static const int GDK_Linefeed = 0xff0A;
    public static const int GDK_LSB_FIRST = 0x0;
    public static const int GDK_Left = 0xff51;
    public static const int GDK_Meta_L = 0xFFE7;
    public static const int GDK_Meta_R = 0xFFE8;
    public static const int GDK_MAP = 14;
    public static const int GDK_MOD1_MASK = 0x8;
    public static const int GDK_MOTION_NOTIFY = 0x3;
    public static const int GDK_NO_EXPOSE = 30;
    public static const int GDK_NONE = 0;
    public static const int GDK_NOTIFY_INFERIOR = 2;
    public static const int GDK_Num_Lock = 0xFF7F;
    public static const int GDK_OVERLAP_RECTANGLE_OUT = 0x1;
    public static const int GDK_PIXBUF_ALPHA_BILEVEL = 0x0;
    public static const int GDK_POINTER_MOTION_HINT_MASK = 0x8;
    public static const int GDK_POINTER_MOTION_MASK = 0x4;
    public static const int GDK_PROPERTY_NOTIFY = 16;
    public static const int GDK_Page_Down = 0xff56;
    public static const int GDK_Page_Up = 0xff55;
    public static const int GDK_Pause = 0xff13;
    public static const int GDK_Print = 0xff61;
    public static const int GDK_QUESTION_ARROW = 0x5c;
    public static const int GDK_RGB_DITHER_NORMAL = 0x1;
    public static const int GDK_RIGHT_SIDE = 0x60;
    public static const int GDK_Return = 0xff0d;
    public static const int GDK_Right = 0xff53;
    public static const int GDK_space = 0x20;
    public static const int GDK_SB_H_DOUBLE_ARROW = 0x6c;
    public static const int GDK_SB_UP_ARROW = 0x72;
    public static const int GDK_SB_V_DOUBLE_ARROW = 0x74;
    public static const int GDK_SCROLL_UP = 0;
    public static const int GDK_SCROLL_DOWN = 1;
    public static const int GDK_SCROLL_LEFT = 2;
    public static const int GDK_SCROLL_RIGHT = 3;
    public static const int GDK_SELECTION_CLEAR = 17;
    public static const int GDK_SELECTION_NOTIFY = 19;
    public static const int GDK_SELECTION_REQUEST = 18;
    public static const int GDK_SHIFT_MASK = 0x1;
    public static const int GDK_SIZING = 0x78;
    public static const int GDK_STIPPLED = 0x2;
    public static const int GDK_TILED = 0x1;
    public static const int GDK_Shift_L = 0xffe1;
    public static const int GDK_Shift_R = 0xffe2;
    public static const int GDK_SCROLL = 31;
    public static const int GDK_Scroll_Lock = 0xff14;
    public static const int GDK_TOP_LEFT_CORNER = 0x86;
    public static const int GDK_TOP_RIGHT_CORNER = 0x88;
    public static const int GDK_TOP_SIDE = 0x8a;
    public static const int GDK_Tab = 0xff09;
    public static const int GDK_Up = 0xff52;
    public static const int GDK_WATCH = 0x96;
    public static const int GDK_XOR = 0x2;
    public static const int GDK_XTERM = 0x98;
    public static const int GDK_X_CURSOR = 0x0;
    public static const int GDK_VISIBILITY_FULLY_OBSCURED = 2;
    public static const int GDK_VISIBILITY_NOTIFY_MASK = 1 << 17;
    public static const int GDK_WINDOW_CHILD = 2;
    public static const int GDK_WINDOW_STATE_ICONIFIED  = 1 << 1;
    public static const int GDK_WINDOW_STATE_MAXIMIZED  = 1 << 2;
    public static const int GDK_WINDOW_STATE_FULLSCREEN  = 1 << 4;
    public static const int GTK_ACCEL_VISIBLE = 0x1;
    public static const int GTK_ARROW_DOWN = 0x1;
    public static const int GTK_ARROW_LEFT = 0x2;
    public static const int GTK_ARROW_RIGHT = 0x3;
    public static const int GTK_ARROW_UP = 0x0;
    public static const int GTK_CALENDAR_SHOW_HEADING = 1 << 0;
    public static const int GTK_CALENDAR_SHOW_DAY_NAMES = 1 << 1;
    public static const int GTK_CALENDAR_NO_MONTH_CHANGE = 1 << 2;
    public static const int GTK_CALENDAR_SHOW_WEEK_NUMBERS = 1 << 3;
    public static const int GTK_CALENDAR_WEEK_START_MONDAY = 1 << 4;
    public static const int GTK_CAN_DEFAULT = 0x2000;
    public static const int GTK_CAN_FOCUS = 0x800;
    public static const int GTK_CELL_RENDERER_MODE_ACTIVATABLE = 1;
    public static const int GTK_CELL_RENDERER_SELECTED = 1 << 0;
    public static const int GTK_CELL_RENDERER_FOCUSED = 1 << 4;
    public static const int GTK_CLIST_SHOW_TITLES = 0x4;
    public static const int GTK_CORNER_TOP_LEFT = 0x0;
    public static const int GTK_CORNER_TOP_RIGHT = 0x2;
    public static const int GTK_DIALOG_DESTROY_WITH_PARENT = 1 << 1;
    public static const int GTK_DIALOG_MODAL = 1 << 0;
    public static const int GTK_DIR_TAB_FORWARD = 0;
    public static const int GTK_DIR_TAB_BACKWARD = 1;
    public static const int GTK_FILE_CHOOSER_ACTION_OPEN = 0;
    public static const int GTK_FILE_CHOOSER_ACTION_SAVE = 1;
    public static const int GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER = 2;
    public static const int GTK_HAS_FOCUS = 1 << 12;
    public static const int GTK_ICON_SIZE_MENU = 1;
    public static const int GTK_ICON_SIZE_SMALL_TOOLBAR = 2;
    public static const int GTK_ICON_SIZE_LARGE_TOOLBAR = 3;
    public static const int GTK_ICON_SIZE_DIALOG = 6;
    public static const int GTK_JUSTIFY_CENTER = 0x2;
    public static const int GTK_JUSTIFY_LEFT = 0x0;
    public static const int GTK_JUSTIFY_RIGHT = 0x1;
    public static const int GTK_MAPPED = 1 << 7;
    public static const int GTK_MESSAGE_INFO = 0;
    public static const int GTK_MESSAGE_WARNING = 1;
    public static const int GTK_MESSAGE_QUESTION = 2;
    public static const int GTK_MESSAGE_ERROR = 3;
    public static const int GTK_NO_WINDOW = 1 << 5;
    public static const int GTK_ORIENTATION_HORIZONTAL = 0x0;
    public static const int GTK_ORIENTATION_VERTICAL = 0x1;
    public static const int GTK_PACK_END = 1;
    public static const int GTK_PACK_START = 0;
    public static const int GTK_POLICY_ALWAYS = 0x0;
    public static const int GTK_POLICY_AUTOMATIC = 0x1;
    public static const int GTK_POLICY_NEVER = 0x2;
    public static const int GTK_POS_TOP = 0x2;
    public static const int GTK_POS_BOTTOM = 0x3;
    public static const int GTK_PRINT_CAPABILITY_PAGE_SET     = 1 << 0;
    public static const int GTK_PRINT_CAPABILITY_COPIES       = 1 << 1;
    public static const int GTK_PRINT_CAPABILITY_COLLATE      = 1 << 2;
    public static const int GTK_PRINT_CAPABILITY_REVERSE      = 1 << 3;
    public static const int GTK_PRINT_CAPABILITY_SCALE        = 1 << 4;
    public static const int GTK_PRINT_CAPABILITY_GENERATE_PDF = 1 << 5;
    public static const int GTK_PRINT_CAPABILITY_GENERATE_PS  = 1 << 6;
    public static const int GTK_PRINT_CAPABILITY_PREVIEW      = 1 << 7;
    public static const int GTK_PRINT_PAGES_ALL = 0;
    public static const int GTK_PRINT_PAGES_CURRENT = 1;
    public static const int GTK_PRINT_PAGES_RANGES = 2;
    public static const int GTK_PROGRESS_CONTINUOUS = 0x0;
    public static const int GTK_PROGRESS_DISCRETE = 0x1;
    public static const int GTK_PROGRESS_LEFT_TO_RIGHT = 0x0;
    public static const int GTK_PROGRESS_BOTTOM_TO_TOP = 0x2;
    public static const int GTK_REALIZED  = 1 << 6;
    public static const int GTK_RECEIVES_DEFAULT = 1 << 20;
    public static const int GTK_RELIEF_NONE = 0x2;
    public static const int GTK_RELIEF_NORMAL = 0;
    public static const int GTK_RC_BG = 1 << 1;
    public static const int GTK_RC_FG = 1 << 0;
    public static const int GTK_RC_TEXT = 1 << 2;
    public static const int GTK_RC_BASE = 1 << 3;
    public static const int GTK_RESPONSE_APPLY = 0xfffffff6;
    public static const int GTK_RESPONSE_CANCEL = 0xfffffffa;
    public static const int GTK_RESPONSE_OK = 0xfffffffb;
    public static const int GTK_SCROLL_NONE = 0;
    public static const int GTK_SCROLL_JUMP = 1;
    public static const int GTK_SCROLL_STEP_BACKWARD = 2;
    public static const int GTK_SCROLL_STEP_FORWARD = 3;
    public static const int GTK_SCROLL_PAGE_BACKWARD = 4;
    public static const int GTK_SCROLL_PAGE_FORWARD = 5;
    public static const int GTK_SCROLL_STEP_UP = 6;
    public static const int GTK_SCROLL_STEP_DOWN = 7;
    public static const int GTK_SCROLL_PAGE_UP = 8;
    public static const int GTK_SCROLL_PAGE_DOWN = 9;
    public static const int GTK_SCROLL_STEP_LEFT = 10;
    public static const int GTK_SCROLL_STEP_RIGHT = 11;
    public static const int GTK_SCROLL_PAGE_LEFT = 12;
    public static const int GTK_SCROLL_PAGE_RIGHT = 13;
    public static const int GTK_SCROLL_START = 14;
    public static const int GTK_SCROLL_END = 15;
    public static const int GTK_SELECTION_BROWSE = 0x2;
    public static const int GTK_SELECTION_MULTIPLE = 0x3;
    public static const int GTK_SENSITIVE = 0x200;
    public static const int GTK_SHADOW_ETCHED_IN = 0x3;
    public static const int GTK_SHADOW_ETCHED_OUT = 0x4;
    public static const int GTK_SHADOW_IN = 0x1;
    public static const int GTK_SHADOW_NONE = 0x0;
    public static const int GTK_SHADOW_OUT = 0x2;
    public static const int GTK_STATE_ACTIVE = 0x1;
    public static const int GTK_STATE_INSENSITIVE = 0x4;
    public static const int GTK_STATE_NORMAL = 0x0;
    public static const int GTK_STATE_PRELIGHT = 0x2;
    public static const int GTK_STATE_SELECTED = 0x3;
    public static const int GTK_TEXT_DIR_LTR = 1;
    public static const int GTK_TEXT_DIR_NONE = 0 ;
    public static const int GTK_TEXT_DIR_RTL = 2;
    public static const int GTK_TEXT_WINDOW_TEXT = 2;
    public static const int GTK_TOOLBAR_CHILD_BUTTON = 0x1;
    public static const int GTK_TOOLBAR_CHILD_RADIOBUTTON = 0x3;
    public static const int GTK_TOOLBAR_CHILD_TOGGLEBUTTON = 0x2;
    public static const int GTK_TREE_VIEW_COLUMN_GROW_ONLY = 0;
    public static const int GTK_TREE_VIEW_COLUMN_AUTOSIZE = 1;
    public static const int GTK_TREE_VIEW_COLUMN_FIXED = 2;
    public static const int GTK_TREE_VIEW_DROP_BEFORE = 0;
    public static const int GTK_TREE_VIEW_DROP_AFTER = 1;
    public static const int GTK_TREE_VIEW_DROP_INTO_OR_BEFORE = 2;
    public static const int GTK_TREE_VIEW_DROP_INTO_OR_AFTER = 3;
    public static const int GDK_UNMAP = 15;
    public static const int GTK_UNIT_PIXEL = 0;
    public static const int GTK_UNIT_POINTS = 1;
    public static const int GTK_UNIT_INCH = 2;
    public static const int GTK_UNIT_MM = 3;
    public static const int GTK_VISIBILITY_FULL = 0x2;
    public static const int GTK_VISIBILITY_NONE = 0x0;
    public static const int GTK_VISIBLE = 0x100;
    public static const int GDK_WA_X = 1 << 2;
    public static const int GDK_WA_Y = 1 << 3;
    public static const int GDK_WA_VISUAL = 1 << 6;
    public static const int GTK_WINDOW_POPUP = 0x1;
    public static const int GTK_WINDOW_TOPLEVEL = 0x0;
    public static const int GDK_WINDOW_TYPE_HINT_DIALOG = 1;
    public static const int GTK_WRAP_NONE = 0;
    public static const int GTK_WRAP_WORD = 2;
    public static const int GTK_WRAP_WORD_CHAR = 3;
    public static const int G_LOG_FLAG_FATAL = 0x2;
    public static const int G_LOG_FLAG_RECURSION = 0x1;
    public static const int G_LOG_LEVEL_MASK = 0xfffffffc;
    public static const int None = 0;
    public static const int PANGO_ALIGN_LEFT = 0;
    public static const int PANGO_ALIGN_CENTER = 1;
    public static const int PANGO_ALIGN_RIGHT = 2;
    public static const int PANGO_ATTR_FOREGROUND = 9;
    public static const int PANGO_ATTR_BACKGROUND = 10;
    public static const int PANGO_ATTR_UNDERLINE = 11;
    public static const int PANGO_ATTR_UNDERLINE_COLOR = 18;
    public static const int PANGO_DIRECTION_LTR = 0;
    public static const int PANGO_DIRECTION_RTL = 1;
    public static const int PANGO_SCALE = 1024;
    public static const int PANGO_STRETCH_NORMAL = 0x4;
    public static const int PANGO_STYLE_ITALIC = 0x2;
    public static const int PANGO_STYLE_NORMAL = 0x0;
    public static const int PANGO_STYLE_OBLIQUE = 0x1;
    public static const int PANGO_TAB_LEFT = 0;
    public static const int PANGO_UNDERLINE_NONE = 0;
    public static const int PANGO_UNDERLINE_SINGLE = 1;
    public static const int PANGO_UNDERLINE_DOUBLE = 2;
    public static const int PANGO_UNDERLINE_LOW = 3;
    public static const int PANGO_UNDERLINE_ERROR = 4;
    public static const int PANGO_WEIGHT_BOLD = 0x2bc;
    public static const int PANGO_WEIGHT_NORMAL = 0x190;
    public static const int PANGO_WRAP_WORD = 0;
    public static const int PANGO_WRAP_WORD_CHAR = 2;
    public static const int RTLD_LAZY = 1;
    public static const int XA_CARDINAL = 6;
    public static const int XA_WINDOW = 33;

    /** Signals */
    public static const char[] activate = "activate";
    public static const char[] button_press_event = "button-press-event";
    public static const char[] button_release_event = "button-release-event";
    public static const char[] changed = "changed";
    public static const char[] change_current_page = "change-current-page";
    public static const char[] change_value = "change-value";
    public static const char[] clicked = "clicked";
    public static const char[] commit = "commit";
    public static const char[] configure_event = "configure-event";
    public static const char[] delete_event = "delete-event";
    public static const char[] day_selected = "day-selected";
    public static const char[] delete_range = "delete-range";
    public static const char[] delete_text = "delete-text";
    public static const char[] drag_data_delete = "drag_data_delete";
    public static const char[] drag_data_get = "drag_data_get";
    public static const char[] drag_data_received = "drag_data_received";
    public static const char[] drag_drop = "drag_drop";
    public static const char[] drag_end = "drag_end";
    public static const char[] drag_leave = "drag_leave";
    public static const char[] drag_motion = "drag_motion";
    public static const char[] enter_notify_event = "enter-notify-event";
    public static const char[] event = "event";
    public static const char[] event_after = "event-after";
    public static const char[] expand_collapse_cursor_row = "expand-collapse-cursor-row";
    public static const char[] expose_event = "expose-event";
    public static const char[] focus = "focus";
    public static const char[] focus_in_event = "focus-in-event";
    public static const char[] focus_out_event = "focus-out-event";
    public static const char[] grab_focus = "grab-focus";
    public static const char[] hide = "hide";
    public static const char[] input = "input";
    public static const char[] insert_text = "insert-text";
    public static const char[] key_press_event = "key-press-event";
    public static const char[] key_release_event = "key-release-event";
    public static const char[] leave_notify_event = "leave-notify-event";
    public static const char[] map = "map";
    public static const char[] map_event = "map-event";
    public static const char[] mnemonic_activate = "mnemonic-activate";
    public static const char[] month_changed = "month-changed";
    public static const char[] motion_notify_event = "motion-notify-event";
    public static const char[] move_focus = "move-focus";
    public static const char[] output = "output";
    public static const char[] popup_menu = "popup-menu";
    public static const char[] populate_popup = "populate-popup";
    public static const char[] preedit_changed = "preedit-changed";
    public static const char[] realize = "realize";
    public static const char[] row_activated = "row-activated";
    public static const char[] row_changed = "row-changed";
    public static const char[] scroll_child = "scroll-child";
    public static const char[] scroll_event = "scroll-event";
    public static const char[] select = "select";
    public static const char[] show = "show";
    public static const char[] show_help = "show-help";
    public static const char[] size_allocate = "size-allocate";
    public static const char[] size_request = "size-request";
    public static const char[] style_set = "style-set";
    public static const char[] switch_page = "switch-page";
    public static const char[] test_collapse_row = "test-collapse-row";
    public static const char[] test_expand_row = "test-expand-row";
    public static const char[] toggled = "toggled";
    public static const char[] unmap = "unmap";
    public static const char[] unmap_event = "unmap-event";
    public static const char[] unrealize = "unrealize";
    public static const char[] value_changed = "value-changed";
    public static const char[] visibility_notify_event = "visibility-notify-event";
    public static const char[] window_state_event = "window-state-event";

    /** Properties */
    public static const char[] active = "active";
    public static const char[] background_gdk = "background-gdk";
    public static const char[] button_relief = "button-relief";
    public static const char[] cell_background_gdk = "cell-background-gdk";
    public static const char[] default_border = "default-border";
    public static const char[] expander_size = "expander-size";
    public static const char[] fixed_height_mode = "fixed-height-mode";
    public static const char[] focus_line_width = "focus-line-width";
    public static const char[] font_desc = "font-desc";
    public static const char[] foreground_gdk = "foreground-gdk";
    public static const char[] gtk_cursor_blink = "gtk-cursor-blink";
    public static const char[] gtk_cursor_blink_time = "gtk-cursor-blink-time";
    public static const char[] gtk_double_click_time = "gtk-double-click-time";
    public static const char[] gtk_entry_select_on_focus = "gtk-entry-select-on-focus";
    public static const char[] horizontal_separator = "horizontal-separator";
    public static const char[] inconsistent = "inconsistent";
    public static const char[] interior_focus = "interior-focus";
    public static const char[] mode = "mode";
    public static const char[] pixbuf = "pixbuf";
    public static const char[] text = "text";
    public static const char[] xalign = "xalign";
    public static const char[] ypad = "ypad";
    public static const char[] GTK_PRINT_SETTINGS_OUTPUT_URI = "output-uri";

    public static gint GTK_VERSION(){
        return .GTK_VERSION();
    }
//     = buildVERSION(gtk_major_version(), gtk_minor_version(), gtk_micro_version());


public static gint buildVERSION(gint major, gint minor, gint micro) {
    return .buildVERSION( major, minor, micro );
}

/++
public static final native gint localeconv_decimal_point();
public static final native gint realpath(byte[] path, byte[] realPath);
++/

/** X11 Native methods and constants */
public static const int Above = 0;
public static const int Below = 1;
public static const int ButtonRelease = 5;
public static const int ClientMessage = 33;
public static const int CurrentTime = 0;
public static const int CWSibling = 0x20;
public static const int CWStackMode = 0x40;
public static const int EnterNotify = 7;
public static const int Expose = 12;
public static const int FocusChangeMask = 1 << 21;
public static const int FocusIn = 9;
public static const int FocusOut = 10;
public static const int GraphicsExpose = 13;
public static const int NoExpose = 14;
public static const int ExposureMask = 1 << 15;
public static const gint NoEventMask = 0;
public static const int NotifyNormal = 0;
public static const int NotifyGrab = 1;
public static const int NotifyHint = 1;
public static const int NotifyUngrab = 2;
public static const int NotifyWhileGrabbed = 3;
public static const int NotifyAncestor = 0;
public static const int NotifyVirtual = 1;
public static const int NotifyNonlinear = 3;
public static const int NotifyNonlinearVirtual = 4;
public static const int NotifyPointer = 5;
public static const int RevertToParent = 2;
public static const int VisibilityChangeMask = 1 << 16;
public static const int VisibilityFullyObscured = 2;
public static const int VisibilityNotify = 15;
public static const int SYSTEM_TRAY_REQUEST_DOCK = 0;

/** X render natives and constants */
public static const int PictStandardARGB32 = 0;
public static const int PictStandardRGB24 = 1;
public static const int PictStandardA8 = 2;
public static const int PictStandardA4 = 3;
public static const int PictStandardA1 = 4;
public static const int PictOpSrc = 1;
public static const int PictOpOver = 3;

    public static gint gtk_major_version(){
        version(GTK_DYN_LINK) return *.gtk_minor_version;
        else                  return .gtk_minor_version;
    }
    public static gint gtk_minor_version(){
        version(GTK_DYN_LINK) return *.gtk_minor_version;
        else                  return .gtk_minor_version;
    }
    public static gint gtk_micro_version(){
        version(GTK_DYN_LINK) return *.gtk_micro_version;
        else                  return .gtk_micro_version;
    }
    mixin ForwardGtkOsCFunc!(localeconv_decimal_point);
    mixin ForwardGtkOsCFunc!(realpath);

//    mixin ForwardGtkOsCFunc!(X_EVENT_TYPE);
//    mixin ForwardGtkOsCFunc!(X_EVENT_WINDOW);
//    mixin ForwardGtkOsCFunc!(.Call);
//    mixin ForwardGtkOsCFunc!(.call );
    mixin ForwardGtkOsCFunc!(.GDK_WINDOWING_X11);
    mixin ForwardGtkOsCFunc!(.GDK_PIXMAP_XID);

//     mixin ForwardGtkOsCFunc!(.XCheckMaskEvent);
//     mixin ForwardGtkOsCFunc!(.XCheckWindowEvent);
    mixin ForwardGtkOsCFunc!(.XCheckIfEvent);
    mixin ForwardGtkOsCFunc!(.XDefaultScreen);
    mixin ForwardGtkOsCFunc!(.XDefaultRootWindow);
    mixin ForwardGtkOsCFunc!(.XFlush);
    mixin ForwardGtkOsCFunc!(.XFree);
    mixin ForwardGtkOsCFunc!(.XGetSelectionOwner);
    mixin ForwardGtkOsCFunc!(.XInternAtom);
    mixin ForwardGtkOsCFunc!(.XQueryPointer);
    mixin ForwardGtkOsCFunc!(.XQueryTree);
    mixin ForwardGtkOsCFunc!(.XKeysymToKeycode);
    mixin ForwardGtkOsCFunc!(.XListProperties);
    mixin ForwardGtkOsCFunc!(.XReconfigureWMWindow);
    mixin ForwardGtkOsCFunc!(.XSendEvent);

    mixin ForwardGtkOsCFunc!(.XSetIOErrorHandler);
    mixin ForwardGtkOsCFunc!(.XSetErrorHandler);
    mixin ForwardGtkOsCFunc!(.XSetInputFocus);
    mixin ForwardGtkOsCFunc!(.XSetTransientForHint);
    mixin ForwardGtkOsCFunc!(.XSynchronize);
    mixin ForwardGtkOsCFunc!(.XTestFakeButtonEvent);
    mixin ForwardGtkOsCFunc!(.XTestFakeKeyEvent);
    mixin ForwardGtkOsCFunc!(.XTestFakeMotionEvent);
    mixin ForwardGtkOsCFunc!(.XWarpPointer);

    mixin ForwardGtkOsCFunc!(.gdk_x11_atom_to_xatom);
    mixin ForwardGtkOsCFunc!(.gdk_x11_colormap_get_xcolormap);
    mixin ForwardGtkOsCFunc!(.gdk_x11_drawable_get_xdisplay);
    mixin ForwardGtkOsCFunc!(.gdk_x11_drawable_get_xid);
    mixin ForwardGtkOsCFunc!(.gdk_x11_screen_lookup_visual);
    mixin ForwardGtkOsCFunc!(.gdk_x11_screen_get_window_manager_name);
    mixin ForwardGtkOsCFunc!(.gdk_x11_visual_get_xvisual);
    mixin ForwardGtkOsCFunc!(.gdk_pixmap_foreign_new);
    mixin ForwardGtkOsCFunc!(.gdk_window_lookup);
    mixin ForwardGtkOsCFunc!(.gdk_window_add_filter);
    mixin ForwardGtkOsCFunc!(.gdk_window_remove_filter);

/** X render natives and constants */

    mixin ForwardGtkOsCFunc!(.XRenderQueryExtension);
    mixin ForwardGtkOsCFunc!(.XRenderQueryVersion);
    mixin ForwardGtkOsCFunc!(.XRenderCreatePicture);
    mixin ForwardGtkOsCFunc!(.XRenderSetPictureClipRectangles);
    mixin ForwardGtkOsCFunc!(.XRenderSetPictureTransform);
    mixin ForwardGtkOsCFunc!(.XRenderFreePicture);
    mixin ForwardGtkOsCFunc!(.XRenderComposite);
    mixin ForwardGtkOsCFunc!(.XRenderFindStandardFormat);
    mixin ForwardGtkOsCFunc!(.XRenderFindVisualFormat);

    mixin ForwardGtkOsCFunc!(.g_signal_add_emission_hook);
    mixin ForwardGtkOsCFunc!(.g_signal_remove_emission_hook);
    mixin ForwardGtkOsCFunc!(.g_cclosure_new);
    mixin ForwardGtkOsCFunc!(.g_closure_ref);
    mixin ForwardGtkOsCFunc!(.g_closure_unref);
    mixin ForwardGtkOsCFunc!(.g_main_context_acquire);
    mixin ForwardGtkOsCFunc!(.g_main_context_check);
    mixin ForwardGtkOsCFunc!(.g_main_context_default);
    mixin ForwardGtkOsCFunc!(.g_main_context_iteration);
    mixin ForwardGtkOsCFunc!(.g_main_context_pending);
    mixin ForwardGtkOsCFunc!(.g_main_context_get_poll_func);
    mixin ForwardGtkOsCFunc!(.g_main_context_prepare);
    mixin ForwardGtkOsCFunc!(.g_main_context_query);
    mixin ForwardGtkOsCFunc!(.g_main_context_release);

    // no lock for g_main_context_wakeup
    alias .g_main_context_wakeup g_main_context_wakeup;

    mixin ForwardGtkOsCFunc!(.g_filename_to_utf8);
    mixin ForwardGtkOsCFunc!(.g_filename_to_uri);
    mixin ForwardGtkOsCFunc!(.g_filename_from_utf8);
    mixin ForwardGtkOsCFunc!(.g_filename_from_uri);
    mixin ForwardGtkOsCFunc!(.g_free);
    mixin ForwardGtkOsCFunc!(.g_idle_add);
    mixin ForwardGtkOsCFunc!(.g_list_append);
    mixin ForwardGtkOsCFunc!(.g_list_free);
    mixin ForwardGtkOsCFunc!(.g_list_free_1);
    mixin ForwardGtkOsCFunc!(.g_list_length);
    mixin ForwardGtkOsCFunc!(.g_list_nth);
    mixin ForwardGtkOsCFunc!(.g_list_nth_data);
    mixin ForwardGtkOsCFunc!(.g_list_prepend);
    mixin ForwardGtkOsCFunc!(.g_list_remove_link);
    mixin ForwardGtkOsCFunc!(.g_list_reverse);
    mixin ForwardGtkOsCFunc!(.g_locale_from_utf8);
    mixin ForwardGtkOsCFunc!(.g_locale_to_utf8);
    mixin ForwardGtkOsCFunc!(.g_log_default_handler);
    mixin ForwardGtkOsCFunc!(.g_log_remove_handler);
    mixin ForwardGtkOsCFunc!(.g_log_set_handler);
    mixin ForwardGtkOsCFunc!(.g_malloc);
    mixin ForwardGtkOsCFunc!(.g_object_get1);
    mixin ForwardGtkOsCFunc!(.g_object_get_qdata);
    mixin ForwardGtkOsCFunc!(.g_object_new);
    mixin ForwardGtkOsCFunc!(.g_object_ref);
    mixin ForwardGtkOsCFunc!(.g_object_set1);
    mixin ForwardGtkOsCFunc!(.g_object_set1_float);
    mixin ForwardGtkOsCFunc!(.g_object_set_qdata);
    mixin ForwardGtkOsCFunc!(.g_object_unref);
    mixin ForwardGtkOsCFunc!(.g_object_get_data);
    mixin ForwardGtkOsCFunc!(.g_object_set_data);
    mixin ForwardGtkOsCFunc!(.g_quark_from_string);
    mixin ForwardGtkOsCFunc!(.g_set_prgname);
    mixin ForwardGtkOsCFunc!(.g_signal_connect_closure);
    mixin ForwardGtkOsCFunc!(.g_signal_connect_closure_by_id);
    mixin ForwardGtkOsCFunc!(.g_signal_emit_by_name0);
    mixin ForwardGtkOsCFunc!(.g_signal_emit_by_name1);
    mixin ForwardGtkOsCFunc!(.g_signal_emit_by_name2);
    mixin ForwardGtkOsCFunc!(.g_signal_emit_by_name3);
    mixin ForwardGtkOsCFunc!(.g_signal_handler_disconnect);
    mixin ForwardGtkOsCFunc!(.g_signal_handlers_block_matched);
    mixin ForwardGtkOsCFunc!(.g_signal_handlers_disconnect_matched);
    mixin ForwardGtkOsCFunc!(.g_signal_handlers_unblock_matched);
    mixin ForwardGtkOsCFunc!(.g_signal_lookup );
    mixin ForwardGtkOsCFunc!(.g_signal_stop_emission_by_name);
    mixin ForwardGtkOsCFunc!(.g_source_remove );
    mixin ForwardGtkOsCFunc!(.g_slist_free );
    mixin ForwardGtkOsCFunc!(.g_slist_length );
    mixin ForwardGtkOsCFunc!(.g_strfreev);
    mixin ForwardGtkOsCFunc!(.g_strtod);
    mixin ForwardGtkOsCFunc!(.g_type_add_interface_static );
    mixin ForwardGtkOsCFunc!(.g_type_class_peek );
    mixin ForwardGtkOsCFunc!(.g_type_class_peek_parent );
    mixin ForwardGtkOsCFunc!(.g_type_from_name );
    mixin ForwardGtkOsCFunc!(.g_type_interface_peek_parent );
    mixin ForwardGtkOsCFunc!(.g_type_is_a );
    mixin ForwardGtkOsCFunc!(.g_type_name );
    mixin ForwardGtkOsCFunc!(.g_type_parent );
    mixin ForwardGtkOsCFunc!(.g_type_query );
    mixin ForwardGtkOsCFunc!(.g_type_register_static );
    mixin ForwardGtkOsCFunc!(.g_thread_init);
    mixin ForwardGtkOsCFunc!(.g_thread_supported);
    mixin ForwardGtkOsCFunc!(.g_utf16_to_utf8);
    mixin ForwardGtkOsCFunc!(.g_utf8_offset_to_pointer);
    mixin ForwardGtkOsCFunc!(.g_utf8_pointer_to_offset);
    mixin ForwardGtkOsCFunc!(.g_utf8_strlen);
    mixin ForwardGtkOsCFunc!(.g_utf8_to_utf16);
    mixin ForwardGtkOsCFunc!(.g_value_peek_pointer);
    mixin ForwardGtkOsCFunc!(.gdk_atom_intern);
    mixin ForwardGtkOsCFunc!(.gdk_atom_name);
    mixin ForwardGtkOsCFunc!(.gdk_beep);
    mixin ForwardGtkOsCFunc!(.gdk_bitmap_create_from_data);
    mixin ForwardGtkOsCFunc!(.gdk_cairo_region);
    mixin ForwardGtkOsCFunc!(.gdk_cairo_set_source_color);
    mixin ForwardGtkOsCFunc!(.gdk_color_white);
    mixin ForwardGtkOsCFunc!(.gdk_colormap_alloc_color);
    mixin ForwardGtkOsCFunc!(.gdk_colormap_free_colors);
    mixin ForwardGtkOsCFunc!(.gdk_colormap_get_system);
    mixin ForwardGtkOsCFunc!(.gdk_colormap_query_color);
    mixin ForwardGtkOsCFunc!(.gdk_cursor_destroy); // is alias for gdk_cursor_unref
    mixin ForwardGtkOsCFunc!(.gdk_cursor_new);
    mixin ForwardGtkOsCFunc!(.gdk_cursor_new_from_pixmap);
    mixin ForwardGtkOsCFunc!(.gdk_cursor_new_from_pixbuf);
    mixin ForwardGtkOsCFunc!(.gdk_display_get_default);
    mixin ForwardGtkOsCFunc!(.gdk_display_supports_cursor_color);
    mixin ForwardGtkOsCFunc!(.gdk_drag_status);
    mixin ForwardGtkOsCFunc!(.gdk_draw_arc);
    mixin ForwardGtkOsCFunc!(.gdk_draw_drawable);
    mixin ForwardGtkOsCFunc!(.gdk_draw_image);
    mixin ForwardGtkOsCFunc!(.gdk_draw_layout);
    mixin ForwardGtkOsCFunc!(.gdk_draw_layout_with_colors);
    mixin ForwardGtkOsCFunc!(.gdk_draw_line);
    mixin ForwardGtkOsCFunc!(.gdk_draw_lines);
    mixin ForwardGtkOsCFunc!(.gdk_draw_pixbuf);
    mixin ForwardGtkOsCFunc!(.gdk_draw_point);
    mixin ForwardGtkOsCFunc!(.gdk_draw_polygon);
    mixin ForwardGtkOsCFunc!(.gdk_draw_rectangle);
    mixin ForwardGtkOsCFunc!(.gdk_drawable_get_depth);
    mixin ForwardGtkOsCFunc!(.gdk_drawable_get_image);
    mixin ForwardGtkOsCFunc!(.gdk_drawable_get_size);
    mixin ForwardGtkOsCFunc!(.gdk_drawable_get_visible_region);
    mixin ForwardGtkOsCFunc!(.gdk_event_copy);
    mixin ForwardGtkOsCFunc!(.gdk_event_free);
    mixin ForwardGtkOsCFunc!(.gdk_event_get);
    mixin ForwardGtkOsCFunc!(.gdk_event_get_root_coords);
    mixin ForwardGtkOsCFunc!(.gdk_event_get_coords);
    mixin ForwardGtkOsCFunc!(.gdk_event_get_graphics_expose);
    mixin ForwardGtkOsCFunc!(.gdk_event_get_state);
    mixin ForwardGtkOsCFunc!(.gdk_event_get_time);
    mixin ForwardGtkOsCFunc!(.gdk_event_handler_set);
    mixin ForwardGtkOsCFunc!(.gdk_event_new);
    mixin ForwardGtkOsCFunc!(.gdk_event_peek);
    mixin ForwardGtkOsCFunc!(.gdk_event_put);
    mixin ForwardGtkOsCFunc!(.gdk_error_trap_push);
    mixin ForwardGtkOsCFunc!(.gdk_error_trap_pop);
    mixin ForwardGtkOsCFunc!(.gdk_flush);
//    mixin ForwardGtkOsCFunc!(.gdk_free_text_list);
    mixin ForwardGtkOsCFunc!(.gdk_gc_get_values);
    mixin ForwardGtkOsCFunc!(.gdk_gc_new);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_background);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_clip_mask);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_clip_origin);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_clip_rectangle);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_clip_region);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_dashes);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_exposures);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_fill);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_foreground);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_function);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_line_attributes);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_stipple);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_subwindow);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_tile);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_ts_origin);
    mixin ForwardGtkOsCFunc!(.gdk_gc_set_values);
    mixin ForwardGtkOsCFunc!(.gdk_keyboard_ungrab);
    mixin ForwardGtkOsCFunc!(.gdk_keymap_get_default);
    mixin ForwardGtkOsCFunc!(.gdk_keymap_translate_keyboard_state );
    mixin ForwardGtkOsCFunc!(.gdk_keyval_to_lower);
    mixin ForwardGtkOsCFunc!(.gdk_keyval_to_unicode);
    mixin ForwardGtkOsCFunc!(.gdk_pango_context_get);
    mixin ForwardGtkOsCFunc!(.gdk_pango_context_set_colormap);
    mixin ForwardGtkOsCFunc!(.gdk_pango_layout_get_clip_region);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_copy_area);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_get_from_drawable);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_get_has_alpha);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_get_height);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_get_pixels);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_get_rowstride);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_get_width);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_loader_new);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_loader_close);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_loader_get_pixbuf);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_loader_write);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_new);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_new_from_file);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_render_to_drawable);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_render_to_drawable_alpha);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_render_pixmap_and_mask);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_save_to_buffer0);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_scale);
    mixin ForwardGtkOsCFunc!(.gdk_pixbuf_scale_simple);
    mixin ForwardGtkOsCFunc!(.gdk_pixmap_new);
    mixin ForwardGtkOsCFunc!(.gdk_pointer_grab);
    mixin ForwardGtkOsCFunc!(.gdk_pointer_is_grabbed);
    mixin ForwardGtkOsCFunc!(.gdk_pointer_ungrab);
    mixin ForwardGtkOsCFunc!(.gdk_property_get);
    mixin ForwardGtkOsCFunc!(.gdk_region_destroy);
    mixin ForwardGtkOsCFunc!(.gdk_region_empty);
    mixin ForwardGtkOsCFunc!(.gdk_region_get_clipbox);
    mixin ForwardGtkOsCFunc!(.gdk_region_get_rectangles);
    mixin ForwardGtkOsCFunc!(.gdk_region_intersect);
    mixin ForwardGtkOsCFunc!(.gdk_region_new);
    mixin ForwardGtkOsCFunc!(.gdk_region_offset);
    mixin ForwardGtkOsCFunc!(.gdk_region_point_in);
    mixin ForwardGtkOsCFunc!(.gdk_region_polygon);
    mixin ForwardGtkOsCFunc!(.gdk_region_rectangle);
    mixin ForwardGtkOsCFunc!(.gdk_region_rect_in);
    mixin ForwardGtkOsCFunc!(.gdk_region_subtract);
    mixin ForwardGtkOsCFunc!(.gdk_region_union);
    mixin ForwardGtkOsCFunc!(.gdk_region_union_with_rect);
    mixin ForwardGtkOsCFunc!(.gdk_rgb_init);
    mixin ForwardGtkOsCFunc!(.gdk_screen_get_default);
    mixin ForwardGtkOsCFunc!(.gdk_screen_get_monitor_at_point );
    mixin ForwardGtkOsCFunc!(.gdk_screen_get_monitor_at_window);
    mixin ForwardGtkOsCFunc!(.gdk_screen_get_monitor_geometry );
    mixin ForwardGtkOsCFunc!(.gdk_screen_get_n_monitors);
    mixin ForwardGtkOsCFunc!(.gdk_screen_get_number);
    mixin ForwardGtkOsCFunc!(.gdk_screen_height);
    mixin ForwardGtkOsCFunc!(.gdk_screen_width);
    mixin ForwardGtkOsCFunc!(.gdk_screen_width_mm);
    mixin ForwardGtkOsCFunc!(.gdk_set_program_class);
    mixin ForwardGtkOsCFunc!(.gdk_utf8_to_compound_text);
    mixin ForwardGtkOsCFunc!(.gdk_utf8_to_string_target);
    mixin ForwardGtkOsCFunc!(.gdk_text_property_to_utf8_list);
    mixin ForwardGtkOsCFunc!(.gtk_tooltip_trigger_tooltip_query);
    mixin ForwardGtkOsCFunc!(.gdk_unicode_to_keyval);
    mixin ForwardGtkOsCFunc!(.gdk_visual_get_system);
    mixin ForwardGtkOsCFunc!(.gdk_window_at_pointer);
    mixin ForwardGtkOsCFunc!(.gdk_window_begin_paint_rect);
    mixin ForwardGtkOsCFunc!(.gdk_window_clear_area);
    mixin ForwardGtkOsCFunc!(.gdk_window_destroy);
    mixin ForwardGtkOsCFunc!(.gdk_window_end_paint);
    mixin ForwardGtkOsCFunc!(.gdk_window_get_children);
    mixin ForwardGtkOsCFunc!(.gdk_window_get_events);
    mixin ForwardGtkOsCFunc!(.gdk_window_focus);
    mixin ForwardGtkOsCFunc!(.gdk_window_freeze_updates);
    mixin ForwardGtkOsCFunc!(.gdk_window_get_frame_extents);
    mixin ForwardGtkOsCFunc!(.gdk_window_get_internal_paint_info);
    mixin ForwardGtkOsCFunc!(.gdk_window_get_origin);
    mixin ForwardGtkOsCFunc!(.gdk_window_get_parent);
    mixin ForwardGtkOsCFunc!(.gdk_window_get_pointer);
    mixin ForwardGtkOsCFunc!(.gdk_window_get_position);
    mixin ForwardGtkOsCFunc!(.gdk_window_get_user_data);
    mixin ForwardGtkOsCFunc!(.gdk_window_hide);
    mixin ForwardGtkOsCFunc!(.gdk_window_invalidate_rect);
    mixin ForwardGtkOsCFunc!(.gdk_window_invalidate_region);
    mixin ForwardGtkOsCFunc!(.gdk_window_is_visible);
    mixin ForwardGtkOsCFunc!(.gdk_window_move);
    mixin ForwardGtkOsCFunc!(.gdk_window_new);
    mixin ForwardGtkOsCFunc!(.gdk_window_lower);
    mixin ForwardGtkOsCFunc!(.gdk_window_process_all_updates);
    mixin ForwardGtkOsCFunc!(.gdk_window_process_updates);
    mixin ForwardGtkOsCFunc!(.gdk_window_raise);
    mixin ForwardGtkOsCFunc!(.gdk_window_resize);
    mixin ForwardGtkOsCFunc!(.gdk_window_scroll);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_accept_focus);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_back_pixmap);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_cursor);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_debug_updates);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_decorations);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_events);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_icon);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_icon_list);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_keep_above);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_override_redirect);
    mixin ForwardGtkOsCFunc!(.gdk_window_set_user_data);
    mixin ForwardGtkOsCFunc!(.gdk_window_shape_combine_region );
    mixin ForwardGtkOsCFunc!(.gdk_window_show);
    mixin ForwardGtkOsCFunc!(.gdk_window_show_unraised);
    mixin ForwardGtkOsCFunc!(.gdk_window_thaw_updates);
    mixin ForwardGtkOsCFunc!(.gtk_accel_group_new);
    mixin ForwardGtkOsCFunc!(.gtk_accel_groups_activate);
    mixin ForwardGtkOsCFunc!(.gtk_accel_label_set_accel_widget);
    mixin ForwardGtkOsCFunc!(.gtk_accel_label_get_accel_widget);
    mixin ForwardGtkOsCFunc!(.gtk_adjustment_changed);
    mixin ForwardGtkOsCFunc!(.gtk_adjustment_new);
    mixin ForwardGtkOsCFunc!(.gtk_adjustment_set_value);
    mixin ForwardGtkOsCFunc!(.gtk_adjustment_value_changed);
    mixin ForwardGtkOsCFunc!(.gtk_arrow_new);
    mixin ForwardGtkOsCFunc!(.gtk_arrow_set);
    mixin ForwardGtkOsCFunc!(.gtk_bin_get_child);
    mixin ForwardGtkOsCFunc!(.gtk_box_set_spacing);
    mixin ForwardGtkOsCFunc!(.gtk_box_set_child_packing);
    mixin ForwardGtkOsCFunc!(.gtk_button_clicked);
    mixin ForwardGtkOsCFunc!(.gtk_button_get_relief);
    mixin ForwardGtkOsCFunc!(.gtk_button_new);
    mixin ForwardGtkOsCFunc!(.gtk_button_set_relief);
    mixin ForwardGtkOsCFunc!(.gtk_calendar_new);
    mixin ForwardGtkOsCFunc!(.gtk_calendar_select_month);
    mixin ForwardGtkOsCFunc!(.gtk_calendar_select_day);
    mixin ForwardGtkOsCFunc!(.gtk_calendar_set_display_options);
    mixin ForwardGtkOsCFunc!(.gtk_calendar_display_options);
    mixin ForwardGtkOsCFunc!(.gtk_calendar_get_date);
    mixin ForwardGtkOsCFunc!(.gtk_cell_layout_clear);
    mixin ForwardGtkOsCFunc!(.gtk_cell_layout_set_attributes1);
    mixin ForwardGtkOsCFunc!(.gtk_cell_layout_pack_start);
    mixin ForwardGtkOsCFunc!(.gtk_cell_renderer_get_size);
    mixin ForwardGtkOsCFunc!(.gtk_cell_renderer_pixbuf_new);
    mixin ForwardGtkOsCFunc!(.gtk_cell_renderer_text_new);
    mixin ForwardGtkOsCFunc!(.gtk_cell_renderer_toggle_new);
    mixin ForwardGtkOsCFunc!(.gtk_check_button_new);
    mixin ForwardGtkOsCFunc!(.gtk_check_menu_item_get_active);
    mixin ForwardGtkOsCFunc!(.gtk_check_menu_item_new_with_label);
    mixin ForwardGtkOsCFunc!(.gtk_check_menu_item_set_active);
    mixin ForwardGtkOsCFunc!(.gtk_check_version);
    mixin ForwardGtkOsCFunc!(.gtk_clipboard_clear);
    mixin ForwardGtkOsCFunc!(.gtk_clipboard_get);
    mixin ForwardGtkOsCFunc!(.gtk_clipboard_set_with_data);
    mixin ForwardGtkOsCFunc!(.gtk_clipboard_wait_for_contents);
    mixin ForwardGtkOsCFunc!(.gtk_color_selection_dialog_new);
    mixin ForwardGtkOsCFunc!(.gtk_color_selection_get_current_color);
    mixin ForwardGtkOsCFunc!(.gtk_color_selection_set_current_color);
    mixin ForwardGtkOsCFunc!(.gtk_color_selection_set_has_palette);
    mixin ForwardGtkOsCFunc!(.gtk_combo_disable_activate);
    mixin ForwardGtkOsCFunc!(.gtk_combo_new);
    mixin ForwardGtkOsCFunc!(.gtk_combo_set_case_sensitive);
    mixin ForwardGtkOsCFunc!(.gtk_combo_box_set_focus_on_click);
    mixin ForwardGtkOsCFunc!(.gtk_combo_set_popdown_strings);
    mixin ForwardGtkOsCFunc!(.gtk_combo_box_entry_new_text);
    mixin ForwardGtkOsCFunc!(.gtk_combo_box_new_text);
    mixin ForwardGtkOsCFunc!(.gtk_combo_box_insert_text);
    mixin ForwardGtkOsCFunc!(.gtk_combo_box_remove_text);
    mixin ForwardGtkOsCFunc!(.gtk_combo_box_get_active);
    mixin ForwardGtkOsCFunc!(.gtk_combo_box_get_model);
    mixin ForwardGtkOsCFunc!(.gtk_combo_box_set_active);
    mixin ForwardGtkOsCFunc!(.gtk_combo_box_popup);
    mixin ForwardGtkOsCFunc!(.gtk_combo_box_popdown);
    mixin ForwardGtkOsCFunc!(.gtk_container_add);
    mixin ForwardGtkOsCFunc!(.gtk_container_forall);
    mixin ForwardGtkOsCFunc!(.gtk_container_get_border_width);
    mixin ForwardGtkOsCFunc!(.gtk_container_get_children);
    mixin ForwardGtkOsCFunc!(.gtk_container_remove);
    mixin ForwardGtkOsCFunc!(.gtk_container_resize_children);
    mixin ForwardGtkOsCFunc!(.gtk_container_set_border_width);
    mixin ForwardGtkOsCFunc!(.gtk_dialog_add_button);
    mixin ForwardGtkOsCFunc!(.gtk_dialog_run);
    mixin ForwardGtkOsCFunc!(.gtk_drag_begin);
    mixin ForwardGtkOsCFunc!(.gtk_drag_check_threshold);
    mixin ForwardGtkOsCFunc!(.gtk_drag_dest_find_target);
    mixin ForwardGtkOsCFunc!(.gtk_drag_dest_set);
    mixin ForwardGtkOsCFunc!(.gtk_drag_dest_unset);
    mixin ForwardGtkOsCFunc!(.gtk_drag_finish);
    mixin ForwardGtkOsCFunc!(.gtk_drag_get_data);
    mixin ForwardGtkOsCFunc!(.gtk_drag_set_icon_pixbuf);
    mixin ForwardGtkOsCFunc!(.gtk_drawing_area_new);
    mixin ForwardGtkOsCFunc!(.gtk_editable_copy_clipboard);
    mixin ForwardGtkOsCFunc!(.gtk_editable_cut_clipboard);
    mixin ForwardGtkOsCFunc!(.gtk_editable_delete_selection);
    mixin ForwardGtkOsCFunc!(.gtk_editable_delete_text);
    mixin ForwardGtkOsCFunc!(.gtk_editable_get_chars);
    mixin ForwardGtkOsCFunc!(.gtk_editable_get_editable);
    mixin ForwardGtkOsCFunc!(.gtk_editable_get_position);
    mixin ForwardGtkOsCFunc!(.gtk_editable_get_selection_bounds);
    mixin ForwardGtkOsCFunc!(.gtk_editable_insert_text);
    mixin ForwardGtkOsCFunc!(.gtk_editable_paste_clipboard);
    mixin ForwardGtkOsCFunc!(.gtk_editable_select_region);
    mixin ForwardGtkOsCFunc!(.gtk_editable_set_editable);
    mixin ForwardGtkOsCFunc!(.gtk_editable_set_position);
    mixin ForwardGtkOsCFunc!(.gtk_entry_get_invisible_char);
    mixin ForwardGtkOsCFunc!(.gtk_entry_get_layout );
    mixin ForwardGtkOsCFunc!(.gtk_entry_get_layout_offsets );
    mixin ForwardGtkOsCFunc!(.gtk_entry_text_index_to_layout_index );
    mixin ForwardGtkOsCFunc!(.gtk_entry_get_max_length);
    mixin ForwardGtkOsCFunc!(.gtk_entry_get_text);
    mixin ForwardGtkOsCFunc!(.FcConfigAppFontAddFile);
    mixin ForwardGtkOsCFunc!(.gtk_entry_get_visibility);
    mixin ForwardGtkOsCFunc!(.gtk_entry_new);
    mixin ForwardGtkOsCFunc!(.gtk_entry_set_activates_default);
    mixin ForwardGtkOsCFunc!(.gtk_entry_set_alignment);
    mixin ForwardGtkOsCFunc!(.gtk_entry_set_has_frame);
    mixin ForwardGtkOsCFunc!(.gtk_entry_set_invisible_char);
    mixin ForwardGtkOsCFunc!(.gtk_entry_set_max_length);
    mixin ForwardGtkOsCFunc!(.gtk_entry_set_text);
    mixin ForwardGtkOsCFunc!(.gtk_entry_set_visibility);

    mixin ForwardGtkOsCFunc!(.gtk_events_pending);
    mixin ForwardGtkOsCFunc!(.gtk_expander_get_expanded);
    mixin ForwardGtkOsCFunc!(.gtk_expander_get_label_widget);
    mixin ForwardGtkOsCFunc!(.gtk_expander_new);
    mixin ForwardGtkOsCFunc!(.gtk_expander_set_expanded);
    mixin ForwardGtkOsCFunc!(.gtk_expander_set_label);
    mixin ForwardGtkOsCFunc!(.gtk_expander_set_label_widget);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_add_filter);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_dialog_new2);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_get_current_folder);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_get_filename);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_get_filenames);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_get_filter);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_set_current_folder);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_set_current_name);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_set_do_overwrite_confirmation);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_set_extra_widget);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_set_filename);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_set_filter);
    mixin ForwardGtkOsCFunc!(.gtk_file_chooser_set_select_multiple);
    mixin ForwardGtkOsCFunc!(.gtk_file_filter_add_pattern);
    mixin ForwardGtkOsCFunc!(.gtk_file_filter_new);
    mixin ForwardGtkOsCFunc!(.gtk_file_filter_get_name);
    mixin ForwardGtkOsCFunc!(.gtk_file_filter_set_name);
    mixin ForwardGtkOsCFunc!(.gtk_file_selection_get_filename);
    mixin ForwardGtkOsCFunc!(.gtk_file_selection_get_selections);
    mixin ForwardGtkOsCFunc!(.gtk_file_selection_hide_fileop_buttons);
    mixin ForwardGtkOsCFunc!(.gtk_file_selection_new);
    mixin ForwardGtkOsCFunc!(.gtk_file_selection_set_filename);
    mixin ForwardGtkOsCFunc!(.gtk_file_selection_set_select_multiple);
    mixin ForwardGtkOsCFunc!(.gtk_fixed_move);
    mixin ForwardGtkOsCFunc!(.gtk_fixed_new);
    mixin ForwardGtkOsCFunc!(.gtk_fixed_set_has_window);
    mixin ForwardGtkOsCFunc!(.gtk_font_selection_dialog_get_font_name);
    mixin ForwardGtkOsCFunc!(.gtk_font_selection_dialog_new);
    mixin ForwardGtkOsCFunc!(.gtk_font_selection_dialog_set_font_name);
    mixin ForwardGtkOsCFunc!(.gtk_frame_new);
    mixin ForwardGtkOsCFunc!(.gtk_frame_get_label_widget);
    mixin ForwardGtkOsCFunc!(.gtk_frame_set_label);
    mixin ForwardGtkOsCFunc!(.gtk_frame_set_label_widget);
    mixin ForwardGtkOsCFunc!(.gtk_frame_set_shadow_type);
    mixin ForwardGtkOsCFunc!(.gtk_get_current_event);
    mixin ForwardGtkOsCFunc!(.gtk_get_current_event_state );
    mixin ForwardGtkOsCFunc!(.gtk_get_current_event_time);
    mixin ForwardGtkOsCFunc!(.gtk_get_default_language);
    mixin ForwardGtkOsCFunc!(.gtk_get_event_widget);
    mixin ForwardGtkOsCFunc!(.gtk_grab_add);
    mixin ForwardGtkOsCFunc!(.gtk_grab_get_current);
    mixin ForwardGtkOsCFunc!(.gtk_grab_remove);
    mixin ForwardGtkOsCFunc!(.gtk_hbox_new);
    mixin ForwardGtkOsCFunc!(.gtk_hscale_new);
    mixin ForwardGtkOsCFunc!(.gtk_hscrollbar_new);
    mixin ForwardGtkOsCFunc!(.gtk_hseparator_new);
    mixin ForwardGtkOsCFunc!(.gtk_icon_factory_lookup_default);
    mixin ForwardGtkOsCFunc!(.gtk_icon_source_free);
    mixin ForwardGtkOsCFunc!(.gtk_icon_source_new);
    mixin ForwardGtkOsCFunc!(.gtk_icon_source_set_pixbuf);
    mixin ForwardGtkOsCFunc!(.gtk_icon_set_render_icon);
    mixin ForwardGtkOsCFunc!(.gtk_im_context_filter_keypress);
    mixin ForwardGtkOsCFunc!(.gtk_im_context_focus_in);
    mixin ForwardGtkOsCFunc!(.gtk_im_context_focus_out);
    mixin ForwardGtkOsCFunc!(.gtk_im_context_get_preedit_string);
    mixin ForwardGtkOsCFunc!(.gtk_im_context_get_type);
    mixin ForwardGtkOsCFunc!(.gtk_im_context_reset);
    mixin ForwardGtkOsCFunc!(.gtk_im_context_set_client_window);
    mixin ForwardGtkOsCFunc!(.gtk_im_context_set_cursor_location);
    mixin ForwardGtkOsCFunc!(.gtk_im_multicontext_append_menuitems );
    mixin ForwardGtkOsCFunc!(.gtk_im_multicontext_new);
    mixin ForwardGtkOsCFunc!(.gtk_image_menu_item_new_with_label);
    mixin ForwardGtkOsCFunc!(.gtk_image_menu_item_set_image);
    mixin ForwardGtkOsCFunc!(.gtk_image_new);
    mixin ForwardGtkOsCFunc!(.gtk_image_new_from_pixbuf);
    mixin ForwardGtkOsCFunc!(.gtk_image_new_from_pixmap);
    mixin ForwardGtkOsCFunc!(.gtk_image_set_from_pixbuf);
    mixin ForwardGtkOsCFunc!(.gtk_image_set_from_pixmap);
    mixin ForwardGtkOsCFunc!(.gtk_init_check);
    mixin ForwardGtkOsCFunc!(.gtk_label_get_layout);
    mixin ForwardGtkOsCFunc!(.gtk_label_get_mnemonic_keyval);
    mixin ForwardGtkOsCFunc!(.gtk_label_new);
    mixin ForwardGtkOsCFunc!(.gtk_label_new_with_mnemonic);
    mixin ForwardGtkOsCFunc!(.gtk_label_set_attributes);
    mixin ForwardGtkOsCFunc!(.gtk_label_set_justify);
    mixin ForwardGtkOsCFunc!(.gtk_label_set_line_wrap);
    mixin ForwardGtkOsCFunc!(.gtk_label_set_line_wrap_mode);
    mixin ForwardGtkOsCFunc!(.gtk_label_set_text);
    mixin ForwardGtkOsCFunc!(.gtk_label_set_text_with_mnemonic);
    mixin ForwardGtkOsCFunc!(.gtk_list_append_items);
    mixin ForwardGtkOsCFunc!(.gtk_list_clear_items);
    mixin ForwardGtkOsCFunc!(.gtk_list_insert_items);
    mixin ForwardGtkOsCFunc!(.gtk_list_item_new_with_label);
    mixin ForwardGtkOsCFunc!(.gtk_list_remove_items);
    mixin ForwardGtkOsCFunc!(.gtk_list_select_item);
    mixin ForwardGtkOsCFunc!(.gtk_list_unselect_all);
    mixin ForwardGtkOsCFunc!(.gtk_list_unselect_item);
    mixin ForwardGtkOsCFunc!(.gtk_list_store_append);
    mixin ForwardGtkOsCFunc!(.gtk_list_store_clear);
    mixin ForwardGtkOsCFunc!(.gtk_list_store_insert);
    mixin ForwardGtkOsCFunc!(.gtk_list_store_newv);
    mixin ForwardGtkOsCFunc!(.gtk_list_store_remove);
    mixin ForwardGtkOsCFunc!(.gtk_list_store_set1);
    mixin ForwardGtkOsCFunc!(.gtk_main);
    mixin ForwardGtkOsCFunc!(.gtk_main_iteration);
    mixin ForwardGtkOsCFunc!(.gtk_main_do_event);
    mixin ForwardGtkOsCFunc!(.gtk_menu_bar_new);
    mixin ForwardGtkOsCFunc!(.gtk_menu_item_remove_submenu);
    mixin ForwardGtkOsCFunc!(.gtk_menu_item_get_submenu);
    mixin ForwardGtkOsCFunc!(.gtk_menu_item_set_submenu);
    mixin ForwardGtkOsCFunc!(.gtk_menu_new);
    mixin ForwardGtkOsCFunc!(.gtk_menu_popdown);
    mixin ForwardGtkOsCFunc!(.gtk_menu_popup);
    mixin ForwardGtkOsCFunc!(.gtk_menu_shell_deactivate);
    mixin ForwardGtkOsCFunc!(.gtk_menu_shell_insert);
    mixin ForwardGtkOsCFunc!(.gtk_menu_shell_select_item);
    mixin ForwardGtkOsCFunc!(.gtk_menu_shell_set_take_focus);
    mixin ForwardGtkOsCFunc!(.gtk_message_dialog_new);
    mixin ForwardGtkOsCFunc!(.gtk_misc_set_alignment);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_get_current_page);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_get_scrollable);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_insert_page);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_new);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_next_page);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_prev_page);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_remove_page);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_set_current_page);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_set_scrollable);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_set_show_tabs);
    mixin ForwardGtkOsCFunc!(.gtk_notebook_set_tab_pos);
    mixin ForwardGtkOsCFunc!(.gtk_object_sink);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_new );
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_get_orientation);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_set_orientation);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_get_paper_size);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_set_paper_size);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_get_top_margin);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_set_top_margin);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_get_bottom_margin);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_set_bottom_margin);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_get_left_margin);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_set_left_margin);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_get_right_margin);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_set_right_margin);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_get_paper_width);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_get_paper_height);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_get_page_width);
    mixin ForwardGtkOsCFunc!(.gtk_page_setup_get_page_height);
    mixin ForwardGtkOsCFunc!(.gtk_paint_handle);
    mixin ForwardGtkOsCFunc!(.gtk_paint_flat_box);
    mixin ForwardGtkOsCFunc!(.gtk_paint_focus);
    mixin ForwardGtkOsCFunc!(.gtk_paint_option);
    mixin ForwardGtkOsCFunc!(.gtk_paint_slider);
    mixin ForwardGtkOsCFunc!(.gtk_paint_tab);
    mixin ForwardGtkOsCFunc!(.gtk_paint_arrow);
    mixin ForwardGtkOsCFunc!(.gtk_paint_box);
    mixin ForwardGtkOsCFunc!(.gtk_paint_box_gap);
    mixin ForwardGtkOsCFunc!(.gtk_paint_check);
    mixin ForwardGtkOsCFunc!(.gtk_paint_expander);
    mixin ForwardGtkOsCFunc!(.gtk_paint_extension);
    mixin ForwardGtkOsCFunc!(.gtk_paint_hline);
    mixin ForwardGtkOsCFunc!(.gtk_paint_layout);
    mixin ForwardGtkOsCFunc!(.gtk_paint_shadow_gap);
    mixin ForwardGtkOsCFunc!(.gtk_paint_shadow);
    mixin ForwardGtkOsCFunc!(.gtk_paint_vline);
    mixin ForwardGtkOsCFunc!(.gtk_paper_size_new);
    mixin ForwardGtkOsCFunc!(.gtk_paper_size_new_from_ppd);
    mixin ForwardGtkOsCFunc!(.gtk_paper_size_new_custom);
    mixin ForwardGtkOsCFunc!(.gtk_paper_size_get_name);
    mixin ForwardGtkOsCFunc!(.gtk_paper_size_get_display_name);
    mixin ForwardGtkOsCFunc!(.gtk_paper_size_get_ppd_name);
    mixin ForwardGtkOsCFunc!(.gtk_paper_size_get_width);
    mixin ForwardGtkOsCFunc!(.gtk_paper_size_get_height);
    mixin ForwardGtkOsCFunc!(.gtk_paper_size_is_custom);
    mixin ForwardGtkOsCFunc!(.gtk_paper_size_free);
    mixin ForwardGtkOsCFunc!(.gtk_plug_get_id);
    mixin ForwardGtkOsCFunc!(.gtk_plug_new);
    mixin ForwardGtkOsCFunc!(.gtk_printer_get_backend);
    mixin ForwardGtkOsCFunc!(.gtk_printer_get_name);
    mixin ForwardGtkOsCFunc!(.gtk_printer_is_default);
    mixin ForwardGtkOsCFunc!(.gtk_enumerate_printers);
    mixin ForwardGtkOsCFunc!(.gtk_print_job_new);
    mixin ForwardGtkOsCFunc!(.gtk_print_job_get_settings);
    mixin ForwardGtkOsCFunc!(.gtk_print_job_get_printer);
    mixin ForwardGtkOsCFunc!(.gtk_print_job_get_title);
    mixin ForwardGtkOsCFunc!(.gtk_print_job_get_status);
    mixin ForwardGtkOsCFunc!(.gtk_print_job_set_source_file);
    mixin ForwardGtkOsCFunc!(.gtk_print_job_get_surface);
    mixin ForwardGtkOsCFunc!(.gtk_print_job_send);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_new);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_foreach);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_get);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_set);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_get_printer);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_set_printer);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_get_orientation);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_set_orientation);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_get_collate);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_set_collate);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_get_n_copies);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_set_n_copies);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_get_print_pages);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_set_print_pages);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_get_page_ranges);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_set_page_ranges);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_get_paper_width);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_get_paper_height);
    mixin ForwardGtkOsCFunc!(.gtk_print_settings_get_resolution);
    mixin ForwardGtkOsCFunc!(.gtk_print_unix_dialog_new);
    mixin ForwardGtkOsCFunc!(.gtk_print_unix_dialog_set_page_setup);
    mixin ForwardGtkOsCFunc!(.gtk_print_unix_dialog_get_page_setup);
    mixin ForwardGtkOsCFunc!(.gtk_print_unix_dialog_set_current_page);
    mixin ForwardGtkOsCFunc!(.gtk_print_unix_dialog_get_current_page);
    mixin ForwardGtkOsCFunc!(.gtk_print_unix_dialog_set_settings);
    mixin ForwardGtkOsCFunc!(.gtk_print_unix_dialog_get_settings);
    mixin ForwardGtkOsCFunc!(.gtk_print_unix_dialog_get_selected_printer);
    mixin ForwardGtkOsCFunc!(.gtk_print_unix_dialog_set_manual_capabilities);
    mixin ForwardGtkOsCFunc!(.gtk_progress_bar_new);
    mixin ForwardGtkOsCFunc!(.gtk_progress_bar_pulse);
    mixin ForwardGtkOsCFunc!(.gtk_progress_bar_set_fraction);
    mixin ForwardGtkOsCFunc!(.gtk_progress_bar_set_orientation);
    mixin ForwardGtkOsCFunc!(.gtk_radio_button_get_group);
    mixin ForwardGtkOsCFunc!(.gtk_radio_button_new);
    mixin ForwardGtkOsCFunc!(.gtk_radio_menu_item_get_group);
    mixin ForwardGtkOsCFunc!(.gtk_radio_menu_item_new);
    mixin ForwardGtkOsCFunc!(.gtk_radio_menu_item_new_with_label);
    mixin ForwardGtkOsCFunc!(.gtk_range_get_adjustment);
    mixin ForwardGtkOsCFunc!(.gtk_range_set_increments);
    mixin ForwardGtkOsCFunc!(.gtk_range_set_inverted);
    mixin ForwardGtkOsCFunc!(.gtk_range_set_range);
    mixin ForwardGtkOsCFunc!(.gtk_range_set_value);
    mixin ForwardGtkOsCFunc!(.gtk_rc_parse_string);
//    mixin ForwardGtkOsCFunc!(.gtk_rc_style_get_bg_pixmap_name);
//    mixin ForwardGtkOsCFunc!(.gtk_rc_style_get_color_flags);
//    mixin ForwardGtkOsCFunc!(.gtk_rc_style_set_bg);
//    mixin ForwardGtkOsCFunc!(.gtk_rc_style_set_bg_pixmap_name);
//    mixin ForwardGtkOsCFunc!(.gtk_rc_style_set_color_flags);
    mixin ForwardGtkOsCFunc!(.gtk_scale_set_digits);
    mixin ForwardGtkOsCFunc!(.gtk_scale_set_draw_value);
//    mixin ForwardGtkOsCFunc!(.gtk_rc_style_set_fg);
//    mixin ForwardGtkOsCFunc!(.gtk_rc_style_set_text);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_add_with_viewport);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_get_hadjustment);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_get_policy);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_get_shadow_type);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_get_vadjustment);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_new);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_set_placement);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_set_policy);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_set_shadow_type);
    mixin ForwardGtkOsCFunc!(.gtk_settings_get_default);
    mixin ForwardGtkOsCFunc!(.gtk_selection_data_free);
    mixin ForwardGtkOsCFunc!(.gtk_selection_data_set);
    mixin ForwardGtkOsCFunc!(.gtk_separator_menu_item_new);
    mixin ForwardGtkOsCFunc!(.gtk_set_locale);
    mixin ForwardGtkOsCFunc!(.gtk_socket_get_id);
    mixin ForwardGtkOsCFunc!(.gtk_socket_new);
    mixin ForwardGtkOsCFunc!(.gtk_spin_button_new);
    mixin ForwardGtkOsCFunc!(.gtk_spin_button_get_adjustment);
    mixin ForwardGtkOsCFunc!(.gtk_spin_button_get_digits);
    mixin ForwardGtkOsCFunc!(.gtk_spin_button_set_digits);
    mixin ForwardGtkOsCFunc!(.gtk_spin_button_set_increments);
    mixin ForwardGtkOsCFunc!(.gtk_spin_button_set_range);
    mixin ForwardGtkOsCFunc!(.gtk_spin_button_set_value);
    mixin ForwardGtkOsCFunc!(.gtk_spin_button_set_wrap);
    mixin ForwardGtkOsCFunc!(.gtk_spin_button_update);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_base);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_black);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_bg);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_dark);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_fg);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_fg_gc);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_bg_gc);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_light_gc);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_dark_gc);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_mid_gc);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_text_gc);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_text_aa_gc);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_black_gc);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_white_gc);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_font_desc);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_light);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_text);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_xthickness);
//    mixin ForwardGtkOsCFunc!(.gtk_style_get_ythickness);
    mixin ForwardGtkOsCFunc!(.gtk_style_render_icon);
    mixin ForwardGtkOsCFunc!(.gtk_target_list_new);
    mixin ForwardGtkOsCFunc!(.gtk_target_list_unref);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_copy_clipboard);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_cut_clipboard);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_delete);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_bounds);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_char_count);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_end_iter);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_insert);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_iter_at_line);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_iter_at_mark);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_iter_at_offset);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_line_count);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_selection_bound);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_selection_bounds);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_get_text);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_insert);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_move_mark);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_paste_clipboard);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_place_cursor);
    mixin ForwardGtkOsCFunc!(.gtk_text_buffer_set_text);
    mixin ForwardGtkOsCFunc!(.gtk_text_iter_get_line);
    mixin ForwardGtkOsCFunc!(.gtk_text_iter_get_offset);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_buffer_to_window_coords);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_get_buffer);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_get_editable);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_get_iter_at_location);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_get_iter_location);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_get_line_at_y);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_get_visible_rect);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_get_window);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_new);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_scroll_mark_onscreen);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_scroll_to_iter);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_set_editable);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_set_justification);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_set_tabs);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_set_wrap_mode);
    mixin ForwardGtkOsCFunc!(.gtk_text_view_window_to_buffer_coords);
    mixin ForwardGtkOsCFunc!(.gtk_timeout_add);
    mixin ForwardGtkOsCFunc!(.gtk_timeout_remove);
    mixin ForwardGtkOsCFunc!(.gtk_toggle_button_get_active);
    mixin ForwardGtkOsCFunc!(.gtk_toggle_button_new);
    mixin ForwardGtkOsCFunc!(.gtk_toggle_button_get_inconsistent);
    mixin ForwardGtkOsCFunc!(.gtk_toggle_button_set_active);
    mixin ForwardGtkOsCFunc!(.gtk_toggle_button_set_inconsistent);
    mixin ForwardGtkOsCFunc!(.gtk_toggle_button_set_mode);
    mixin ForwardGtkOsCFunc!(.gtk_toolbar_insert_widget);
    mixin ForwardGtkOsCFunc!(.gtk_toolbar_new);
    mixin ForwardGtkOsCFunc!(.gtk_toolbar_set_orientation);
    mixin ForwardGtkOsCFunc!(.gtk_tooltips_data_get);
    mixin ForwardGtkOsCFunc!(.gtk_tooltips_disable);
    mixin ForwardGtkOsCFunc!(.gtk_tooltips_enable);
    mixin ForwardGtkOsCFunc!(.gtk_tooltips_new);
    mixin ForwardGtkOsCFunc!(.gtk_tooltips_force_window);
    mixin ForwardGtkOsCFunc!(.gtk_tooltips_set_tip);
    mixin ForwardGtkOsCFunc!(.gtk_tree_model_get1);
    mixin ForwardGtkOsCFunc!(.gtk_tree_model_get_iter);
    mixin ForwardGtkOsCFunc!(.gtk_tree_model_get_iter_first);
    mixin ForwardGtkOsCFunc!(.gtk_tree_model_get_n_columns);
    mixin ForwardGtkOsCFunc!(.gtk_tree_model_get_path);
    mixin ForwardGtkOsCFunc!(.gtk_tree_model_get_type);
    mixin ForwardGtkOsCFunc!(.gtk_tree_model_iter_children);
    mixin ForwardGtkOsCFunc!(.gtk_tree_model_iter_n_children);
    mixin ForwardGtkOsCFunc!(.gtk_tree_model_iter_next);
    mixin ForwardGtkOsCFunc!(.gtk_tree_model_iter_nth_child);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_append_index);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_compare);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_down);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_free);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_get_depth);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_get_indices);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_new);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_new_first);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_new_from_string);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_next);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_prev);
    mixin ForwardGtkOsCFunc!(.gtk_tree_path_up);
    mixin ForwardGtkOsCFunc!(.gtk_tree_selection_count_selected_rows);
    mixin ForwardGtkOsCFunc!(.gtk_tree_selection_get_selected);
    mixin ForwardGtkOsCFunc!(.gtk_tree_selection_get_selected_rows);
    mixin ForwardGtkOsCFunc!(.gtk_tree_selection_path_is_selected);
    mixin ForwardGtkOsCFunc!(.gtk_tree_selection_select_all);
    mixin ForwardGtkOsCFunc!(.gtk_tree_selection_select_iter);
    mixin ForwardGtkOsCFunc!(.gtk_tree_selection_selected_foreach);
    mixin ForwardGtkOsCFunc!(.gtk_tree_selection_set_mode);
    mixin ForwardGtkOsCFunc!(.gtk_tree_selection_unselect_all);
    mixin ForwardGtkOsCFunc!(.gtk_tree_selection_unselect_iter);
    mixin ForwardGtkOsCFunc!(.gtk_tree_store_append);
    mixin ForwardGtkOsCFunc!(.gtk_tree_store_clear);
    mixin ForwardGtkOsCFunc!(.gtk_tree_store_insert);
    mixin ForwardGtkOsCFunc!(.gtk_tree_store_newv);
    mixin ForwardGtkOsCFunc!(.gtk_tree_store_remove);
    mixin ForwardGtkOsCFunc!(.gtk_tree_store_set1);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_create_row_drag_icon);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_collapse_row);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_add_attribute);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_cell_get_position);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_cell_get_size);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_cell_set_cell_data);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_clear);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_get_cell_renderers);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_get_fixed_width);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_get_reorderable);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_get_resizable);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_get_sizing);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_get_spacing);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_get_visible);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_get_sort_indicator);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_get_sort_order);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_get_width);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_new);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_pack_start);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_pack_end);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_alignment);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_cell_data_func);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_clickable);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_fixed_width);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_min_width);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_reorderable);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_resizable);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_sizing);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_sort_indicator);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_sort_order);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_title);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_visible );
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_column_set_widget);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_set_drag_dest_row);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_set_enable_search );
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_expand_row);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_background_area);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_bin_window);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_cell_area);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_expander_column);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_column);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_columns);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_cursor);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_headers_visible);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_path_at_pos);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_rules_hint);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_selection);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_get_visible_rect);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_insert_column);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_move_column_after);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_new_with_model);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_remove_column);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_row_expanded);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_scroll_to_cell);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_scroll_to_point );
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_set_cursor);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_set_headers_visible);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_set_model);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_set_rules_hint);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_set_search_column);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_tree_to_widget_coords);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_unset_rows_drag_dest);
    mixin ForwardGtkOsCFunc!(.gtk_tree_view_widget_to_tree_coords);
    mixin ForwardGtkOsCFunc!(.gtk_vbox_new);
    mixin ForwardGtkOsCFunc!(.gtk_vscale_new);
    mixin ForwardGtkOsCFunc!(.gtk_vscrollbar_new);
    mixin ForwardGtkOsCFunc!(.gtk_vseparator_new);
    mixin ForwardGtkOsCFunc!(.gtk_widget_add_accelerator);
    mixin ForwardGtkOsCFunc!(.gtk_widget_add_events);
    mixin ForwardGtkOsCFunc!(.gtk_widget_child_focus);
    mixin ForwardGtkOsCFunc!(.gtk_widget_create_pango_layout);
    mixin ForwardGtkOsCFunc!(.gtk_widget_destroy);
    mixin ForwardGtkOsCFunc!(.gtk_widget_event);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_accessible );
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_child_visible );
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_default_direction);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_default_style);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_direction);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_events);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_modifier_style);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_pango_context);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_parent);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_style);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_size_request);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_toplevel );
    mixin ForwardGtkOsCFunc!(.gtk_widget_grab_focus);
    mixin ForwardGtkOsCFunc!(.gtk_widget_hide);
    mixin ForwardGtkOsCFunc!(.gtk_widget_is_composited);
    mixin ForwardGtkOsCFunc!(.gtk_widget_is_focus);
    mixin ForwardGtkOsCFunc!(.gtk_widget_map);
    mixin ForwardGtkOsCFunc!(.gtk_widget_mnemonic_activate);
    mixin ForwardGtkOsCFunc!(.gtk_widget_modify_base);
    mixin ForwardGtkOsCFunc!(.gtk_widget_modify_bg);
    mixin ForwardGtkOsCFunc!(.gtk_widget_modify_fg);
    mixin ForwardGtkOsCFunc!(.gtk_widget_modify_font);
    mixin ForwardGtkOsCFunc!(.gtk_widget_modify_style);
    mixin ForwardGtkOsCFunc!(.gtk_widget_modify_text);
    mixin ForwardGtkOsCFunc!(.gtk_widget_queue_resize);
    mixin ForwardGtkOsCFunc!(.gtk_widget_realize);
    mixin ForwardGtkOsCFunc!(.gtk_widget_remove_accelerator);
    mixin ForwardGtkOsCFunc!(.gtk_widget_reparent);
    mixin ForwardGtkOsCFunc!(.gtk_widget_send_expose);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_app_paintable);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_default_direction);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_direction);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_double_buffered);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_name);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_redraw_on_allocate);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_sensitive);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_size_request);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_state);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_style);
    mixin ForwardGtkOsCFunc!(.gtk_widget_shape_combine_mask);
    mixin ForwardGtkOsCFunc!(.gtk_widget_show);
    mixin ForwardGtkOsCFunc!(.gtk_widget_show_now);
    mixin ForwardGtkOsCFunc!(.gtk_widget_size_allocate);
    mixin ForwardGtkOsCFunc!(.gtk_widget_size_request);
    mixin ForwardGtkOsCFunc!(.gtk_widget_style_get1); // 1=get one property, see above
    mixin ForwardGtkOsCFunc!(.gtk_widget_translate_coordinates);
    mixin ForwardGtkOsCFunc!(.gtk_widget_unrealize);
    mixin ForwardGtkOsCFunc!(.gtk_window_activate_default);
    mixin ForwardGtkOsCFunc!(.gtk_window_add_accel_group);
    mixin ForwardGtkOsCFunc!(.gtk_window_deiconify);
    mixin ForwardGtkOsCFunc!(.gtk_window_get_focus);
    mixin ForwardGtkOsCFunc!(.gtk_window_get_group);
    mixin ForwardGtkOsCFunc!(.gtk_window_get_icon_list);
    mixin ForwardGtkOsCFunc!(.gtk_window_get_modal);
    mixin ForwardGtkOsCFunc!(.gtk_window_get_mnemonic_modifier);
    mixin ForwardGtkOsCFunc!(.gtk_window_get_opacity);
    mixin ForwardGtkOsCFunc!(.gtk_window_get_position);
    mixin ForwardGtkOsCFunc!(.gtk_window_get_size);
    mixin ForwardGtkOsCFunc!(.gtk_window_group_add_window);
    mixin ForwardGtkOsCFunc!(.gtk_window_group_remove_window);
    mixin ForwardGtkOsCFunc!(.gtk_window_group_new);
    mixin ForwardGtkOsCFunc!(.gtk_window_iconify);
    mixin ForwardGtkOsCFunc!(.gtk_window_list_toplevels);
    mixin ForwardGtkOsCFunc!(.gtk_window_maximize);
    mixin ForwardGtkOsCFunc!(.gtk_window_fullscreen);
    mixin ForwardGtkOsCFunc!(.gtk_window_unfullscreen);
    mixin ForwardGtkOsCFunc!(.gtk_window_move);
    mixin ForwardGtkOsCFunc!(.gtk_window_new);
    mixin ForwardGtkOsCFunc!(.gtk_window_present);
    mixin ForwardGtkOsCFunc!(.gtk_window_remove_accel_group);
    mixin ForwardGtkOsCFunc!(.gtk_window_resize);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_default);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_destroy_with_parent);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_keep_below);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_geometry_hints);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_icon_list);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_modal);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_opacity);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_tooltip_text);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_parent_window);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_resizable);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_title);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_skip_taskbar_hint);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_type_hint);
    mixin ForwardGtkOsCFunc!(.gtk_window_set_transient_for);
    mixin ForwardGtkOsCFunc!(.gtk_window_unmaximize);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_window);
    mixin ForwardGtkOsCFunc!(.gtk_widget_get_allocation);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_allocation);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_get_hscrollbar);
    mixin ForwardGtkOsCFunc!(.gtk_scrolled_window_get_vscrollbar);
    mixin ForwardGtkOsCFunc!(.gtk_widget_set_tooltip_window);
    mixin ForwardGtkOsCFunc!(.pango_attr_background_new );
    mixin ForwardGtkOsCFunc!(.pango_attr_font_desc_new);
    mixin ForwardGtkOsCFunc!(.pango_attr_foreground_new );
    mixin ForwardGtkOsCFunc!(.pango_attr_rise_new);
    mixin ForwardGtkOsCFunc!(.pango_attr_shape_new);
    mixin ForwardGtkOsCFunc!(.pango_attr_list_insert);
    mixin ForwardGtkOsCFunc!(.pango_attr_list_change);
    mixin ForwardGtkOsCFunc!(.pango_attr_list_get_iterator);
    mixin ForwardGtkOsCFunc!(.pango_attr_iterator_next);
    mixin ForwardGtkOsCFunc!(.pango_attr_iterator_range);
    mixin ForwardGtkOsCFunc!(.pango_attr_iterator_get);
    mixin ForwardGtkOsCFunc!(.pango_attr_iterator_get_attrs);
    mixin ForwardGtkOsCFunc!(.pango_attr_iterator_destroy);
    mixin ForwardGtkOsCFunc!(.pango_attr_list_new);
    mixin ForwardGtkOsCFunc!(.pango_attr_list_unref);
    mixin ForwardGtkOsCFunc!(.pango_attr_strikethrough_color_new);
    mixin ForwardGtkOsCFunc!(.pango_attr_strikethrough_new);
    mixin ForwardGtkOsCFunc!(.pango_attr_underline_color_new);
    mixin ForwardGtkOsCFunc!(.pango_attr_underline_new);
    mixin ForwardGtkOsCFunc!(.pango_attr_weight_new);
//    mixin ForwardGtkOsCFunc!(.pango_cairo_font_map_get_default);
//    mixin ForwardGtkOsCFunc!(.pango_cairo_font_map_new);
//    mixin ForwardGtkOsCFunc!(.pango_cairo_font_map_create_context);
    mixin ForwardGtkOsCFunc!(.pango_cairo_create_layout);
    mixin ForwardGtkOsCFunc!(.pango_cairo_context_get_font_options);
    mixin ForwardGtkOsCFunc!(.pango_cairo_context_set_font_options);
//    mixin ForwardGtkOsCFunc!(.pango_cairo_font_map_set_resolution);
    mixin ForwardGtkOsCFunc!(.pango_cairo_layout_path);
    mixin ForwardGtkOsCFunc!(.pango_cairo_show_layout);
    mixin ForwardGtkOsCFunc!(.pango_context_get_base_dir);
    mixin ForwardGtkOsCFunc!(.pango_context_get_language);
    mixin ForwardGtkOsCFunc!(.pango_context_get_metrics);
    mixin ForwardGtkOsCFunc!(.pango_context_list_families);
    mixin ForwardGtkOsCFunc!(.pango_context_set_base_dir);
    mixin ForwardGtkOsCFunc!(.pango_context_set_language);
    mixin ForwardGtkOsCFunc!(.pango_font_description_copy);
    mixin ForwardGtkOsCFunc!(.pango_font_description_free);
    mixin ForwardGtkOsCFunc!(.pango_font_description_from_string);
    mixin ForwardGtkOsCFunc!(.pango_font_description_get_family);
    mixin ForwardGtkOsCFunc!(.pango_font_description_get_size);
    mixin ForwardGtkOsCFunc!(.pango_font_description_get_style);
    mixin ForwardGtkOsCFunc!(.pango_font_description_get_weight);
    mixin ForwardGtkOsCFunc!(.pango_font_description_new);
    mixin ForwardGtkOsCFunc!(.pango_font_description_set_family);
    mixin ForwardGtkOsCFunc!(.pango_font_description_set_size);
    mixin ForwardGtkOsCFunc!(.pango_font_description_set_stretch);
    mixin ForwardGtkOsCFunc!(.pango_font_description_set_style);
    mixin ForwardGtkOsCFunc!(.pango_font_description_set_weight);
    mixin ForwardGtkOsCFunc!(.pango_font_description_to_string);
    mixin ForwardGtkOsCFunc!(.pango_font_face_describe);
    mixin ForwardGtkOsCFunc!(.pango_font_family_get_name);
    mixin ForwardGtkOsCFunc!(.pango_font_family_list_faces);
    mixin ForwardGtkOsCFunc!(.pango_font_get_metrics);
    mixin ForwardGtkOsCFunc!(.pango_font_metrics_get_approximate_char_width);
    mixin ForwardGtkOsCFunc!(.pango_font_metrics_get_ascent);
    mixin ForwardGtkOsCFunc!(.pango_font_metrics_get_descent);
    mixin ForwardGtkOsCFunc!(.pango_font_metrics_get_underline_thickness);
    mixin ForwardGtkOsCFunc!(.pango_font_metrics_get_underline_position);
    mixin ForwardGtkOsCFunc!(.pango_font_metrics_get_strikethrough_thickness);
    mixin ForwardGtkOsCFunc!(.pango_font_metrics_get_strikethrough_position);
    mixin ForwardGtkOsCFunc!(.pango_font_metrics_unref);
    mixin ForwardGtkOsCFunc!(.pango_language_from_string);
    mixin ForwardGtkOsCFunc!(.pango_layout_context_changed);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_alignment);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_context);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_attributes);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_indent);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_iter);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_justify);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_line);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_line_count);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_log_attrs);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_size);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_spacing);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_tabs);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_text);
    mixin ForwardGtkOsCFunc!(.pango_layout_get_width);
    mixin ForwardGtkOsCFunc!(.pango_layout_index_to_pos);
    mixin ForwardGtkOsCFunc!(.pango_layout_iter_free);
    mixin ForwardGtkOsCFunc!(.pango_layout_iter_get_line_extents);
    mixin ForwardGtkOsCFunc!(.pango_layout_iter_get_index);
    mixin ForwardGtkOsCFunc!(.pango_layout_iter_get_run);
    mixin ForwardGtkOsCFunc!(.pango_layout_iter_next_line);
    mixin ForwardGtkOsCFunc!(.pango_layout_iter_next_run);
    mixin ForwardGtkOsCFunc!(.pango_layout_line_get_extents);
    mixin ForwardGtkOsCFunc!(.pango_layout_line_x_to_index);
    mixin ForwardGtkOsCFunc!(.pango_layout_new);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_alignment );
    mixin ForwardGtkOsCFunc!(.pango_layout_set_attributes);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_auto_dir);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_font_description);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_indent);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_justify);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_single_paragraph_mode);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_spacing);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_tabs);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_text);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_width);
    mixin ForwardGtkOsCFunc!(.pango_layout_set_wrap );
    mixin ForwardGtkOsCFunc!(.pango_layout_xy_to_index);
    mixin ForwardGtkOsCFunc!(.pango_tab_array_get_size);
    mixin ForwardGtkOsCFunc!(.pango_tab_array_get_tabs);
    mixin ForwardGtkOsCFunc!(.pango_tab_array_free);
    mixin ForwardGtkOsCFunc!(.pango_tab_array_new);
    mixin ForwardGtkOsCFunc!(.pango_tab_array_set_tab);
    mixin ForwardGtkOsCFunc!(.atk_object_add_relationship );

    /* Field accessors */

    public static guint pango_layout_line_get_resolved_dir( PangoLayoutLine* line ){
        return line.resolved_dir();
    }

    static void    GTK_ACCEL_LABEL_SET_ACCEL_STRING( void *arg0, gchar * arg1 )
            { (cast(GtkAccelLabel*)arg0).accel_string = arg1; }
    static gchar*  GTK_ACCEL_LABEL_GET_ACCEL_STRING( void* arg0)
            { return (cast(GtkAccelLabel*)arg0).accel_string; }

    static GtkWidget* GTK_SCROLLED_WINDOW_HSCROLLBAR( void* arg0 )
            { return (cast(GtkScrolledWindow*)arg0).hscrollbar; }
    static GtkWidget* GTK_SCROLLED_WINDOW_VSCROLLBAR( void* arg0 )
            { return (cast(GtkScrolledWindow*)arg0).vscrollbar; }

    static gint GTK_SCROLLED_WINDOW_SCROLLBAR_SPACING( void* arg0)
    {
        return   ((cast(GtkScrolledWindowClass*) ((cast(GTypeInstance*) arg0).g_class) ).scrollbar_spacing >= 0 ?
                  (cast(GtkScrolledWindowClass*) ((cast(GTypeInstance*) arg0).g_class)).scrollbar_spacing : 3) ;
    }

    static gint GTK_WIDGET_HEIGHT( void* arg0 )
         { return (cast(GtkWidget*)arg0).allocation.height; }
    static void GTK_WIDGET_SET_HEIGHT( void* arg0, gint arg1)
         { (cast(GtkWidget*)arg0).allocation.height = arg1; }
    static gint GTK_WIDGET_WIDTH( void* arg0)
         { return (cast(GtkWidget*)arg0).allocation.width; }
    static void GTK_WIDGET_SET_WIDTH( void* arg0, gint arg1)
         { (cast(GtkWidget*)arg0).allocation.width = arg1; }
    static GdkWindow* GTK_WIDGET_WINDOW( void* arg0)
         { return (cast(GtkWidget*)arg0).window; }
    static gint GTK_WIDGET_X( void* arg0 )
         { return (cast(GtkWidget*)arg0).allocation.x; }
    static void GTK_WIDGET_SET_X( void* arg0, gint arg1)
         { (cast(GtkWidget*)arg0).allocation.x = arg1; }
    static gint GTK_WIDGET_Y( void* arg0 )
         { return (cast(GtkWidget*)arg0).allocation.y; }
    static void GTK_WIDGET_SET_Y( void* arg0, gint arg1)
         { (cast(GtkWidget*)arg0).allocation.y = arg1; }
    static gint GTK_WIDGET_REQUISITION_WIDTH( void* arg0 )
         { return (cast(GtkWidget*)arg0).requisition.width; }
    static gint GTK_WIDGET_REQUISITION_HEIGHT( void* arg0 )
         { return (cast(GtkWidget*)arg0).requisition.height; }

    static GtkIMContext* GTK_ENTRY_IM_CONTEXT( void* arg0 )
         { return (cast(GtkEntry*)arg0).im_context; }

    static GtkIMContext* GTK_TEXTVIEW_IM_CONTEXT( void* arg0)
         { return (cast(GtkTextView*)arg0).im_context; }

    static GtkWidget* GTK_TOOLTIPS_TIP_WINDOW( void* arg0)
         { return (cast(GtkTooltips*)arg0).tip_window; }
    static void GTK_TOOLTIPS_SET_ACTIVE( void* arg0, void*  arg1 )
         { (cast(GtkTooltips*)arg0).active_tips_data = cast(GtkTooltipsData*)arg1; }

    static gint  GDK_EVENT_TYPE( void* arg0 )
         { return (cast(GdkEvent*)arg0).type; }
    static GdkWindow* GDK_EVENT_WINDOW( void* arg0 )
         { return (cast(GdkEventAny*)arg0).window; }
    static gint  X_EVENT_TYPE( void* arg0 )
         { return (cast(XEvent*)arg0).type; }
    //Window X_EVENT_WINDOW( XAnyEvent* arg0 )
    //     { return arg0.window; }

/+

    //gtk_rc_style_get_bg_pixmap_name(arg0, arg1) (arg0)->bg_pixmap_name[arg1]
    static char* gtk_rc_style_get_bg_pixmap_name( GtkRcStyle* arg0, int arg1 ) {
        return arg0.bg_pixmap_name[arg1];
    }
    //gtk_rc_style_get_color_flags(arg0, arg1) (arg0)->color_flags[arg1]
    static int gtk_rc_style_get_color_flags( GtkRcStyle* arg0, int arg1 ) {
        return arg0.color_flags[arg1];
    }
    //gtk_rc_style_set_bg(arg0, arg1, arg2) if (arg2) (arg0)->bg[arg1] = *arg2
    static void gtk_rc_style_set_bg( GtkRcStyle* arg0, int arg1, GdkColor* arg2 ) {
        if (arg2) arg0.bg[arg1] = *arg2;
    }
    //gtk_rc_style_set_bg_pixmap_name(arg0, arg1, arg2) (arg0)->bg_pixmap_name[arg1] = (char *)arg2
    static void gtk_rc_style_set_bg_pixmap_name( GtkRcStyle* arg0, int arg1, char* arg2 ) {
        arg0.bg_pixmap_name[arg1] = arg2;
    }

    //gtk_rc_style_set_color_flags(arg0, arg1, arg2) (arg0)->color_flags[arg1] = arg2
    static void gtk_rc_style_set_color_flags( GtkRcStyle* arg0, int arg1, int arg2 ) {
        arg0.color_flags[arg1] = arg2;
    }

    //gtk_rc_style_set_fg(arg0, arg1, arg2) if (arg2) (arg0)->fg[arg1] = *arg2
    static void gtk_rc_style_set_fg( GtkRcStyle* arg0, int arg1, GdkColor* arg2 ) {
        if (arg2) arg0.fg[arg1] = *arg2;
    }
    //gtk_rc_style_set_text(arg0, arg1, arg2) if (arg2) (arg0)->text[arg1] = *arg2
    static void gtk_rc_style_set_text( GtkRcStyle* arg0, int arg1, GdkColor* arg2 ) {
        if (arg2) arg0.text[arg1] = *arg2;
    }

    //gtk_style_get_font_desc(arg0) (arg0)->font_desc
    static PangoFontDescription* gtk_style_get_font_desc( GtkStyle* arg0 ) {
        return cast( PangoFontDescription* ) arg0.font_desc;
    }
    //gtk_style_get_base(arg0, arg1, arg2) *arg2 = (arg0)->base[arg1]
    static void gtk_style_get_base( GtkStyle* arg0, int arg1, GdkColor* arg2 ) {
        *arg2 = arg0.base[arg1];
    }
    //gtk_style_get_bg(arg0, arg1, arg2) *arg2 = (arg0)->bg[arg1]
    static void gtk_style_get_bg( GtkStyle* arg0, int arg1, GdkColor* arg2 ) {
        *arg2 = arg0.bg[arg1];
    }
    //gtk_style_get_black(arg0, arg1) *arg1 = (arg0)->black
    static void gtk_style_get_black( GtkStyle* arg0, GdkColor* arg1 ) {
        *arg1 = arg0.black;
    }
    //gtk_style_get_dark(arg0, arg1, arg2) *arg2 = (arg0)->dark[arg1]
    static void gtk_style_get_dark( GtkStyle* arg0, int arg1, GdkColor* arg2 ) {
        *arg2 = arg0.dark[arg1];
    }
    //gtk_style_get_fg(arg0, arg1, arg2) *arg2 = (arg0)->fg[arg1]
    static void gtk_style_get_fg( GtkStyle* arg0, int arg1, GdkColor* arg2 ) {
        *arg2 = arg0.fg[arg1];
    }
    //gtk_style_get_light(arg0, arg1, arg2) *arg2 = (arg0)->light[arg1]
    static void gtk_style_get_light( GtkStyle* arg0, int arg1, GdkColor* arg2 ) {
        *arg2 = arg0.light[arg1];
    }
    //gtk_style_get_text(arg0, arg1, arg2) *arg2 = (arg0)->text[arg1]
    static void gtk_style_get_text( GtkStyle* arg0, int arg1, GdkColor* arg2 ) {
        *arg2 = arg0.text[arg1];
    }

    //gtk_style_get_xthickness(arg0) (arg0)->xthickness
    static int gtk_style_get_xthickness( GtkStyle* arg0 ) {
        return arg0.xthickness;
    }
    //gtk_style_get_ythickness(arg0) (arg0)->ythickness
    static int gtk_style_get_ythickness( GtkStyle* arg0 ) {
        return arg0.ythickness;
    }
    +/
    /+
    gtk_style_get_fg_gc(arg0, arg1, arg2) *arg2 = (arg0)->fg_gc[arg1]
    gtk_style_get_bg_gc(arg0, arg1, arg2) *arg2 = (arg0)->bg_gc[arg1]
    gtk_style_get_light_gc(arg0, arg1, arg2) *arg2 = (arg0)->light_gc[arg1]
    gtk_style_get_dark_gc(arg0, arg1, arg2) *arg2 = (arg0)->dark_gc[arg1]
    gtk_style_get_mid_gc(arg0, arg1, arg2) *arg2 = (arg0)->mid_gc[arg1]
    gtk_style_get_text_gc(arg0, arg1, arg2) *arg2 = (arg0)->text_gc[arg1]
    gtk_style_get_text_aa_gc(arg0, arg1, arg2) *arg2 = (arg0)->text_aa_gc[arg1]
    gtk_style_get_black_gc(arg0, arg1) *arg1 = (arg0)->black_gc
    gtk_style_get_white_gc(arg0, arg1) *arg1 = (arg0)->white_gc

    localeconv_decimal_point() localeconv()->decimal_point
+/

   /**************************************************************************

        Utility methods -- conversions of gtk macros

    **************************************************************************/
    static gulong g_signal_connect( gpointer arg0, in gchar* arg1, GCallback arg2, gpointer arg3 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return g_signal_connect_data (arg0, arg1, arg2, arg3, null , cast(GConnectFlags) 0) ;
    }

    static gulong g_signal_connect_after( gpointer arg0, in gchar* arg1, GCallback arg2, gpointer arg3 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return g_signal_connect_data ( arg0, arg1, arg2, arg3, null, GConnectFlags.G_CONNECT_AFTER );
    }

    static GSList* g_slist_next( GSList* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return arg0 ? arg0.next : null;
    }

    static GList* g_list_next( GList* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return arg0 ? arg0.next : null;
    }

    static GList* g_list_previous( GList* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return arg0 ? arg0.prev : null;
    }

    static Display* GDK_DISPLAY()
    {
        lock.lock();
        scope(exit) lock.unlock();
        // gdk_display needs to be a reference to the an external X11 global
        // representing the current X11 display
        return gdk_display;
    }

    static GdkWindow* GDK_ROOT_PARENT()
    {
        lock.lock();
        scope(exit) lock.unlock;
        return gdk_get_default_root_window();
    }

    static GType GDK_TYPE_COLOR()
    {
        lock.lock();
        scope(exit) lock.unlock;
        return gdk_color_get_type();
    }

    static GType GDK_TYPE_PIXBUF()
    {
        lock.lock();
        scope(exit) lock.unlock;
        return gdk_pixbuf_get_type();
    }

    static bool GTK_IS_BUTTON( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return  cast(bool)g_type_check_instance_is_a( cast(GTypeInstance*)arg0, gtk_button_get_type() );
    }

    static bool GTK_IS_WINDOW( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return cast(bool)g_type_check_instance_is_a( cast(GTypeInstance*)arg0, gtk_window_get_type());
    }

    static bool GTK_IS_CELL_RENDERER_PIXBUF( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return cast(bool)g_type_check_instance_is_a( cast(GTypeInstance*)arg0, gtk_cell_renderer_pixbuf_get_type());
    }

    static bool GTK_IS_CELL_RENDERER_TEXT( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return cast(bool)g_type_check_instance_is_a( cast(GTypeInstance*)arg0, gtk_cell_renderer_text_get_type());
    }

    static bool GTK_IS_CELL_RENDERER_TOGGLE( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return cast(bool)g_type_check_instance_is_a( cast(GTypeInstance*)arg0, gtk_cell_renderer_toggle_get_type ());
    }

    static bool GTK_IS_CONTAINER( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return cast(bool)g_type_check_instance_is_a( cast(GTypeInstance*)arg0, gtk_container_get_type () );
    }


    static bool GTK_IS_IMAGE_MENU_ITEM( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return cast(bool)g_type_check_instance_is_a( cast(GTypeInstance*)arg0, gtk_image_menu_item_get_type ());
    }

    static bool GTK_IS_MENU_ITEM( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return cast(bool)g_type_check_instance_is_a( cast(GTypeInstance*)arg0, gtk_menu_item_get_type ());
    }

    static bool GTK_IS_PLUG( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return cast(bool)g_type_check_instance_is_a( cast(GTypeInstance*)arg0, gtk_plug_get_type () );
    }

    // Should use d char[] instead for next two methods? - JJR
    static char* GTK_STOCK_CANCEL()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return cast(char*)"gtk-cancel".ptr;
    }

    static char* GTK_STOCK_OK()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return cast(char*)"gtk-ok".ptr;
    }

    static GType GTK_TYPE_CELL_RENDERER_TEXT()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return gtk_cell_renderer_text_get_type();
    }

    static GType GTK_TYPE_CELL_RENDERER_PIXBUF()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return gtk_cell_renderer_pixbuf_get_type();
    }

    static GType GTK_TYPE_CELL_RENDERER_TOGGLE ()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return gtk_cell_renderer_toggle_get_type();
    }

    static GType GTK_TYPE_FIXED()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return gtk_fixed_get_type ();
    }

    static GType GTK_TYPE_MENU()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return gtk_menu_get_type ();
    }

    static GType GTK_TYPE_WIDGET()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return gtk_widget_get_type ();
    }

    static guint GTK_WIDGET_FLAGS( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return    (cast(GtkObject*) g_type_check_instance_cast (cast(GTypeInstance*) arg0,  gtk_object_get_type ())).flags ;
    }

    static ubyte GTK_WIDGET_STATE( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return (  cast(GtkWidget*) g_type_check_instance_cast (cast(GTypeInstance*)arg0, gtk_widget_get_type ())).state;
    }

    static bool GTK_WIDGET_HAS_DEFAULT( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return ( ( ( cast(GtkObject*) g_type_check_instance_cast (cast(GTypeInstance*)arg0, gtk_object_get_type () )).flags & GtkWidgetFlags.GTK_HAS_DEFAULT) != 0) ;
    }

    static bool GTK_WIDGET_HAS_FOCUS( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return ( ( ( cast(GtkObject*) g_type_check_instance_cast (cast(GTypeInstance*)arg0, gtk_object_get_type () )).flags & GtkWidgetFlags.GTK_HAS_FOCUS) != 0) ;
    }

    static bool GTK_WIDGET_IS_SENSITIVE( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return ( ( ( cast (GtkObject*) g_type_check_instance_cast ( cast(GTypeInstance*)arg0, gtk_object_get_type ()) ).flags & GtkWidgetFlags.GTK_SENSITIVE) != 0)   && ( ( ( cast(GtkObject*) g_type_check_instance_cast ( cast(GTypeInstance*)arg0, gtk_object_get_type ()) ).flags & GtkWidgetFlags.GTK_PARENT_SENSITIVE) != 0);
    }

    static bool GTK_WIDGET_MAPPED( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return ( ( ( cast(GtkObject*) g_type_check_instance_cast (cast(GTypeInstance*)arg0, gtk_object_get_type () )).flags & GtkWidgetFlags.GTK_MAPPED) != 0) ;
    }

    static bool GTK_WIDGET_SENSITIVE( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return ( ( ( cast(GtkObject*) g_type_check_instance_cast (cast(GTypeInstance*)arg0, gtk_object_get_type () )).flags & GTK_SENSITIVE) != 0) ;
    }

    static void GTK_WIDGET_SET_FLAGS( void* arg0, uint arg1 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        (cast(GtkObject*) g_type_check_instance_cast ( cast(GTypeInstance*)arg0,  gtk_object_get_type () ) ).flags |= arg1;
    }

    static void GTK_WIDGET_UNSET_FLAGS( void* arg0, uint arg1 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        (cast(GtkObject*) g_type_check_instance_cast ( cast(GTypeInstance*)arg0,  gtk_object_get_type () ) ).flags &= ~arg1;
    }

    static bool GTK_WIDGET_VISIBLE( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return ( ( ( cast(GtkObject*) g_type_check_instance_cast (cast(GTypeInstance*)arg0, gtk_object_get_type () )).flags & GTK_VISIBLE) != 0) ;
    }

    static GObjectClass* G_OBJECT_CLASS( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return (cast(GObjectClass*) g_type_check_class_cast ( cast(GTypeClass*)arg0, cast(GType) (20 << 2) ) ) ;
    }

    static GObjectClass* G_OBJECT_GET_CLASS( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return (cast(GObjectClass*) (cast(GTypeInstance*)arg0).g_class) ;
    }

    static gchar* G_OBJECT_TYPE_NAME( void* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return g_type_name( (cast(GTypeClass*) (cast(GTypeInstance*)arg0).g_class).g_type ) ;
    }

    static GType G_TYPE_BOOLEAN()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return  (cast(GType) (5 << 2)) ;
    }

    static GType G_TYPE_INT()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return (cast(GType) (6 << 2));
    }

    static GType G_OBJECT_TYPE( GTypeInstance* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return (cast(GTypeClass*) arg0.g_class).g_type;
    }

    static GType G_TYPE_STRING()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return (cast(GType) (16 << 2));
    }


    static gint PANGO_PIXELS( gint arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return ((arg0 + 512) >> 10);
    }

    static GType PANGO_TYPE_FONT_DESCRIPTION()
    {
        lock.lock();
        scope(exit) lock.unlock();
        return pango_font_description_get_type () ;
    }

    /**************************************************************************

        Utility methods -- conversions of SWT macros

    **************************************************************************/

    static gpointer g_list_data( GList* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return arg0.data;
    }

    static gpointer g_slist_data( GSList* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return arg0.data;
    }

    static void g_list_set_next( GList* arg0, GList* arg1 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        arg0.next = arg1;
    }

    static void g_list_set_previous( GList* arg0, GList* arg1 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        arg0.prev = arg1;
    }

    static char* gtk_rc_style_get_bg_pixmap_name( GtkRcStyle* arg0, gint arg1 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return arg0.bg_pixmap_name[arg1];
    }

    static gint  gtk_rc_style_get_color_flags( GtkRcStyle* arg0, gint arg1)
    {
        lock.lock();
        scope(exit) lock.unlock();
        return arg0.color_flags[arg1];
    }

    static void gtk_rc_style_set_bg( GtkRcStyle* arg0, gint arg1, GdkColor* arg2)
    {
        lock.lock();
        scope(exit) lock.unlock();
        if (arg2 !is null) {
            arg0.bg[arg1] = *arg2;
        }
    }

    static void gtk_rc_style_set_bg_pixmap_name( GtkRcStyle* arg0, gint arg1, char* arg2)
    {
        lock.lock();
        scope(exit) lock.unlock();
        arg0.bg_pixmap_name[arg1] = arg2;
    }

    static void gtk_rc_style_set_color_flags( GtkRcStyle* arg0, gint arg1, gint arg2)
    {
        lock.lock();
        scope(exit) lock.unlock();
        arg0.color_flags[arg1] = arg2;
    }

    static void gtk_rc_style_set_fg( GtkRcStyle* arg0, gint arg1, GdkColor* arg2)
    {
        lock.lock();
        scope(exit) lock.unlock();
        if (arg2 !is null ) {
            arg0.fg[arg1] = *arg2;
        }
    }

    static void gtk_rc_style_set_text( GtkRcStyle* arg0, gint arg1, GdkColor* arg2)
    {
        lock.lock();
        scope(exit) lock.unlock();
        if (arg2 !is null) {
            arg0.text[arg1] = *arg2;
        }
    }

    static void* gtk_style_get_font_desc( GtkStyle* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return arg0.font_desc;
    }

    static void gtk_style_get_base( GtkStyle* arg0, gint arg1, GdkColor* arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.base[arg1];
    }

    static void gtk_style_get_bg( GtkStyle* arg0, gint arg1, GdkColor* arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.bg[arg1];
    }

    static void gtk_style_get_black( GtkStyle* arg0, GdkColor* arg1 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg1 = arg0.black;
    }

    static void gtk_style_get_dark( GtkStyle* arg0, gint arg1, GdkColor* arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.dark[arg1];
    }

    static void gtk_style_get_fg( GtkStyle* arg0, gint arg1, GdkColor* arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.fg[arg1];
    }

    static void gtk_style_get_light( GtkStyle* arg0, gint arg1, GdkColor* arg2)
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.light[arg1];
    }

    static void gtk_style_get_text( GtkStyle* arg0, gint arg1, GdkColor* arg2)
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.text[arg1];
    }

    static gint  gtk_style_get_xthickness( GtkStyle* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return arg0.xthickness;
    }

    static gint gtk_style_get_ythickness( GtkStyle* arg0 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        return arg0.ythickness;
    }

    static void gtk_style_get_fg_gc( GtkStyle* arg0, gint arg1, GdkGC** arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.fg_gc[arg1];
    }

    static void gtk_style_get_bg_gc( GtkStyle* arg0, gint arg1, GdkGC** arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.bg_gc[arg1];
    }

    static void gtk_style_get_light_gc( GtkStyle* arg0, gint arg1, GdkGC** arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.light_gc[arg1];
    }

    static void gtk_style_get_dark_gc( GtkStyle* arg0, gint arg1, GdkGC** arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.dark_gc[arg1];
    }

    static void gtk_style_get_mid_gc( GtkStyle* arg0, gint arg1, GdkGC** arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.mid_gc[arg1];
    }

    static void gtk_style_get_text_gc( GtkStyle* arg0, gint arg1, GdkGC** arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.text_gc[arg1];
    }

    static void gtk_style_get_text_aa_gc( GtkStyle* arg0, gint arg1, GdkGC** arg2 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg2 = arg0.text_aa_gc[arg1];
    }

    static void gtk_style_get_black_gc( GtkStyle* arg0, GdkGC** arg1 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg1 = arg0.black_gc;
    }

    static void gtk_style_get_white_gc( GtkStyle* arg0, GdkGC** arg1 )
    {
        lock.lock();
        scope(exit) lock.unlock();
        *arg1 = arg0.white_gc;
    }

    static int strlen( char* ptr ){
        version(Tango){
            return tango.stdc.string.strlen( ptr );
        } else { // Phobos
            return cast(int)/*64bit*/core.stdc.string.strlen( ptr );
        }
    }
    //localeconv_decimal_point() localeconv()->decimal_point
    static void* memmove( void* trg, in void* src, size_t len ){
        version(Tango){
            return tango.stdc.string.memmove( trg, src, len );
        } else { // Phobos
            return core.stdc.string.memmove( trg, src, len );
        }
    }
}









