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
module org.eclipse.swt.custom.CTabFolder;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.accessibility.ACC;
import org.eclipse.swt.accessibility.Accessible;
import org.eclipse.swt.accessibility.AccessibleAdapter;
import org.eclipse.swt.accessibility.AccessibleControlAdapter;
import org.eclipse.swt.accessibility.AccessibleControlEvent;
import org.eclipse.swt.accessibility.AccessibleEvent;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Region;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.custom.CTabItem;
import org.eclipse.swt.custom.CTabFolder2Listener;
import org.eclipse.swt.custom.CTabFolderListener;
import org.eclipse.swt.custom.CTabFolderLayout;
import org.eclipse.swt.custom.CTabFolderEvent;

import java.lang.all;
import java.nonstandard.UnsafeUtf;

/**
 *
 * Instances of this class implement the notebook user interface
 * metaphor.  It allows the user to select a notebook page from
 * set of pages.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>CTabItem</code>.
 * <code>Control</code> children are created and then set into a
 * tab item using <code>CTabItem#setControl</code>.
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to set a layout on it.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>CLOSE, TOP, BOTTOM, FLAT, BORDER, SINGLE, MULTI</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * <dd>"CTabFolder2"</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles TOP and BOTTOM
 * may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#ctabfolder">CTabFolder, CTabItem snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: CustomControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class CTabFolder : Composite {

    /**
     * marginWidth specifies the number of pixels of horizontal margin
     * that will be placed along the left and right edges of the form.
     *
     * The default value is 0.
     */
    public int marginWidth = 0;
    /**
     * marginHeight specifies the number of pixels of vertical margin
     * that will be placed along the top and bottom edges of the form.
     *
     * The default value is 0.
     */
    public int marginHeight = 0;

    /**
     * A multiple of the tab height that specifies the minimum width to which a tab
     * will be compressed before scrolling arrows are used to navigate the tabs.
     *
     * NOTE This field is badly named and can not be fixed for backwards compatibility.
     * It should not be capitalized.
     *
     * @deprecated This field is no longer used.  See setMinimumCharacters(int)
     */
    public int MIN_TAB_WIDTH = 4;

    /**
     * Color of innermost line of drop shadow border.
     *
     * NOTE This field is badly named and can not be fixed for backwards compatibility.
     * It should be capitalized.
     *
     * @deprecated drop shadow border is no longer drawn in 3.0
     */
    public static RGB borderInsideRGB;
    /**
     * Color of middle line of drop shadow border.
     *
     * NOTE This field is badly named and can not be fixed for backwards compatibility.
     * It should be capitalized.
     *
     * @deprecated drop shadow border is no longer drawn in 3.0
     */
    public static RGB borderMiddleRGB;
    /**
     * Color of outermost line of drop shadow border.
     *
     * NOTE This field is badly named and can not be fixed for backwards compatibility.
     * It should be capitalized.
     *
     * @deprecated drop shadow border is no longer drawn in 3.0
     */
    public static RGB borderOutsideRGB;

    /* sizing, positioning */
    int xClient, yClient;
    bool onBottom = false;
    bool single = false;
    bool simple = true;
    int fixedTabHeight = SWT.DEFAULT;
    int tabHeight;
    int minChars = 20;

    /* item management */
    CTabItem[] items;
    int firstIndex = -1; // index of the left most visible tab.
    int selectedIndex = -1;
    int[] priority;
    bool mru = false;
    Listener listener;

    /* External Listener management */
    CTabFolder2Listener[] folderListeners;
    // support for deprecated listener mechanism
    CTabFolderListener[] tabListeners;

    /* Selected item appearance */
    Image selectionBgImage;
    Color[] selectionGradientColors;
    int[] selectionGradientPercents;
    bool selectionGradientVertical;
    Color selectionForeground;
    Color selectionBackground;  //selection fade end
    Color selectionFadeStart;

    Color selectionHighlightGradientBegin = null;  //null is no highlight
    //Although we are given new colours all the time to show different states (active, etc),
    //some of which may have a highlight and some not, we'd like to retain the highlight colours
    //as a cache so that we can reuse them if we're again told to show the highlight.
    //We are relying on the fact that only one tab state usually gets a highlight, so only
    //a single cache is required. If that happens to not be true, cache simply becomes less effective,
    //but we don't leak colours.
    Color[] selectionHighlightGradientColorsCache = null;  //null is a legal value, check on access

    /* Unselected item appearance */
    Image bgImage;
    Color[] gradientColors;
    int[] gradientPercents;
    bool gradientVertical;
    bool showUnselectedImage = true;

    static Color borderColor;

    // close, min/max and chevron buttons
    bool showClose = false;
    bool showUnselectedClose = true;

    Rectangle chevronRect;
    int chevronImageState = NORMAL;
    bool showChevron = false;
    Menu showMenu;

    bool showMin = false;
    Rectangle minRect;
    bool minimized = false;
    int minImageState = NORMAL;

    bool showMax = false;
    Rectangle maxRect;
    bool maximized = false;
    int maxImageState = NORMAL;

    Control topRight;
    Rectangle topRightRect;
    int topRightAlignment = SWT.RIGHT;

    // borders and shapes
    int borderLeft = 0;
    int borderRight = 0;
    int borderTop = 0;
    int borderBottom = 0;

    int highlight_margin = 0;
    int highlight_header = 0;

    int[] curve;
    int[] topCurveHighlightStart;
    int[] topCurveHighlightEnd;
    int curveWidth = 0;
    int curveIndent = 0;

    // when disposing CTabFolder, don't try to layout the items or
    // change the selection as each child is destroyed.
    bool inDispose = false;

    // keep track of size changes in order to redraw only affected area
    // on Resize
    Point oldSize;
    Font oldFont;

    // internal constants
    static const int DEFAULT_WIDTH = 64;
    static const int DEFAULT_HEIGHT = 64;
    static const int BUTTON_SIZE = 18;

    static const int[] TOP_LEFT_CORNER = [0,6, 1,5, 1,4, 4,1, 5,1, 6,0];

    //TOP_LEFT_CORNER_HILITE is laid out in reverse (ie. top to bottom)
    //so can fade in same direction as right swoop curve
    static const int[] TOP_LEFT_CORNER_HILITE = [5,2, 4,2, 3,3, 2,4, 2,5, 1,6];

    static const int[] TOP_RIGHT_CORNER = [-6,0, -5,1, -4,1, -1,4, -1,5, 0,6];
    static const int[] BOTTOM_LEFT_CORNER = [0,-6, 1,-5, 1,-4, 4,-1, 5,-1, 6,0];
    static const int[] BOTTOM_RIGHT_CORNER = [-6,0, -5,-1, -4,-1, -1,-4, -1,-5, 0,-6];

    static const int[] SIMPLE_TOP_LEFT_CORNER = [0,2, 1,1, 2,0];
    static const int[] SIMPLE_TOP_RIGHT_CORNER = [-2,0, -1,1, 0,2];
    static const int[] SIMPLE_BOTTOM_LEFT_CORNER = [0,-2, 1,-1, 2,0];
    static const int[] SIMPLE_BOTTOM_RIGHT_CORNER = [-2,0, -1,-1, 0,-2];
    static const int[] SIMPLE_UNSELECTED_INNER_CORNER = [0,0];

    static const int[] TOP_LEFT_CORNER_BORDERLESS = [0,6, 1,5, 1,4, 4,1, 5,1, 6,0];
    static const int[] TOP_RIGHT_CORNER_BORDERLESS = [-7,0, -6,1, -5,1, -2,4, -2,5, -1,6];
    static const int[] BOTTOM_LEFT_CORNER_BORDERLESS = [0,-6, 1,-6, 1,-5, 2,-4, 4,-2, 5,-1, 6,-1, 6,0];
    static const int[] BOTTOM_RIGHT_CORNER_BORDERLESS = [-7,0, -7,-1, -6,-1, -5,-2, -3,-4, -2,-5, -2,-6, -1,-6];

    static const int[] SIMPLE_TOP_LEFT_CORNER_BORDERLESS = [0,2, 1,1, 2,0];
    static const int[] SIMPLE_TOP_RIGHT_CORNER_BORDERLESS= [-3,0, -2,1, -1,2];
    static const int[] SIMPLE_BOTTOM_LEFT_CORNER_BORDERLESS = [0,-3, 1,-2, 2,-1, 3,0];
    static const int[] SIMPLE_BOTTOM_RIGHT_CORNER_BORDERLESS = [-4,0, -3,-1, -2,-2, -1,-3];

    static const int SELECTION_FOREGROUND = SWT.COLOR_LIST_FOREGROUND;
    static const int SELECTION_BACKGROUND = SWT.COLOR_LIST_BACKGROUND;
    static const int BORDER1_COLOR = SWT.COLOR_WIDGET_NORMAL_SHADOW;
    static const int FOREGROUND = SWT.COLOR_WIDGET_FOREGROUND;
    static const int BACKGROUND = SWT.COLOR_WIDGET_BACKGROUND;
    static const int BUTTON_BORDER = SWT.COLOR_WIDGET_DARK_SHADOW;
    static const int BUTTON_FILL = SWT.COLOR_LIST_BACKGROUND;

    static const int NONE = 0;
    static const int NORMAL = 1;
    static const int HOT = 2;
    static const int SELECTED = 3;
    static const RGB CLOSE_FILL;

    static const int CHEVRON_CHILD_ID = 0;
    static const int MINIMIZE_CHILD_ID = 1;
    static const int MAXIMIZE_CHILD_ID = 2;
    static const int EXTRA_CHILD_ID_COUNT = 3;

static this(){
    borderInsideRGB  = new RGB (132, 130, 132);
    borderMiddleRGB  = new RGB (143, 141, 138);
    borderOutsideRGB = new RGB (171, 168, 165);
    CLOSE_FILL = new RGB(252, 160, 160);
}

/**
 * Constructs a new instance of this class given its parent
 * and a style value describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>SWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>SWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p>
 *
 * @param parent a widget which will be the parent of the new instance (cannot be null)
 * @param style the style of widget to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see SWT#TOP
 * @see SWT#BOTTOM
 * @see SWT#FLAT
 * @see SWT#BORDER
 * @see SWT#SINGLE
 * @see SWT#MULTI
 * @see #getStyle()
 */
public this(Composite parent, int style) {
    chevronRect = new Rectangle(0, 0, 0, 0);
    minRect = new Rectangle(0, 0, 0, 0);
    maxRect = new Rectangle(0, 0, 0, 0);
    topRightRect = new Rectangle(0, 0, 0, 0);
    super(parent, checkStyle (parent, style));
    super.setLayout(new CTabFolderLayout());
    int style2 = super.getStyle();
    oldFont = getFont();
    onBottom = (style2 & SWT.BOTTOM) !is 0;
    showClose = (style2 & SWT.CLOSE) !is 0;
//  showMin = (style2 & SWT.MIN) !is 0; - conflicts with SWT.TOP
//  showMax = (style2 & SWT.MAX) !is 0; - conflicts with SWT.BOTTOM
    single = (style2 & SWT.SINGLE) !is 0;
    borderLeft = borderRight = (style & SWT.BORDER) !is 0 ? 1 : 0;
    borderTop = onBottom ? borderLeft : 0;
    borderBottom = onBottom ? 0 : borderLeft;
    highlight_header = (style & SWT.FLAT) !is 0 ? 1 : 3;
    highlight_margin = (style & SWT.FLAT) !is 0 ? 0 : 2;
    //set up default colors
    Display display = getDisplay();
    selectionForeground = display.getSystemColor(SELECTION_FOREGROUND);
    selectionBackground = display.getSystemColor(SELECTION_BACKGROUND);
    borderColor = display.getSystemColor(BORDER1_COLOR);
    updateTabHeight(false);

    initAccessible();

    // Add all listeners
    listener = new class() Listener {
        public void handleEvent(Event event) {
            switch (event.type) {
                case SWT.Dispose:          onDispose(event); break;
                case SWT.DragDetect:       onDragDetect(event); break;
                case SWT.FocusIn:          onFocus(event);  break;
                case SWT.FocusOut:         onFocus(event);  break;
                case SWT.KeyDown:          onKeyDown(event); break;
                case SWT.MouseDoubleClick: onMouseDoubleClick(event); break;
                case SWT.MouseDown:        onMouse(event);  break;
                case SWT.MouseEnter:       onMouse(event);  break;
                case SWT.MouseExit:        onMouse(event);  break;
                case SWT.MouseMove:        onMouse(event); break;
                case SWT.MouseUp:          onMouse(event); break;
                case SWT.Paint:            onPaint(event);  break;
                case SWT.Resize:           onResize();  break;
                case SWT.Traverse:         onTraverse(event); break;
                default:
            }
        }
    };

    int[] folderEvents = [
        SWT.Dispose,
        SWT.DragDetect,
        SWT.FocusIn,
        SWT.FocusOut,
        SWT.KeyDown,
        SWT.MouseDoubleClick,
        SWT.MouseDown,
        SWT.MouseEnter,
        SWT.MouseExit,
        SWT.MouseMove,
        SWT.MouseUp,
        SWT.Paint,
        SWT.Resize,
        SWT.Traverse,
    ];
    for (int i = 0; i < folderEvents.length; i++) {
        addListener(folderEvents[i], listener);
    }
}
static int checkStyle (Composite parent, int style) {
    int mask = SWT.CLOSE | SWT.TOP | SWT.BOTTOM | SWT.FLAT | SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT | SWT.SINGLE | SWT.MULTI;
    style = style & mask;
    // TOP and BOTTOM are mutually exclusive.
    // TOP is the default
    if ((style & SWT.TOP) !is 0) style = style & ~SWT.BOTTOM;
    // SINGLE and MULTI are mutually exclusive.
    // MULTI is the default
    if ((style & SWT.MULTI) !is 0) style = style & ~SWT.SINGLE;
    // reduce the flash by not redrawing the entire area on a Resize event
    style |= SWT.NO_REDRAW_RESIZE;
    //TEMPORARY CODE
    /*
     * The default background on carbon and some GTK themes is not a solid color
     * but a texture.  To show the correct default background, we must allow
     * the operating system to draw it and therefore, we can not use the
     * NO_BACKGROUND style.  The NO_BACKGROUND style is not required on platforms
     * that use double buffering which is true in both of these cases.
     */
    String platform = SWT.getPlatform();
    if ("carbon"==platform || "gtk"==platform) return style; //$NON-NLS-1$ //$NON-NLS-2$

    //TEMPORARY CODE
    /*
     * In Right To Left orientation on Windows, all GC calls that use a brush are drawing
     * offset by one pixel.  This results in some parts of the CTabFolder not drawing correctly.
     * To alleviate some of the appearance problems, allow the OS to draw the background.
     * This does not draw correctly but the result is less obviously wrong.
     */
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) return style;
    if ((parent.getStyle() & SWT.MIRRORED) !is 0 && (style & SWT.LEFT_TO_RIGHT) is 0) return style;

    return style | SWT.NO_BACKGROUND;
}
static void fillRegion(GC gc, Region region) {
    // NOTE: region passed in to this function will be modified
    Region clipping = new Region();
    gc.getClipping(clipping);
    region.intersect(clipping);
    gc.setClipping(region);
    gc.fillRectangle(region.getBounds());
    gc.setClipping(clipping);
    clipping.dispose();
}
/**
 *
 * Adds the listener to the collection of listeners who will
 * be notified when a tab item is closed, minimized, maximized,
 * restored, or to show the list of items that are not
 * currently visible.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @see CTabFolder2Listener
 * @see #removeCTabFolder2Listener(CTabFolder2Listener)
 *
 * @since 3.0
 */
public void addCTabFolder2Listener(CTabFolder2Listener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    // add to array
    CTabFolder2Listener[] newListeners = new CTabFolder2Listener[folderListeners.length + 1];
    SimpleType!(CTabFolder2Listener).arraycopy(folderListeners, 0, newListeners, 0, cast(int)/*64bit*/folderListeners.length);
    folderListeners = newListeners;
    folderListeners[folderListeners.length - 1] = listener;
}
/**
 * Adds the listener to the collection of listeners who will
 * be notified when a tab item is closed.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @see CTabFolderListener
 * @see #removeCTabFolderListener(CTabFolderListener)
 *
 * @deprecated use addCTabFolder2Listener(CTabFolder2Listener)
 */
public void addCTabFolderListener(CTabFolderListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    // add to array
    CTabFolderListener[] newTabListeners = new CTabFolderListener[tabListeners.length + 1];
    SimpleType!(CTabFolderListener).arraycopy(tabListeners, 0, newTabListeners, 0, cast(int)/*64bit*/tabListeners.length);
    tabListeners = newTabListeners;
    tabListeners[tabListeners.length - 1] = listener;
    // display close button to be backwards compatible
    if (!showClose) {
        showClose = true;
        updateItems();
        redraw();
    }
}
/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the user changes the selected tab.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the user changes the receiver's selection
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SelectionListener
 * @see #removeSelectionListener
 * @see SelectionEvent
 */
public void addSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) {
        SWT.error(SWT.ERROR_NULL_ARGUMENT);
    }
    TypedListener typedListener = new TypedListener(listener);
    addListener(SWT.Selection, typedListener);
    addListener(SWT.DefaultSelection, typedListener);
}
void antialias (int[] shape, RGB lineRGB, RGB innerRGB, RGB outerRGB, GC gc){
    // Don't perform anti-aliasing on Mac and WPF because the platform
    // already does it.  The simple style also does not require anti-aliasing.
    if (simple || "carbon".equals(SWT.getPlatform()) || "wpf".equals(SWT.getPlatform())) return; //$NON-NLS-1$
    // Don't perform anti-aliasing on low resolution displays
    if (getDisplay().getDepth() < 15) return;
    if (outerRGB !is null) {
        int index = 0;
        bool left = true;
        int oldY = onBottom ? 0 : getSize().y;
        int[] outer = new int[shape.length];
        for (int i = 0; i < shape.length/2; i++) {
            if (left && (index + 3 < shape.length)) {
                left = onBottom ? oldY <= shape[index+3] : oldY >= shape[index+3];
                oldY = shape[index+1];
            }
            outer[index] = shape[index] + (left ? -1 : +1);
            index++;
            outer[index] = shape[index];
            index++;
        }
        RGB from = lineRGB;
        RGB to = outerRGB;
        int red = from.red + 2*(to.red - from.red)/3;
        int green = from.green + 2*(to.green - from.green)/3;
        int blue = from.blue + 2*(to.blue - from.blue)/3;
        Color color = new Color(getDisplay(), red, green, blue);
        gc.setForeground(color);
        gc.drawPolyline(outer);
        color.dispose();
    }
    if (innerRGB !is null) {
        int[] inner = new int[shape.length];
        int index = 0;
        bool left = true;
        int oldY = onBottom ? 0 : getSize().y;
        for (int i = 0; i < shape.length/2; i++) {
            if (left && (index + 3 < shape.length)) {
                left = onBottom ? oldY <= shape[index+3] : oldY >= shape[index+3];
                oldY = shape[index+1];
            }
            inner[index] = shape[index] + (left ? +1 : -1);
            index++;
            inner[index] = shape[index];
            index++;
        }
        RGB from = lineRGB;
        RGB to = innerRGB;
        int red = from.red + 2*(to.red - from.red)/3;
        int green = from.green + 2*(to.green - from.green)/3;
        int blue = from.blue + 2*(to.blue - from.blue)/3;
        Color color = new Color(getDisplay(), red, green, blue);
        gc.setForeground(color);
        gc.drawPolyline(inner);
        color.dispose();
    }
}
public override Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget();
    int trimX = x - marginWidth - highlight_margin - borderLeft;
    int trimWidth = width + borderLeft + borderRight + 2*marginWidth + 2*highlight_margin;
    if (minimized) {
        int trimY = onBottom ? y - borderTop : y - highlight_header - tabHeight - borderTop;
        int trimHeight = borderTop + borderBottom + tabHeight + highlight_header;
        return new Rectangle (trimX, trimY, trimWidth, trimHeight);
    } else {
        int trimY = onBottom ? y - marginHeight - highlight_margin - borderTop: y - marginHeight - highlight_header - tabHeight - borderTop;
        int trimHeight = height + borderTop + borderBottom + 2*marginHeight + tabHeight + highlight_header + highlight_margin;
        return new Rectangle (trimX, trimY, trimWidth, trimHeight);
    }
}
void createItem (CTabItem item, int index) {
    if (0 > index || index > getItemCount ())SWT.error (SWT.ERROR_INVALID_RANGE);
    item.parent = this;
    CTabItem[] newItems = new CTabItem [items.length + 1];
    System.arraycopy(items, 0, newItems, 0, index);
    newItems[index] = item;
    System.arraycopy(items, index, newItems, index + 1, items.length - index);
    items = newItems;
    if (selectedIndex >= index) selectedIndex ++;
    int[] newPriority = new int[priority.length + 1];
    int next = 0,  priorityIndex = cast(int)/*64bit*/priority.length;
    for (int i = 0; i < priority.length; i++) {
        if (!mru && priority[i] is index) {
            priorityIndex = next++;
        }
        newPriority[next++] = priority[i] >= index ? priority[i] + 1 : priority[i];
    }
    newPriority[priorityIndex] = index;
    priority = newPriority;

    if (items.length is 1) {
        if (!updateTabHeight(false)) updateItems();
        redraw();
    } else {
        updateItems();
        redrawTabs();
    }
}
void destroyItem (CTabItem item) {
    if (inDispose) return;
    int index = indexOf(item);
    if (index is -1) return;

    if (items.length is 1) {
        items = new CTabItem[0];
        priority = new int[0];
        firstIndex = -1;
        selectedIndex = -1;

        Control control = item.getControl();
        if (control !is null && !control.isDisposed()) {
            control.setVisible(false);
        }
        setToolTipText(null);
        setButtonBounds();
        redraw();
        return;
    }

    CTabItem[] newItems = new CTabItem [items.length - 1];
    System.arraycopy(items, 0, newItems, 0, index);
    System.arraycopy(items, index + 1, newItems, index, items.length - index - 1);
    items = newItems;

    int[] newPriority = new int[priority.length - 1];
    int next = 0;
    for (int i = 0; i < priority.length; i++) {
        if (priority [i] is index) continue;
        newPriority[next++] = priority[i] > index ? priority[i] - 1 : priority [i];
    }
    priority = newPriority;

    // move the selection if this item is selected
    if (selectedIndex is index) {
        Control control = item.getControl();
        selectedIndex = -1;
        int nextSelection = mru ? priority[0] : Math.max(0, index - 1);
        setSelection(nextSelection, true);
        if (control !is null && !control.isDisposed()) {
            control.setVisible(false);
        }
    } else if (selectedIndex > index) {
        selectedIndex --;
    }

    updateItems();
    redrawTabs();
}
void drawBackground(GC gc, int[] shape, bool selected) {
    Color defaultBackground = selected ? selectionBackground : getBackground();
    Image image = selected ? selectionBgImage : bgImage;
    Color[] colors = selected ? selectionGradientColors : gradientColors;
    int[] percents = selected ? selectionGradientPercents : gradientPercents;
    bool vertical = selected ? selectionGradientVertical : gradientVertical;
    Point size = getSize();
    int width = size.x;
    int height = tabHeight + highlight_header;
    int x = 0;
    if (borderLeft > 0) {
        x += 1; width -= 2;
    }
    int y = onBottom ? size.y - borderBottom - height : borderTop;
    drawBackground(gc, shape, x, y, width, height, defaultBackground, image, colors, percents, vertical);
}
void drawBackground(GC gc, int[] shape, int x, int y, int width, int height, Color defaultBackground, Image image, Color[] colors, int[] percents, bool vertical) {
    Region clipping = new Region();
    gc.getClipping(clipping);
    Region region = new Region();
    region.add(shape);
    region.intersect(clipping);
    gc.setClipping(region);

    if (image !is null) {
        // draw the background image in shape
        gc.setBackground(defaultBackground);
        gc.fillRectangle(x, y, width, height);
        Rectangle imageRect = image.getBounds();
        gc.drawImage(image, imageRect.x, imageRect.y, imageRect.width, imageRect.height, x, y, width, height);
    } else if (colors !is null) {
        // draw gradient
        if (colors.length is 1) {
            Color background = colors[0] !is null ? colors[0] : defaultBackground;
            gc.setBackground(background);
            gc.fillRectangle(x, y, width, height);
        } else {
            if (vertical) {
                if (onBottom) {
                    int pos = 0;
                    if (percents[percents.length - 1] < 100) {
                        pos = percents[percents.length - 1] * height / 100;
                        gc.setBackground(defaultBackground);
                        gc.fillRectangle(x, y, width, pos);
                    }
                    Color lastColor = colors[colors.length-1];
                    if (lastColor is null) lastColor = defaultBackground;
                    for (ptrdiff_t i = cast(ptrdiff_t) (percents.length)-1; i >= 0; i--) {
                        gc.setForeground(lastColor);
                        lastColor = colors[i];
                        if (lastColor is null) lastColor = defaultBackground;
                        gc.setBackground(lastColor);
                        int gradientHeight = percents[i] * height / 100;
                        gc.fillGradientRectangle(x, y+pos, width, gradientHeight, true);
                        pos += gradientHeight;
                    }
                } else {
                    Color lastColor = colors[0];
                    if (lastColor is null) lastColor = defaultBackground;
                    int pos = 0;
                    for (int i = 0; i < percents.length; i++) {
                        gc.setForeground(lastColor);
                        lastColor = colors[i + 1];
                        if (lastColor is null) lastColor = defaultBackground;
                        gc.setBackground(lastColor);
                        int gradientHeight = percents[i] * height / 100;
                        gc.fillGradientRectangle(x, y+pos, width, gradientHeight, true);
                        pos += gradientHeight;
                    }
                    if (pos < height) {
                        gc.setBackground(defaultBackground);
                        gc.fillRectangle(x, pos, width, height-pos+1);
                    }
                }
            } else { //horizontal gradient
                y = 0;
                height = getSize().y;
                Color lastColor = colors[0];
                if (lastColor is null) lastColor = defaultBackground;
                int pos = 0;
                for (int i = 0; i < percents.length; ++i) {
                    gc.setForeground(lastColor);
                    lastColor = colors[i + 1];
                    if (lastColor is null) lastColor = defaultBackground;
                    gc.setBackground(lastColor);
                    int gradientWidth = (percents[i] * width / 100) - pos;
                    gc.fillGradientRectangle(x+pos, y, gradientWidth, height, false);
                    pos += gradientWidth;
                }
                if (pos < width) {
                    gc.setBackground(defaultBackground);
                    gc.fillRectangle(x+pos, y, width-pos, height);
                }
            }
        }
    } else {
        // draw a solid background using default background in shape
        if ((getStyle() & SWT.NO_BACKGROUND) !is 0 || defaultBackground!=getBackground()) {
            gc.setBackground(defaultBackground);
            gc.fillRectangle(x, y, width, height);
        }
    }
    gc.setClipping(clipping);
    clipping.dispose();
    region.dispose();
}
void drawBody(Event event) {
    GC gc = event.gc;
    Point size = getSize();

    // fill in body
    if (!minimized){
        int width = size.x  - borderLeft - borderRight - 2*highlight_margin;
        int height = size.y - borderTop - borderBottom - tabHeight - highlight_header - highlight_margin;
        // Draw highlight margin
        if (highlight_margin > 0) {
            int[] shape = null;
            if (onBottom) {
                int x1 = borderLeft;
                int y1 = borderTop;
                int x2 = size.x - borderRight;
                int y2 = size.y - borderBottom - tabHeight - highlight_header;
                shape = [x1,y1, x2,y1, x2,y2, x2-highlight_margin,y2,
                                   x2-highlight_margin, y1+highlight_margin, x1+highlight_margin,y1+highlight_margin,
                                   x1+highlight_margin,y2, x1,y2];
            } else {
                int x1 = borderLeft;
                int y1 = borderTop + tabHeight + highlight_header;
                int x2 = size.x - borderRight;
                int y2 = size.y - borderBottom;
                shape = [x1,y1, x1+highlight_margin,y1, x1+highlight_margin,y2-highlight_margin,
                                   x2-highlight_margin,y2-highlight_margin, x2-highlight_margin,y1,
                                   x2,y1, x2,y2, x1,y2];
            }
            // If horizontal gradient, show gradient across the whole area
            if (selectedIndex !is -1 && selectionGradientColors !is null && selectionGradientColors.length > 1 && !selectionGradientVertical) {
                drawBackground(gc, shape, true);
            } else if (selectedIndex is -1 && gradientColors !is null && gradientColors.length > 1 && !gradientVertical) {
                drawBackground(gc, shape, false);
            } else {
                gc.setBackground(selectedIndex is -1 ? getBackground() : selectionBackground);
                gc.fillPolygon(shape);
            }
        }
        //Draw client area
        if ((getStyle() & SWT.NO_BACKGROUND) !is 0) {
            gc.setBackground(getBackground());
            gc.fillRectangle(xClient - marginWidth, yClient - marginHeight, width, height);
        }
    } else {
        if ((getStyle() & SWT.NO_BACKGROUND) !is 0) {
            int height = borderTop + tabHeight + highlight_header + borderBottom;
            if (size.y > height) {
                gc.setBackground(getParent().getBackground());
                gc.fillRectangle(0, height, size.x, size.y - height);
            }
        }
    }

    //draw 1 pixel border around outside
    if (borderLeft > 0) {
        gc.setForeground(borderColor);
        int x1 = borderLeft - 1;
        int x2 = size.x - borderRight;
        int y1 = onBottom ? borderTop - 1 : borderTop + tabHeight;
        int y2 = onBottom ? size.y - tabHeight - borderBottom - 1 : size.y - borderBottom;
        gc.drawLine(x1, y1, x1, y2); // left
        gc.drawLine(x2, y1, x2, y2); // right
        if (onBottom) {
            gc.drawLine(x1, y1, x2, y1); // top
        } else {
            gc.drawLine(x1, y2, x2, y2); // bottom
        }
    }
}

void drawChevron(GC gc) {
    if (chevronRect.width is 0 || chevronRect.height is 0) return;
    // draw chevron (10x7)
    Display display = getDisplay();
    Point dpi = display.getDPI();
    int fontHeight = 72 * 10 / dpi.y;
    FontData fd = getFont().getFontData()[0];
    fd.setHeight(fontHeight);
    Font f = new Font(display, fd);
    int fHeight = f.getFontData()[0].getHeight() * dpi.y / 72;
    int indent = Math.max(2, (chevronRect.height - fHeight - 4) /2);
    int x = chevronRect.x + 2;
    int y = chevronRect.y + indent;
    int count;
    if (single) {
        count = cast(int)/*64bit*/(selectedIndex is -1 ? items.length : items.length - 1);
    } else {
        int showCount = 0;
        while (showCount < priority.length && items[priority[showCount]].showing) {
            showCount++;
        }
        count = cast(int)/*64bit*/items.length - showCount;
    }
    String chevronString = count > 99 ? "99+" : String_valueOf(count); //$NON-NLS-1$
    switch (chevronImageState) {
        case NORMAL: {
            Color chevronBorder = single ? getSelectionForeground() : getForeground();
            gc.setForeground(chevronBorder);
            gc.setFont(f);
            gc.drawLine(x,y,     x+2,y+2);
            gc.drawLine(x+2,y+2, x,y+4);
            gc.drawLine(x+1,y,   x+3,y+2);
            gc.drawLine(x+3,y+2, x+1,y+4);
            gc.drawLine(x+4,y,   x+6,y+2);
            gc.drawLine(x+6,y+2, x+5,y+4);
            gc.drawLine(x+5,y,   x+7,y+2);
            gc.drawLine(x+7,y+2, x+4,y+4);
            gc.drawString(chevronString, x+7, y+3, true);
            break;
        }
        case HOT: {
            gc.setForeground(display.getSystemColor(BUTTON_BORDER));
            gc.setBackground(display.getSystemColor(BUTTON_FILL));
            gc.setFont(f);
            gc.fillRoundRectangle(chevronRect.x, chevronRect.y, chevronRect.width, chevronRect.height, 6, 6);
            gc.drawRoundRectangle(chevronRect.x, chevronRect.y, chevronRect.width - 1, chevronRect.height - 1, 6, 6);
            gc.drawLine(x,y,     x+2,y+2);
            gc.drawLine(x+2,y+2, x,y+4);
            gc.drawLine(x+1,y,   x+3,y+2);
            gc.drawLine(x+3,y+2, x+1,y+4);
            gc.drawLine(x+4,y,   x+6,y+2);
            gc.drawLine(x+6,y+2, x+5,y+4);
            gc.drawLine(x+5,y,   x+7,y+2);
            gc.drawLine(x+7,y+2, x+4,y+4);
            gc.drawString(chevronString, x+7, y+3, true);
            break;
        }
        case SELECTED: {
            gc.setForeground(display.getSystemColor(BUTTON_BORDER));
            gc.setBackground(display.getSystemColor(BUTTON_FILL));
            gc.setFont(f);
            gc.fillRoundRectangle(chevronRect.x, chevronRect.y, chevronRect.width, chevronRect.height, 6, 6);
            gc.drawRoundRectangle(chevronRect.x, chevronRect.y, chevronRect.width - 1, chevronRect.height - 1, 6, 6);
            gc.drawLine(x+1,y+1, x+3,y+3);
            gc.drawLine(x+3,y+3, x+1,y+5);
            gc.drawLine(x+2,y+1, x+4,y+3);
            gc.drawLine(x+4,y+3, x+2,y+5);
            gc.drawLine(x+5,y+1, x+7,y+3);
            gc.drawLine(x+7,y+3, x+6,y+5);
            gc.drawLine(x+6,y+1, x+8,y+3);
            gc.drawLine(x+8,y+3, x+5,y+5);
            gc.drawString(chevronString, x+8, y+4, true);
            break;
        }
        default:
    }
    f.dispose();
}
void drawMaximize(GC gc) {
    if (maxRect.width is 0 || maxRect.height is 0) return;
    Display display = getDisplay();
    // 5x4 or 7x9
    int x = maxRect.x + (CTabFolder.BUTTON_SIZE - 10)/2;
    int y = maxRect.y + 3;

    gc.setForeground(display.getSystemColor(BUTTON_BORDER));
    gc.setBackground(display.getSystemColor(BUTTON_FILL));

    switch (maxImageState) {
        case NORMAL: {
            if (!maximized) {
                gc.fillRectangle(x, y, 9, 9);
                gc.drawRectangle(x, y, 9, 9);
                gc.drawLine(x+1, y+2, x+8, y+2);
            } else {
                gc.fillRectangle(x, y+3, 5, 4);
                gc.fillRectangle(x+2, y, 5, 4);
                gc.drawRectangle(x, y+3, 5, 4);
                gc.drawRectangle(x+2, y, 5, 4);
                gc.drawLine(x+3, y+1, x+6, y+1);
                gc.drawLine(x+1, y+4, x+4, y+4);
            }
            break;
        }
        case HOT: {
            gc.fillRoundRectangle(maxRect.x, maxRect.y, maxRect.width, maxRect.height, 6, 6);
            gc.drawRoundRectangle(maxRect.x, maxRect.y, maxRect.width - 1, maxRect.height - 1, 6, 6);
            if (!maximized) {
                gc.fillRectangle(x, y, 9, 9);
                gc.drawRectangle(x, y, 9, 9);
                gc.drawLine(x+1, y+2, x+8, y+2);
            } else {
                gc.fillRectangle(x, y+3, 5, 4);
                gc.fillRectangle(x+2, y, 5, 4);
                gc.drawRectangle(x, y+3, 5, 4);
                gc.drawRectangle(x+2, y, 5, 4);
                gc.drawLine(x+3, y+1, x+6, y+1);
                gc.drawLine(x+1, y+4, x+4, y+4);
            }
            break;
        }
        case SELECTED: {
            gc.fillRoundRectangle(maxRect.x, maxRect.y, maxRect.width, maxRect.height, 6, 6);
            gc.drawRoundRectangle(maxRect.x, maxRect.y, maxRect.width - 1, maxRect.height - 1, 6, 6);
            if (!maximized) {
                gc.fillRectangle(x+1, y+1, 9, 9);
                gc.drawRectangle(x+1, y+1, 9, 9);
                gc.drawLine(x+2, y+3, x+9, y+3);
            } else {
                gc.fillRectangle(x+1, y+4, 5, 4);
                gc.fillRectangle(x+3, y+1, 5, 4);
                gc.drawRectangle(x+1, y+4, 5, 4);
                gc.drawRectangle(x+3, y+1, 5, 4);
                gc.drawLine(x+4, y+2, x+7, y+2);
                gc.drawLine(x+2, y+5, x+5, y+5);
            }
            break;
        }
        default:
    }
}
void drawMinimize(GC gc) {
    if (minRect.width is 0 || minRect.height is 0) return;
    Display display = getDisplay();
    // 5x4 or 9x3
    int x = minRect.x + (BUTTON_SIZE - 10)/2;
    int y = minRect.y + 3;

    gc.setForeground(display.getSystemColor(BUTTON_BORDER));
    gc.setBackground(display.getSystemColor(BUTTON_FILL));

    switch (minImageState) {
        case NORMAL: {
            if (!minimized) {
                gc.fillRectangle(x, y, 9, 3);
                gc.drawRectangle(x, y, 9, 3);
            } else {
                gc.fillRectangle(x, y+3, 5, 4);
                gc.fillRectangle(x+2, y, 5, 4);
                gc.drawRectangle(x, y+3, 5, 4);
                gc.drawRectangle(x+2, y, 5, 4);
                gc.drawLine(x+3, y+1, x+6, y+1);
                gc.drawLine(x+1, y+4, x+4, y+4);
            }
            break;
        }
        case HOT: {
            gc.fillRoundRectangle(minRect.x, minRect.y, minRect.width, minRect.height, 6, 6);
            gc.drawRoundRectangle(minRect.x, minRect.y, minRect.width - 1, minRect.height - 1, 6, 6);
            if (!minimized) {
                gc.fillRectangle(x, y, 9, 3);
                gc.drawRectangle(x, y, 9, 3);
            } else {
                gc.fillRectangle(x, y+3, 5, 4);
                gc.fillRectangle(x+2, y, 5, 4);
                gc.drawRectangle(x, y+3, 5, 4);
                gc.drawRectangle(x+2, y, 5, 4);
                gc.drawLine(x+3, y+1, x+6, y+1);
                gc.drawLine(x+1, y+4, x+4, y+4);
            }
            break;
        }
        case SELECTED: {
            gc.fillRoundRectangle(minRect.x, minRect.y, minRect.width, minRect.height, 6, 6);
            gc.drawRoundRectangle(minRect.x, minRect.y, minRect.width - 1, minRect.height - 1, 6, 6);
            if (!minimized) {
                gc.fillRectangle(x+1, y+1, 9, 3);
                gc.drawRectangle(x+1, y+1, 9, 3);
            } else {
                gc.fillRectangle(x+1, y+4, 5, 4);
                gc.fillRectangle(x+3, y+1, 5, 4);
                gc.drawRectangle(x+1, y+4, 5, 4);
                gc.drawRectangle(x+3, y+1, 5, 4);
                gc.drawLine(x+4, y+2, x+7, y+2);
                gc.drawLine(x+2, y+5, x+5, y+5);
            }
            break;
        }
        default:
    }
}
void drawTabArea(Event event) {
    GC gc = event.gc;
    Point size = getSize();
    int[] shape = null;

    if (tabHeight is 0) {
        int style = getStyle();
        if ((style & SWT.FLAT) !is 0 && (style & SWT.BORDER) is 0) return;
        int x1 = borderLeft - 1;
        int x2 = size.x - borderRight;
        int y1 = onBottom ? size.y - borderBottom - highlight_header - 1 : borderTop + highlight_header;
        int y2 = onBottom ? size.y - borderBottom : borderTop;
        if (borderLeft > 0 && onBottom) y2 -= 1;

        shape = [x1, y1, x1,y2, x2,y2, x2,y1];

        // If horizontal gradient, show gradient across the whole area
        if (selectedIndex !is -1 && selectionGradientColors !is null && selectionGradientColors.length > 1 && !selectionGradientVertical) {
            drawBackground(gc, shape, true);
        } else if (selectedIndex is -1 && gradientColors !is null && gradientColors.length > 1 && !gradientVertical) {
            drawBackground(gc, shape, false);
        } else {
            gc.setBackground(selectedIndex is -1 ? getBackground() : selectionBackground);
            gc.fillPolygon(shape);
        }

        //draw 1 pixel border
        if (borderLeft > 0) {
            gc.setForeground(borderColor);
            gc.drawPolyline(shape);
        }
        return;
    }

    int x = Math.max(0, borderLeft - 1);
    int y = onBottom ? size.y - borderBottom - tabHeight : borderTop;
    int width = size.x - borderLeft - borderRight + 1;
    int height = tabHeight - 1;

    // Draw Tab Header
    if (onBottom) {
        TryConst!(int)[] left, right;
        if ((getStyle() & SWT.BORDER) !is 0) {
            left = simple ? SIMPLE_BOTTOM_LEFT_CORNER : BOTTOM_LEFT_CORNER;
            right = simple ? SIMPLE_BOTTOM_RIGHT_CORNER : BOTTOM_RIGHT_CORNER;
        } else {
            left = simple ? SIMPLE_BOTTOM_LEFT_CORNER_BORDERLESS : BOTTOM_LEFT_CORNER_BORDERLESS;
            right = simple ? SIMPLE_BOTTOM_RIGHT_CORNER_BORDERLESS : BOTTOM_RIGHT_CORNER_BORDERLESS;
        }
        shape = new int[left.length + right.length + 4];
        int index = 0;
        shape[index++] = x;
        shape[index++] = y-highlight_header;
        for (int i = 0; i < left.length/2; i++) {
            shape[index++] = x+left[2*i];
            shape[index++] = y+height+left[2*i+1];
            if (borderLeft is 0) shape[index-1] += 1;
        }
        for (int i = 0; i < right.length/2; i++) {
            shape[index++] = x+width+right[2*i];
            shape[index++] = y+height+right[2*i+1];
            if (borderLeft is 0) shape[index-1] += 1;
        }
        shape[index++] = x+width;
        shape[index++] = y-highlight_header;
    } else {
        TryConst!(int)[] left, right;
        if ((getStyle() & SWT.BORDER) !is 0) {
            left = simple ? SIMPLE_TOP_LEFT_CORNER : TOP_LEFT_CORNER;
            right = simple ? SIMPLE_TOP_RIGHT_CORNER : TOP_RIGHT_CORNER;
        } else {
            left = simple ? SIMPLE_TOP_LEFT_CORNER_BORDERLESS : TOP_LEFT_CORNER_BORDERLESS;
            right = simple ? SIMPLE_TOP_RIGHT_CORNER_BORDERLESS : TOP_RIGHT_CORNER_BORDERLESS;
        }
        shape = new int[left.length + right.length + 4];
        int index = 0;
        shape[index++] = x;
        shape[index++] = y+height+highlight_header + 1;
        for (int i = 0; i < left.length/2; i++) {
            shape[index++] = x+left[2*i];
            shape[index++] = y+left[2*i+1];
        }
        for (int i = 0; i < right.length/2; i++) {
            shape[index++] = x+width+right[2*i];
            shape[index++] = y+right[2*i+1];
        }
        shape[index++] = x+width;
        shape[index++] = y+height+highlight_header + 1;
    }
    // Fill in background
    bool bkSelected = single && selectedIndex !is -1;
    drawBackground(gc, shape, bkSelected);
    // Fill in parent background for non-rectangular shape
    Region r = new Region();
    r.add(new Rectangle(x, y, width + 1, height + 1));
    r.subtract(shape);
    gc.setBackground(getParent().getBackground());
    fillRegion(gc, r);
    r.dispose();

    // Draw the unselected tabs.
    if (!single) {
        for (int i=0; i < items.length; i++) {
            if (i !is selectedIndex && event.getBounds().intersects(items[i].getBounds())) {
                items[i].onPaint(gc, false);
            }
        }
    }

    // Draw selected tab
    if (selectedIndex !is -1) {
        CTabItem item = items[selectedIndex];
        item.onPaint(gc, true);
    } else {
        // if no selected tab - draw line across bottom of all tabs
        int x1 = borderLeft;
        int y1 = (onBottom) ? size.y - borderBottom - tabHeight - 1 : borderTop + tabHeight;
        int x2 = size.x - borderRight;
        gc.setForeground(borderColor);
        gc.drawLine(x1, y1, x2, y1);
    }

    // Draw Buttons
    drawChevron(gc);
    drawMinimize(gc);
    drawMaximize(gc);

    // Draw border line
    if (borderLeft > 0) {
        RGB outside = getParent().getBackground().getRGB();
        antialias(shape, borderColor.getRGB(), null, outside, gc);
        gc.setForeground(borderColor);
        gc.drawPolyline(shape);
    }
}
/**
 * Returns <code>true</code> if the receiver's border is visible.
 *
 * @return the receiver's border visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public bool getBorderVisible() {
    checkWidget();
    return borderLeft is 1;
}
public override Rectangle getClientArea() {
    checkWidget();
    if (minimized) return new Rectangle(xClient, yClient, 0, 0);
    Point size = getSize();
    int width = size.x  - borderLeft - borderRight - 2*marginWidth - 2*highlight_margin;
    int height = size.y - borderTop - borderBottom - 2*marginHeight - highlight_margin - highlight_header;
    height -= tabHeight;
    return new Rectangle(xClient, yClient, width, height);
}
/**
 * Return the tab that is located at the specified index.
 *
 * @param index the index of the tab item
 * @return the item at the specified index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is out of range</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 */
public CTabItem getItem (int index) {
    //checkWidget();
    if (index  < 0 || index >= items.length)
        SWT.error(SWT.ERROR_INVALID_RANGE);
    return items [index];
}
/**
 * Gets the item at a point in the widget.
 *
 * @param pt the point in coordinates relative to the CTabFolder
 * @return the item at a point or null
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public CTabItem getItem (Point pt) {
    //checkWidget();
    if (items.length is 0) return null;
    Point size = getSize();
    if (size.x <= borderLeft + borderRight) return null;
    if (showChevron && chevronRect.contains(pt)) return null;
    for (int i = 0; i < priority.length; i++) {
        CTabItem item = items[priority[i]];
        Rectangle rect = item.getBounds();
        if (rect.contains(pt)) return item;
    }
    return null;
}
/**
 * Return the number of tabs in the folder.
 *
 * @return the number of tabs in the folder
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public int getItemCount(){
    //checkWidget();
    return cast(int)/*64bit*/items.length;
}
/**
 * Return the tab items.
 *
 * @return the tab items
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public CTabItem [] getItems() {
    //checkWidget();
    CTabItem[] tabItems = new CTabItem [items.length];
    System.arraycopy(items, 0, tabItems, 0, items.length);
    return tabItems;
}
/*
 * Return the lowercase of the first non-'&' character following
 * an '&' character in the given string. If there are no '&'
 * characters in the given string, return '\0'.
 */
dchar _findMnemonic (String string) {
    if (string is null) return '\0';
    int index = 0;
    int length_ = cast(int)/*64bit*/string.length;
    do {
        while (index < length_ && string[index] !is '&') index++;
        if (++index >= length_) return '\0';
        if (string[index] !is '&') return Character.toLowerCase (string.dcharAt (index));
        index++;
    } while (index < length_);
    return '\0';
}
String stripMnemonic (String string) {
    int index = 0;
    int length_ = cast(int)/*64bit*/string.length;
    do {
        while ((index < length_) && (string[index] !is '&')) index++;
        if (++index >= length_) return string;
        if (string[index] !is '&') {
            return string.substring(0, index-1) ~ string.substring(index, length_);
        }
        index++;
    } while (index < length_);
    return string;
}
/**
 * Returns <code>true</code> if the receiver is minimized.
 *
 * @return the receiver's minimized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public bool getMinimized() {
    checkWidget();
    return minimized;
}
/**
 * Returns <code>true</code> if the minimize button
 * is visible.
 *
 * @return the visibility of the minimized button
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public bool getMinimizeVisible() {
    checkWidget();
    return showMin;
}
/**
 * Returns the number of characters that will
 * appear in a fully compressed tab.
 *
 * @return number of characters that will appear in a fully compressed tab
 *
 * @since 3.0
 */
public int getMinimumCharacters() {
    checkWidget();
    return minChars;
}
/**
 * Returns <code>true</code> if the receiver is maximized.
 * <p>
 *
 * @return the receiver's maximized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public bool getMaximized() {
    checkWidget();
    return maximized;
}
/**
 * Returns <code>true</code> if the maximize button
 * is visible.
 *
 * @return the visibility of the maximized button
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public bool getMaximizeVisible() {
    checkWidget();
    return showMax;
}
/**
 * Returns <code>true</code> if the receiver displays most
 * recently used tabs and <code>false</code> otherwise.
 * <p>
 * When there is not enough horizontal space to show all the tabs,
 * by default, tabs are shown sequentially from left to right in
 * order of their index.  When the MRU visibility is turned on,
 * the tabs that are visible will be the tabs most recently selected.
 * Tabs will still maintain their left to right order based on index
 * but only the most recently selected tabs are visible.
 * <p>
 * For example, consider a CTabFolder that contains "Tab 1", "Tab 2",
 * "Tab 3" and "Tab 4" (in order by index).  The user selects
 * "Tab 1" and then "Tab 3".  If the CTabFolder is now
 * compressed so that only two tabs are visible, by default,
 * "Tab 2" and "Tab 3" will be shown ("Tab 3" since it is currently
 * selected and "Tab 2" because it is the previous item in index order).
 * If MRU visibility is enabled, the two visible tabs will be "Tab 1"
 * and "Tab 3" (in that order from left to right).</p>
 *
 * @return the receiver's header's visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public bool getMRUVisible() {
    checkWidget();
    return mru;
}
int getRightItemEdge (){
    int x = getSize().x - borderRight - 3;
    if (showMin) x -= BUTTON_SIZE;
    if (showMax) x -= BUTTON_SIZE;
    if (showChevron) x -= 3*BUTTON_SIZE/2;
    if (topRight !is null && topRightAlignment !is SWT.FILL) {
        Point rightSize = topRight.computeSize(SWT.DEFAULT, SWT.DEFAULT);
        x -= rightSize.x + 3;
    }
    return Math.max(0, x);
}
/**
 * Return the selected tab item, or null if there is no selection.
 *
 * @return the selected tab item, or null if none has been selected
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public CTabItem getSelection() {
    //checkWidget();
    if (selectedIndex is -1) return null;
    return items[selectedIndex];
}
/**
 * Returns the receiver's selection background color.
 *
 * @return the selection background color of the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public Color getSelectionBackground() {
    checkWidget();
    return selectionBackground;
}
/**
 * Returns the receiver's selection foreground color.
 *
 * @return the selection foreground color of the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public Color getSelectionForeground() {
    checkWidget();
    return selectionForeground;
}
/**
 * Return the index of the selected tab item, or -1 if there
 * is no selection.
 *
 * @return the index of the selected tab item or -1
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public int getSelectionIndex() {
    //checkWidget();
    return selectedIndex;
}
/**
 * Returns <code>true</code> if the CTabFolder is rendered
 * with a simple, traditional shape.
 *
 * @return <code>true</code> if the CTabFolder is rendered with a simple shape
 *
 * @since 3.0
 */
public bool getSimple() {
    checkWidget();
    return simple;
}
/**
 * Returns <code>true</code> if the CTabFolder only displays the selected tab
 * and <code>false</code> if the CTabFolder displays multiple tabs.
 *
 * @return <code>true</code> if the CTabFolder only displays the selected tab and <code>false</code> if the CTabFolder displays multiple tabs
 *
 * @since 3.0
 */
public bool getSingle() {
    checkWidget();
    return single;
}

public override int getStyle() {
    int style = super.getStyle();
    style &= ~(SWT.TOP | SWT.BOTTOM);
    style |= onBottom ? SWT.BOTTOM : SWT.TOP;
    style &= ~(SWT.SINGLE | SWT.MULTI);
    style |= single ? SWT.SINGLE : SWT.MULTI;
    if (borderLeft !is 0) style |= SWT.BORDER;
    style &= ~SWT.CLOSE;
    if (showClose) style |= SWT.CLOSE;
    return style;
}
/**
 * Returns the height of the tab
 *
 * @return the height of the tab
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public int getTabHeight(){
    checkWidget();
    if (fixedTabHeight !is SWT.DEFAULT) return fixedTabHeight;
    return tabHeight - 1; // -1 for line drawn across top of tab
}
/**
 * Returns the position of the tab.  Possible values are SWT.TOP or SWT.BOTTOM.
 *
 * @return the position of the tab
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public int getTabPosition(){
    checkWidget();
    return onBottom ? SWT.BOTTOM : SWT.TOP;
}
/**
 * Returns the control in the top right corner of the tab folder.
 * Typically this is a close button or a composite with a menu and close button.
 *
 * @return the control in the top right corner of the tab folder or null
 *
 * @exception  SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 *
 * @since 2.1
 */
public Control getTopRight() {
    checkWidget();
    return topRight;
}
/**
 * Returns <code>true</code> if the close button appears
 * when the user hovers over an unselected tabs.
 *
 * @return <code>true</code> if the close button appears on unselected tabs
 *
 * @since 3.0
 */
public bool getUnselectedCloseVisible() {
    checkWidget();
    return showUnselectedClose;
}
/**
 * Returns <code>true</code> if an image appears
 * in unselected tabs.
 *
 * @return <code>true</code> if an image appears in unselected tabs
 *
 * @since 3.0
 */
public bool getUnselectedImageVisible() {
    checkWidget();
    return showUnselectedImage;
}
/**
 * Return the index of the specified tab or -1 if the tab is not
 * in the receiver.
 *
 * @param item the tab item for which the index is required
 *
 * @return the index of the specified tab item or -1
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 */
public int indexOf(CTabItem item) {
    checkWidget();
    if (item is null) {
        SWT.error(SWT.ERROR_NULL_ARGUMENT);
    }
    for (int i = 0; i < items.length; i++) {
        if (items[i] is item) return i;
    }
    return -1;
}
void initAccessible() {
    Accessible accessible = getAccessible();
    accessible.addAccessibleListener(new class() AccessibleAdapter {
        override
        public void getName(AccessibleEvent e) {
            String name = null;
            int childID = e.childID;
            if (childID >= 0 && childID < items.length) {
                name = stripMnemonic(items[childID].getText());
            } else if (childID is items.length + CHEVRON_CHILD_ID) {
                name = SWT.getMessage("SWT_ShowList"); //$NON-NLS-1$
            } else if (childID is items.length + MINIMIZE_CHILD_ID) {
                name = minimized ? SWT.getMessage("SWT_Restore") : SWT.getMessage("SWT_Minimize"); //$NON-NLS-1$ //$NON-NLS-2$
            } else if (childID is items.length + MAXIMIZE_CHILD_ID) {
                name = maximized ? SWT.getMessage("SWT_Restore") : SWT.getMessage("SWT_Maximize"); //$NON-NLS-1$ //$NON-NLS-2$
            }
            e.result = name;
        }

        override
        public void getHelp(AccessibleEvent e) {
            String help = null;
            int childID = e.childID;
            if (childID is ACC.CHILDID_SELF) {
                help = getToolTipText();
            } else if (childID >= 0 && childID < items.length) {
                help = items[childID].getToolTipText();
            }
            e.result = help;
        }

        override
        public void getKeyboardShortcut(AccessibleEvent e) {
            String shortcut = null;
            int childID = e.childID;
            if (childID >= 0 && childID < items.length) {
                String text = items[childID].getText();
                if (text !is null) {
                    dchar mnemonic = _findMnemonic(text);
                    if (mnemonic !is '\0') {
                        shortcut = "Alt+"~dcharToString(mnemonic); //$NON-NLS-1$
                    }
                }
            }
            e.result = shortcut;
        }
    });

    accessible.addAccessibleControlListener(new class() AccessibleControlAdapter {
        override
        public void getChildAtPoint(AccessibleControlEvent e) {
            Point testPoint = toControl(e.x, e.y);
            int childID = ACC.CHILDID_NONE;
            for (int i = 0; i < items.length; i++) {
                if (items[i].getBounds().contains(testPoint)) {
                    childID = i;
                    break;
                }
            }
            if (childID is ACC.CHILDID_NONE) {
                if (showChevron && chevronRect.contains(testPoint)) {
                    childID = cast(int)/*64bit*/items.length + CHEVRON_CHILD_ID;
                } else if (showMin && minRect.contains(testPoint)) {
                    childID = cast(int)/*64bit*/items.length + MINIMIZE_CHILD_ID;
                } else if (showMax && maxRect.contains(testPoint)) {
                    childID = cast(int)/*64bit*/items.length + MAXIMIZE_CHILD_ID;
                } else {
                    Rectangle location = getBounds();
                    location.height = location.height - getClientArea().height;
                    if (location.contains(testPoint)) {
                        childID = ACC.CHILDID_SELF;
                    }
                }
            }
            e.childID = childID;
        }

        override
        public void getLocation(AccessibleControlEvent e) {
            Rectangle location = null;
            Point pt = null;
            int childID = e.childID;
            if (childID is ACC.CHILDID_SELF) {
                location = getBounds();
                pt = getParent().toDisplay(location.x, location.y);
            } else {
                if (childID >= 0 && childID < items.length && items[childID].isShowing()) {
                    location = items[childID].getBounds();
                } else if (showChevron && childID is items.length + CHEVRON_CHILD_ID) {
                    location = chevronRect;
                } else if (showMin && childID is items.length + MINIMIZE_CHILD_ID) {
                    location = minRect;
                } else if (showMax && childID is items.length + MAXIMIZE_CHILD_ID) {
                    location = maxRect;
                }
                if (location !is null) {
                    pt = toDisplay(location.x, location.y);
                }
            }
            if (location !is null && pt !is null) {
                e.x = pt.x;
                e.y = pt.y;
                e.width = location.width;
                e.height = location.height;
            }
        }

        override
        public void getChildCount(AccessibleControlEvent e) {
            e.detail = cast(int)/*64bit*/items.length + EXTRA_CHILD_ID_COUNT;
        }

        override
        public void getDefaultAction(AccessibleControlEvent e) {
            String action = null;
            int childID = e.childID;
            if (childID >= 0 && childID < items.length) {
                action = SWT.getMessage ("SWT_Switch"); //$NON-NLS-1$
            }
            if (childID >= items.length && childID < items.length + EXTRA_CHILD_ID_COUNT) {
                action = SWT.getMessage ("SWT_Press"); //$NON-NLS-1$
            }
            e.result = action;
        }

        override
        public void getFocus(AccessibleControlEvent e) {
            int childID = ACC.CHILDID_NONE;
            if (isFocusControl()) {
                if (selectedIndex is -1) {
                    childID = ACC.CHILDID_SELF;
                } else {
                    childID = selectedIndex;
                }
            }
            e.childID = childID;
        }

        override
        public void getRole(AccessibleControlEvent e) {
            int role = 0;
            int childID = e.childID;
            if (childID is ACC.CHILDID_SELF) {
                role = ACC.ROLE_TABFOLDER;
            } else if (childID >= 0 && childID < items.length) {
                role = ACC.ROLE_TABITEM;
            } else if (childID >= items.length && childID < items.length + EXTRA_CHILD_ID_COUNT) {
                role = ACC.ROLE_PUSHBUTTON;
            }
            e.detail = role;
        }

        override
        public void getSelection(AccessibleControlEvent e) {
            e.childID = (selectedIndex is -1) ? ACC.CHILDID_NONE : selectedIndex;
        }

        override
        public void getState(AccessibleControlEvent e) {
            int state = 0;
            int childID = e.childID;
            if (childID is ACC.CHILDID_SELF) {
                state = ACC.STATE_NORMAL;
            } else if (childID >= 0 && childID < items.length) {
                state = ACC.STATE_SELECTABLE;
                if (isFocusControl()) {
                    state |= ACC.STATE_FOCUSABLE;
                }
                if (selectedIndex is childID) {
                    state |= ACC.STATE_SELECTED;
                    if (isFocusControl()) {
                        state |= ACC.STATE_FOCUSED;
                    }
                }
            } else if (childID is items.length + CHEVRON_CHILD_ID) {
                state = showChevron ? ACC.STATE_NORMAL : ACC.STATE_INVISIBLE;
            } else if (childID is items.length + MINIMIZE_CHILD_ID) {
                state = showMin ? ACC.STATE_NORMAL : ACC.STATE_INVISIBLE;
            } else if (childID is items.length + MAXIMIZE_CHILD_ID) {
                state = showMax ? ACC.STATE_NORMAL : ACC.STATE_INVISIBLE;
            }
            e.detail = state;
        }

        override
        public void getChildren(AccessibleControlEvent e) {
            int childIdCount = cast(int)/*64bit*/items.length + EXTRA_CHILD_ID_COUNT;
            Object[] children = new Object[childIdCount];
            for (int i = 0; i < childIdCount; i++) {
                children[i] = new Integer(i);
            }
            e.children = children;
        }
    });

    addListener(SWT.Selection, new class(accessible) Listener {
        Accessible acc;
        this( Accessible a ){
            this.acc = a;
        }
        public void handleEvent(Event event) {
            if (isFocusControl()) {
                if (selectedIndex is -1) {
                    acc.setFocus(ACC.CHILDID_SELF);
                } else {
                    acc.setFocus(selectedIndex);
                }
            }
        }
    });

    addListener(SWT.FocusIn, new class(accessible) Listener {
        Accessible acc;
        this( Accessible a ){ this.acc = a; }
        public void handleEvent(Event event) {
            if (selectedIndex is -1) {
                acc.setFocus(ACC.CHILDID_SELF);
            } else {
                acc.setFocus(selectedIndex);
            }
        }
    });
}

void onKeyDown (Event event) {
    switch (event.keyCode) {
        case SWT.ARROW_LEFT:
        case SWT.ARROW_RIGHT:
            auto count = items.length;
            if (count is 0) return;
            if (selectedIndex  is -1) return;
            int leadKey = (getStyle() & SWT.RIGHT_TO_LEFT) !is 0 ? SWT.ARROW_RIGHT : SWT.ARROW_LEFT;
            int offset =  event.keyCode is leadKey ? -1 : 1;
            int index;
            if (!mru) {
                index = selectedIndex + offset;
            } else {
                int[] visible = new int[items.length];
                int idx = 0;
                int current = -1;
                for (int i = 0; i < items.length; i++) {
                    if (items[i].showing) {
                        if (i is selectedIndex) current = idx;
                        visible [idx++] = i;
                    }
                }
                if (current + offset >= 0 && current + offset < idx){
                    index = visible [current + offset];
                } else {
                    if (showChevron) {
                        CTabFolderEvent e = new CTabFolderEvent(this);
                        e.widget = this;
                        e.time = event.time;
                        e.x = chevronRect.x;
                        e.y = chevronRect.y;
                        e.width = chevronRect.width;
                        e.height = chevronRect.height;
                        e.doit = true;
                        for (int i = 0; i < folderListeners.length; i++) {
                            folderListeners[i].showList(e);
                        }
                        if (e.doit && !isDisposed()) {
                            showList(chevronRect);
                        }
                    }
                    return;
                }
            }
            if (index < 0 || index >= count) return;
            setSelection (index, true);
            forceFocus();
            break;
        default:
            break;
    }
}
void onDispose(Event event) {
    removeListener(SWT.Dispose, listener);
    notifyListeners(SWT.Dispose, event);
    event.type = SWT.None;
    /*
     * Usually when an item is disposed, destroyItem will change the size of the items array,
     * reset the bounds of all the tabs and manage the widget associated with the tab.
     * Since the whole folder is being disposed, this is not necessary.  For speed
     * the inDispose flag is used to skip over this part of the item dispose.
     */
    inDispose = true;

    if (showMenu !is null && !showMenu.isDisposed()) {
        showMenu.dispose();
        showMenu = null;
    }
    int length = cast(int)/*64bit*/items.length;
    for (int i = 0; i < length; i++) {
        if (items[i] !is null) {
            items[i].dispose();
        }
    }

    selectionGradientColors = null;
    selectionGradientPercents = null;
    selectionBgImage = null;

    selectionBackground = null;
    selectionForeground = null;
    disposeSelectionHighlightGradientColors();
}
void onDragDetect(Event event) {
    bool consume = false;
    if (chevronRect.contains(event.x, event.y) ||
        minRect.contains(event.x, event.y) ||
        maxRect.contains(event.x, event.y)){
        consume = true;
    } else {
        for (int i = 0; i < items.length; i++) {
            if (items[i].closeRect.contains(event.x, event.y)) {
                    consume = true;
                    break;
            }
        }
    }
    if (consume) {
        event.type = SWT.None;
    }
}
void onFocus(Event event) {
    checkWidget();
    if (selectedIndex >= 0) {
        redraw();
    } else {
        setSelection(0, true);
    }
}
bool onMnemonic (Event event) {
    auto key = event.character;
    for (int i = 0; i < items.length; i++) {
        if (items[i] !is null) {
            auto mnemonic = _findMnemonic (items[i].getText ());
            if (mnemonic !is '\0') {
                if ( CharacterToLower(key) is mnemonic) {
                    setSelection(i, true);
                    return true;
                }
            }
        }
    }
    return false;
}
void onMouseDoubleClick(Event event) {
    if (event.button !is 1 ||
        (event.stateMask & SWT.BUTTON2) !is 0 ||
        (event.stateMask & SWT.BUTTON3) !is 0) return;
    Event e = new Event();
    e.item = getItem(new Point(event.x, event.y));
    if (e.item !is null) {
        notifyListeners(SWT.DefaultSelection, e);
    }
}
void onMouse(Event event) {
    int x = event.x, y = event.y;
    CTabItem item = null;
    switch (event.type) {
        case SWT.MouseEnter: {
            setToolTipText(null);
            break;
        }
        case SWT.MouseExit: {
            if (minImageState !is NORMAL) {
                minImageState = NORMAL;
                redraw(minRect.x, minRect.y, minRect.width, minRect.height, false);
            }
            if (maxImageState !is NORMAL) {
                maxImageState = NORMAL;
                redraw(maxRect.x, maxRect.y, maxRect.width, maxRect.height, false);
            }
            if (chevronImageState !is NORMAL) {
                chevronImageState = NORMAL;
                redraw(chevronRect.x, chevronRect.y, chevronRect.width, chevronRect.height, false);
            }
            for (int i=0; i<items.length; i++) {
                item = items[i];
                if (i !is selectedIndex && item.closeImageState !is NONE) {
                    item.closeImageState = NONE;
                    redraw(item.closeRect.x, item.closeRect.y, item.closeRect.width, item.closeRect.height, false);
                }
                if (i is selectedIndex && item.closeImageState !is NORMAL) {
                    item.closeImageState = NORMAL;
                    redraw(item.closeRect.x, item.closeRect.y, item.closeRect.width, item.closeRect.height, false);
                }
            }
            break;
        }
        case SWT.MouseDown: {
            if (minRect.contains(x, y)) {
                if (event.button !is 1) return;
                minImageState = SELECTED;
                redraw(minRect.x, minRect.y, minRect.width, minRect.height, false);
                update();
                return;
            }
            if (maxRect.contains(x, y)) {
                if (event.button !is 1) return;
                maxImageState = SELECTED;
                redraw(maxRect.x, maxRect.y, maxRect.width, maxRect.height, false);
                update();
                return;
            }
            if (chevronRect.contains(x, y)) {
                if (event.button !is 1) return;
                if (chevronImageState !is HOT) {
                    chevronImageState = HOT;
                } else {
                    chevronImageState = SELECTED;
                }
                redraw(chevronRect.x, chevronRect.y, chevronRect.width, chevronRect.height, false);
                update();
                return;
            }
            item = null;
            if (single) {
                if (selectedIndex !is -1) {
                    Rectangle bounds = items[selectedIndex].getBounds();
                    if (bounds.contains(x, y)){
                        item = items[selectedIndex];
                    }
                }
            } else {
                for (int i=0; i<items.length; i++) {
                    Rectangle bounds = items[i].getBounds();
                    if (bounds.contains(x, y)){
                        item = items[i];
                    }
                }
            }
            if (item !is null) {
                if (item.closeRect.contains(x,y)){
                    if (event.button !is 1) return;
                    item.closeImageState = SELECTED;
                    redraw(item.closeRect.x, item.closeRect.y, item.closeRect.width, item.closeRect.height, false);
                    update();
                    return;
                }
                int index = indexOf(item);
                if (item.showing){
                    setSelection(index, true);
                }
                return;
            }
            break;
        }
        case SWT.MouseMove: {
            _setToolTipText(event.x, event.y);
            bool close = false, minimize = false, maximize = false, chevron = false;
            if (minRect.contains(x, y)) {
                minimize = true;
                if (minImageState !is SELECTED && minImageState !is HOT) {
                    minImageState = HOT;
                    redraw(minRect.x, minRect.y, minRect.width, minRect.height, false);
                }
            }
            if (maxRect.contains(x, y)) {
                maximize = true;
                if (maxImageState !is SELECTED && maxImageState !is HOT) {
                    maxImageState = HOT;
                    redraw(maxRect.x, maxRect.y, maxRect.width, maxRect.height, false);
                }
            }
            if (chevronRect.contains(x, y)) {
                chevron = true;
                if (chevronImageState !is SELECTED && chevronImageState !is HOT) {
                    chevronImageState = HOT;
                    redraw(chevronRect.x, chevronRect.y, chevronRect.width, chevronRect.height, false);
                }
            }
            if (minImageState !is NORMAL && !minimize) {
                minImageState = NORMAL;
                redraw(minRect.x, minRect.y, minRect.width, minRect.height, false);
            }
            if (maxImageState !is NORMAL && !maximize) {
                maxImageState = NORMAL;
                redraw(maxRect.x, maxRect.y, maxRect.width, maxRect.height, false);
            }
            if (chevronImageState !is NORMAL && !chevron) {
                chevronImageState = NORMAL;
                redraw(chevronRect.x, chevronRect.y, chevronRect.width, chevronRect.height, false);
            }
            for (int i=0; i<items.length; i++) {
                item = items[i];
                close = false;
                if (item.getBounds().contains(x, y)) {
                    close = true;
                    if (item.closeRect.contains(x, y)) {
                        if (item.closeImageState !is SELECTED && item.closeImageState !is HOT) {
                            item.closeImageState = HOT;
                            redraw(item.closeRect.x, item.closeRect.y, item.closeRect.width, item.closeRect.height, false);
                        }
                    } else {
                        if (item.closeImageState !is NORMAL) {
                            item.closeImageState = NORMAL;
                            redraw(item.closeRect.x, item.closeRect.y, item.closeRect.width, item.closeRect.height, false);
                        }
                    }
                }
                if (i !is selectedIndex && item.closeImageState !is NONE && !close) {
                    item.closeImageState = NONE;
                    redraw(item.closeRect.x, item.closeRect.y, item.closeRect.width, item.closeRect.height, false);
                }
                if (i is selectedIndex && item.closeImageState !is NORMAL && !close) {
                    item.closeImageState = NORMAL;
                    redraw(item.closeRect.x, item.closeRect.y, item.closeRect.width, item.closeRect.height, false);
                }
            }
            break;
        }
        case SWT.MouseUp: {
            if (event.button !is 1) return;
            if (chevronRect.contains(x, y)) {
                bool selected = chevronImageState is SELECTED;
                if (!selected) return;
                CTabFolderEvent e = new CTabFolderEvent(this);
                e.widget = this;
                e.time = event.time;
                e.x = chevronRect.x;
                e.y = chevronRect.y;
                e.width = chevronRect.width;
                e.height = chevronRect.height;
                e.doit = true;
                for (int i = 0; i < folderListeners.length; i++) {
                    folderListeners[i].showList(e);
                }
                if (e.doit && !isDisposed()) {
                    showList(chevronRect);
                }
                return;
            }
            if (minRect.contains(x, y)) {
                bool selected = minImageState is SELECTED;
                minImageState = HOT;
                redraw(minRect.x, minRect.y, minRect.width, minRect.height, false);
                if (!selected) return;
                CTabFolderEvent e = new CTabFolderEvent(this);
                e.widget = this;
                e.time = event.time;
                for (int i = 0; i < folderListeners.length; i++) {
                    if (minimized) {
                        folderListeners[i].restore(e);
                    } else {
                        folderListeners[i].minimize(e);
                    }
                }
                return;
            }
            if (maxRect.contains(x, y)) {
                bool selected = maxImageState is SELECTED;
                maxImageState = HOT;
                redraw(maxRect.x, maxRect.y, maxRect.width, maxRect.height, false);
                if (!selected) return;
                CTabFolderEvent e = new CTabFolderEvent(this);
                e.widget = this;
                e.time = event.time;
                for (int i = 0; i < folderListeners.length; i++) {
                    if (maximized) {
                        folderListeners[i].restore(e);
                    } else {
                        folderListeners[i].maximize(e);
                    }
                }
                return;
            }
            item = null;
            if (single) {
                if (selectedIndex !is -1) {
                    Rectangle bounds = items[selectedIndex].getBounds();
                    if (bounds.contains(x, y)){
                        item = items[selectedIndex];
                    }
                }
            } else {
                for (int i=0; i<items.length; i++) {
                    Rectangle bounds = items[i].getBounds();
                    if (bounds.contains(x, y)){
                        item = items[i];
                    }
                }
            }
            if (item !is null) {
                if (item.closeRect.contains(x,y)) {
                    bool selected = item.closeImageState is SELECTED;
                    item.closeImageState = HOT;
                    redraw(item.closeRect.x, item.closeRect.y, item.closeRect.width, item.closeRect.height, false);
                    if (!selected) return;
                    CTabFolderEvent e = new CTabFolderEvent(this);
                    e.widget = this;
                    e.time = event.time;
                    e.item = item;
                    e.doit = true;
                    for (int j = 0; j < folderListeners.length; j++) {
                        CTabFolder2Listener listener = folderListeners[j];
                        listener.close(e);
                    }
                    for (int j = 0; j < tabListeners.length; j++) {
                        CTabFolderListener listener = tabListeners[j];
                        listener.itemClosed(e);
                    }
                    if (e.doit) item.dispose();
                    if (!isDisposed() && item.isDisposed()) {
                        Display display = getDisplay();
                        Point pt = display.getCursorLocation();
                        pt = display.map(null, this, pt.x, pt.y);
                        CTabItem nextItem = getItem(pt);
                        if (nextItem !is null) {
                            if (nextItem.closeRect.contains(pt)) {
                                if (nextItem.closeImageState !is SELECTED && nextItem.closeImageState !is HOT) {
                                    nextItem.closeImageState = HOT;
                                    redraw(nextItem.closeRect.x, nextItem.closeRect.y, nextItem.closeRect.width, nextItem.closeRect.height, false);
                                }
                            } else {
                                if (nextItem.closeImageState !is NORMAL) {
                                    nextItem.closeImageState = NORMAL;
                                    redraw(nextItem.closeRect.x, nextItem.closeRect.y, nextItem.closeRect.width, nextItem.closeRect.height, false);
                                }
                            }
                        }
                    }
                    return;
                }
            }
        default:
        }
    }
}
bool onPageTraversal(Event event) {
    auto count = items.length;
    if (count is 0) return false;
    size_t index = selectedIndex;
    if (index  is -1) {
        index = 0;
    } else {
        int offset = (event.detail is SWT.TRAVERSE_PAGE_NEXT) ? 1 : -1;
        if (!mru) {
            index = (selectedIndex + offset + count) % count;
        } else {
            int[] visible = new int[items.length];
            int idx = 0;
            int current = -1;
            for (int i = 0; i < items.length; i++) {
                if (items[i].showing) {
                    if (i is selectedIndex) current = idx;
                    visible [idx++] = i;
                }
            }
            if (current + offset >= 0 && current + offset < idx){
                index = visible [current + offset];
            } else {
                if (showChevron) {
                    CTabFolderEvent e = new CTabFolderEvent(this);
                    e.widget = this;
                    e.time = event.time;
                    e.x = chevronRect.x;
                    e.y = chevronRect.y;
                    e.width = chevronRect.width;
                    e.height = chevronRect.height;
                    e.doit = true;
                    for (int i = 0; i < folderListeners.length; i++) {
                        folderListeners[i].showList(e);
                    }
                    if (e.doit && !isDisposed()) {
                        showList(chevronRect);
                    }
                }
                return true;
            }
        }
    }
    setSelection (cast(int)/*64bit*/index, true);
    return true;
}
void onPaint(Event event) {
    if (inDispose) return;
    Font font = getFont();
    if (oldFont is null || oldFont!=font) {
        // handle case where  default font changes
        oldFont = font;
        if (!updateTabHeight(false)) {
            updateItems();
            redraw();
            return;
        }
    }

    GC gc = event.gc;
    Font gcFont = gc.getFont();
    Color gcBackground = gc.getBackground();
    Color gcForeground = gc.getForeground();

// Useful for debugging paint problems
//{
//Point size = getSize();
//gc.setBackground(getDisplay().getSystemColor(SWT.COLOR_GREEN));
//gc.fillRectangle(-10, -10, size.x + 20, size.y+20);
//}

    drawBody(event);

    gc.setFont(gcFont);
    gc.setForeground(gcForeground);
    gc.setBackground(gcBackground);

    drawTabArea(event);

    gc.setFont(gcFont);
    gc.setForeground(gcForeground);
    gc.setBackground(gcBackground);
}

void onResize() {
    if (updateItems()) redrawTabs();

    Point size = getSize();
    if (oldSize is null) {
        redraw();
    } else {
        if (onBottom && size.y !is oldSize.y) {
            redraw();
        } else {
            int x1 = Math.min(size.x, oldSize.x);
            if (size.x !is oldSize.x) x1 -= borderRight + highlight_margin + 2;
            if (!simple) x1 -= 5; // rounded top right corner
            int y1 = Math.min(size.y, oldSize.y);
            if (size.y !is oldSize.y) y1 -= borderBottom + highlight_margin;
            int x2 = Math.max(size.x, oldSize.x);
            int y2 = Math.max(size.y, oldSize.y);
            redraw(0, y1, x2, y2 - y1, false);
            redraw(x1, 0, x2 - x1, y2, false);
        }
    }
    oldSize = size;
}
void onTraverse (Event event) {
    switch (event.detail) {
        case SWT.TRAVERSE_ESCAPE:
        case SWT.TRAVERSE_RETURN:
        case SWT.TRAVERSE_TAB_NEXT:
        case SWT.TRAVERSE_TAB_PREVIOUS:
            Control focusControl = getDisplay().getFocusControl();
            if (focusControl is this) event.doit = true;
            break;
        case SWT.TRAVERSE_MNEMONIC:
            event.doit = onMnemonic(event);
            if (event.doit) event.detail = SWT.TRAVERSE_NONE;
            break;
        case SWT.TRAVERSE_PAGE_NEXT:
        case SWT.TRAVERSE_PAGE_PREVIOUS:
            event.doit = onPageTraversal(event);
            event.detail = SWT.TRAVERSE_NONE;
            break;
        default:
    }
}
void redrawTabs() {
    Point size = getSize();
    if (onBottom) {
        redraw(0, size.y - borderBottom - tabHeight - highlight_header - 1, size.x, borderBottom + tabHeight + highlight_header + 1, false);
    } else {
        redraw(0, 0, size.x, borderTop + tabHeight + highlight_header + 1, false);
    }
}
/**
 * Removes the listener.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @see #addCTabFolder2Listener(CTabFolder2Listener)
 *
 * @since 3.0
 */
public void removeCTabFolder2Listener(CTabFolder2Listener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (folderListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < folderListeners.length; i++) {
        if (listener is folderListeners[i]){
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (folderListeners.length is 1) {
        folderListeners = new CTabFolder2Listener[0];
        return;
    }
    CTabFolder2Listener[] newTabListeners = new CTabFolder2Listener[folderListeners.length - 1];
    SimpleType!(CTabFolder2Listener).arraycopy(folderListeners, 0, newTabListeners, 0, index);
    SimpleType!(CTabFolder2Listener).arraycopy(folderListeners, index + 1, newTabListeners, index, folderListeners.length - index - 1);
    folderListeners = newTabListeners;
}
/**
 * Removes the listener.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @deprecated see removeCTabFolderCloseListener(CTabFolderListener)
 */
public void removeCTabFolderListener(CTabFolderListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (tabListeners.length is 0) return;
    int index = -1;
    for (int i = 0; i < tabListeners.length; i++) {
        if (listener is tabListeners[i]){
            index = i;
            break;
        }
    }
    if (index is -1) return;
    if (tabListeners.length is 1) {
        tabListeners = new CTabFolderListener[0];
        return;
    }
    CTabFolderListener[] newTabListeners = new CTabFolderListener[tabListeners.length - 1];
    SimpleType!(CTabFolderListener).arraycopy(tabListeners, 0, newTabListeners, 0, index);
    SimpleType!(CTabFolderListener).arraycopy(tabListeners, index + 1, newTabListeners, index, tabListeners.length - index - 1);
    tabListeners = newTabListeners;
}
/**
 * Removes the listener from the collection of listeners who will
 * be notified when the user changes the receiver's selection.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SelectionListener
 * @see #addSelectionListener
 */
public void removeSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) {
        SWT.error(SWT.ERROR_NULL_ARGUMENT);
    }
    removeListener(SWT.Selection, listener);
    removeListener(SWT.DefaultSelection, listener);
}
public override void setBackground (Color color) {
    super.setBackground(color);
    redraw();
}
/**
 * Specify a gradient of colours to be drawn in the background of the unselected tabs.
 * For example to draw a gradient that varies from dark blue to blue and then to
 * white, use the following call to setBackground:
 * <pre>
 *  cfolder.setBackground(new Color[]{display.getSystemColor(SWT.COLOR_DARK_BLUE),
 *                                 display.getSystemColor(SWT.COLOR_BLUE),
 *                                 display.getSystemColor(SWT.COLOR_WHITE),
 *                                 display.getSystemColor(SWT.COLOR_WHITE)},
 *                     new int[] {25, 50, 100});
 * </pre>
 *
 * @param colors an array of Color that specifies the colors to appear in the gradient
 *               in order of appearance left to right.  The value <code>null</code> clears the
 *               background gradient. The value <code>null</code> can be used inside the array of
 *               Color to specify the background color.
 * @param percents an array of integers between 0 and 100 specifying the percent of the width
 *                 of the widget at which the color should change.  The size of the percents array must be one
 *                 less than the size of the colors array.
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 *
 * @since 3.0
 */
void setBackground(Color[] colors, int[] percents) {
    setBackground(colors, percents, false);
}
/**
 * Specify a gradient of colours to be drawn in the background of the unselected tab.
 * For example to draw a vertical gradient that varies from dark blue to blue and then to
 * white, use the following call to setBackground:
 * <pre>
 *  cfolder.setBackground(new Color[]{display.getSystemColor(SWT.COLOR_DARK_BLUE),
 *                                 display.getSystemColor(SWT.COLOR_BLUE),
 *                                 display.getSystemColor(SWT.COLOR_WHITE),
 *                                 display.getSystemColor(SWT.COLOR_WHITE)},
 *                        new int[] {25, 50, 100}, true);
 * </pre>
 *
 * @param colors an array of Color that specifies the colors to appear in the gradient
 *               in order of appearance left to right.  The value <code>null</code> clears the
 *               background gradient. The value <code>null</code> can be used inside the array of
 *               Color to specify the background color.
 * @param percents an array of integers between 0 and 100 specifying the percent of the width
 *                 of the widget at which the color should change.  The size of the percents array must be one
 *                 less than the size of the colors array.
 *
 * @param vertical indicate the direction of the gradient.  True is vertical and false is horizontal.
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 *
 * @since 3.0
 */
void setBackground(Color[] colors, int[] percents, bool vertical) {
    checkWidget();
    if (colors !is null) {
        if (percents is null || percents.length !is colors.length - 1) {
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        }
        for (int i = 0; i < percents.length; i++) {
            if (percents[i] < 0 || percents[i] > 100) {
                SWT.error(SWT.ERROR_INVALID_ARGUMENT);
            }
            if (i > 0 && percents[i] < percents[i-1]) {
                SWT.error(SWT.ERROR_INVALID_ARGUMENT);
            }
        }
        if (getDisplay().getDepth() < 15) {
            // Don't use gradients on low color displays
            colors = [colors[colors.length - 1]];
            percents = null;
        }
    }

    // Are these settings the same as before?
    if (bgImage is null) {
        if ((gradientColors !is null) && (colors !is null) &&
            (gradientColors.length is colors.length)) {
            bool same = false;
            for (int i = 0; i < gradientColors.length; i++) {
                if (gradientColors[i] is null) {
                    same = colors[i] is null;
                } else {
                    same = cast(bool)(gradientColors[i]==colors[i]);
                }
                if (!same) break;
            }
            if (same) {
                for (int i = 0; i < gradientPercents.length; i++) {
                    same = gradientPercents[i] is percents[i];
                    if (!same) break;
                }
            }
            if (same && this.gradientVertical is vertical) return;
        }
    } else {
        bgImage = null;
    }
    // Store the new settings
    if (colors is null) {
        gradientColors = null;
        gradientPercents = null;
        gradientVertical = false;
        setBackground(cast(Color)null);
    } else {
        gradientColors = new Color[colors.length];
        for (int i = 0; i < colors.length; ++i) {
            gradientColors[i] = colors[i];
        }
        gradientPercents = new int[percents.length];
        for (int i = 0; i < percents.length; ++i) {
            gradientPercents[i] = percents[i];
        }
        gradientVertical = vertical;
        setBackground(gradientColors[gradientColors.length-1]);
    }

    // Refresh with the new settings
    redraw();
}

/**
 * Set the image to be drawn in the background of the unselected tab.  Image
 * is stretched or compressed to cover entire unselected tab area.
 *
 * @param image the image to be drawn in the background
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
void setBackground(Image image) {
    checkWidget();
    if (image is bgImage) return;
    if (image !is null) {
        gradientColors = null;
        gradientPercents = null;
    }
    bgImage = image;
    redraw();
}
/**
 * Toggle the visibility of the border
 *
 * @param show true if the border should be displayed
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setBorderVisible(bool show) {
    checkWidget();
    if ((borderLeft is 1) is show) return;
    borderLeft = borderRight = show ? 1 : 0;
    borderTop = onBottom ? borderLeft : 0;
    borderBottom = onBottom ? 0 : borderLeft;
    Rectangle rectBefore = getClientArea();
    updateItems();
    Rectangle rectAfter = getClientArea();
    if (rectBefore!=rectAfter) {
        notifyListeners(SWT.Resize, new Event());
    }
    redraw();
}
void setButtonBounds() {
    Point size = getSize();
    int oldX, oldY, oldWidth, oldHeight;
    // max button
    oldX = maxRect.x;
    oldY = maxRect.y;
    oldWidth = maxRect.width;
    oldHeight = maxRect.height;
    maxRect.x = maxRect.y = maxRect.width = maxRect.height = 0;
    if (showMax) {
        maxRect.x = size.x - borderRight - BUTTON_SIZE - 3;
        if (borderRight > 0) maxRect.x += 1;
        maxRect.y = onBottom ? size.y - borderBottom - tabHeight + (tabHeight - BUTTON_SIZE)/2: borderTop + (tabHeight - BUTTON_SIZE)/2;
        maxRect.width = BUTTON_SIZE;
        maxRect.height = BUTTON_SIZE;
    }
    if (oldX !is maxRect.x || oldWidth !is maxRect.width ||
        oldY !is maxRect.y || oldHeight !is maxRect.height) {
        int left = Math.min(oldX, maxRect.x);
        int right = Math.max(oldX + oldWidth, maxRect.x + maxRect.width);
        int top = onBottom ? size.y - borderBottom - tabHeight: borderTop + 1;
        redraw(left, top, right - left, tabHeight, false);
    }

    // min button
    oldX = minRect.x;
    oldY = minRect.y;
    oldWidth = minRect.width;
    oldHeight = minRect.height;
    minRect.x = minRect.y = minRect.width = minRect.height = 0;
    if (showMin) {
        minRect.x = size.x - borderRight - maxRect.width - BUTTON_SIZE - 3;
        if (borderRight > 0) minRect.x += 1;
        minRect.y = onBottom ? size.y - borderBottom - tabHeight + (tabHeight - BUTTON_SIZE)/2: borderTop + (tabHeight - BUTTON_SIZE)/2;
        minRect.width = BUTTON_SIZE;
        minRect.height = BUTTON_SIZE;
    }
    if (oldX !is minRect.x || oldWidth !is minRect.width ||
        oldY !is minRect.y || oldHeight !is minRect.height) {
        int left = Math.min(oldX, minRect.x);
        int right = Math.max(oldX + oldWidth, minRect.x + minRect.width);
        int top = onBottom ? size.y - borderBottom - tabHeight: borderTop + 1;
        redraw(left, top, right - left, tabHeight, false);
    }

    // top right control
    oldX = topRightRect.x;
    oldY = topRightRect.y;
    oldWidth = topRightRect.width;
    oldHeight = topRightRect.height;
    topRightRect.x = topRightRect.y = topRightRect.width = topRightRect.height = 0;
    if (topRight !is null) {
        CTabItem item = null;
        switch (topRightAlignment) {
            case SWT.FILL: {
                int rightEdge = size.x - borderRight - 3 - maxRect.width - minRect.width;
                if (!simple && borderRight > 0 && !showMax && !showMin) rightEdge -= 2;
                if (single) {
                    if (items.length is 0 || selectedIndex is -1) {
                        topRightRect.x = borderLeft + 3;
                        topRightRect.width = rightEdge - topRightRect.x;
                    } else {
                        // fill size is 0 if item compressed
                        item = items[selectedIndex];
                        if (item.x + item.width + 7 + 3*BUTTON_SIZE/2 >= rightEdge) break;
                        topRightRect.x = item.x + item.width + 7 + 3*BUTTON_SIZE/2;
                        topRightRect.width = rightEdge - topRightRect.x;
                    }
                } else {
                    // fill size is 0 if chevron showing
                    if (showChevron) break;
                    if (items.length is 0) {
                        topRightRect.x = borderLeft + 3;
                    } else {
                        item = items[items.length - 1];
                        topRightRect.x = item.x + item.width;
                        if (!simple && items.length - 1 is selectedIndex) topRightRect.x += curveWidth - curveIndent;
                    }
                    topRightRect.width = Math.max(0, rightEdge - topRightRect.x);
                }
                topRightRect.y = onBottom ? size.y - borderBottom - tabHeight: borderTop + 1;
                topRightRect.height = tabHeight - 1;
                break;
            }
            case SWT.RIGHT: {
                Point topRightSize = topRight.computeSize(SWT.DEFAULT, tabHeight, false);
                int rightEdge = size.x - borderRight - 3 - maxRect.width - minRect.width;
                if (!simple && borderRight > 0 && !showMax && !showMin) rightEdge -= 2;
                topRightRect.x = rightEdge - topRightSize.x;
                topRightRect.width = topRightSize.x;
                topRightRect.y = onBottom ? size.y - borderBottom - tabHeight: borderTop + 1;
                topRightRect.height = tabHeight - 1;
                break;
            }
            default:
                break;
        }
        topRight.setBounds(topRightRect);
    }
    if (oldX !is topRightRect.x || oldWidth !is topRightRect.width ||
        oldY !is topRightRect.y || oldHeight !is topRightRect.height) {
        int left = Math.min(oldX, topRightRect.x);
        int right = Math.max(oldX + oldWidth, topRightRect.x + topRightRect.width);
        int top = onBottom ? size.y - borderBottom - tabHeight : borderTop + 1;
        redraw(left, top, right - left, tabHeight, false);
    }

    // chevron button
    oldX = chevronRect.x;
    oldY = chevronRect.y;
    oldWidth = chevronRect.width;
    oldHeight = chevronRect.height;
    chevronRect.x = chevronRect.y = chevronRect.height = chevronRect.width = 0;
    if (single) {
        if (selectedIndex is -1 || items.length > 1) {
            chevronRect.width = 3*BUTTON_SIZE/2;
            chevronRect.height = BUTTON_SIZE;
            chevronRect.y = onBottom ? size.y - borderBottom - tabHeight + (tabHeight - chevronRect.height)/2 : borderTop + (tabHeight - chevronRect.height)/2;
            if (selectedIndex is -1) {
                chevronRect.x = size.x - borderRight - 3 - minRect.width - maxRect.width - topRightRect.width - chevronRect.width;
            } else {
                CTabItem item = items[selectedIndex];
                int w = size.x - borderRight - 3 - minRect.width - maxRect.width - chevronRect.width;
                if (topRightRect.width > 0) w -= topRightRect.width + 3;
                chevronRect.x = Math.min(item.x + item.width + 3, w);
            }
            if (borderRight > 0) chevronRect.x += 1;
        }
    } else {
        if (showChevron) {
            chevronRect.width = 3*BUTTON_SIZE/2;
            chevronRect.height = BUTTON_SIZE;
            int i = 0, lastIndex = -1;
            while (i < priority.length && items[priority[i]].showing) {
                lastIndex = Math.max(lastIndex, priority[i++]);
            }
            if (lastIndex is -1) lastIndex = firstIndex;
            CTabItem lastItem = items[lastIndex];
            int w = lastItem.x + lastItem.width + 3;
            if (!simple && lastIndex is selectedIndex) w += curveWidth - 2*curveIndent;
            chevronRect.x = Math.min(w, getRightItemEdge());
            chevronRect.y = onBottom ? size.y - borderBottom - tabHeight + (tabHeight - chevronRect.height)/2 : borderTop + (tabHeight - chevronRect.height)/2;
        }
    }
    if (oldX !is chevronRect.x || oldWidth !is chevronRect.width ||
        oldY !is chevronRect.y || oldHeight !is chevronRect.height) {
        int left = Math.min(oldX, chevronRect.x);
        int right = Math.max(oldX + oldWidth, chevronRect.x + chevronRect.width);
        int top = onBottom ? size.y - borderBottom - tabHeight: borderTop + 1;
        redraw(left, top, right - left, tabHeight, false);
    }
}
public override void setFont(Font font) {
    checkWidget();
    if (font !is null && font==getFont()) return;
    super.setFont(font);
    oldFont = getFont();
    if (!updateTabHeight(false)) {
        updateItems();
        redraw();
    }
}
public override void setForeground (Color color) {
    super.setForeground(color);
    redraw();
}
/**
 * Display an insert marker before or after the specified tab item.
 *
 * A value of null will clear the mark.
 *
 * @param item the item with which the mark is associated or null
 *
 * @param after true if the mark should be displayed after the specified item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setInsertMark(CTabItem item, bool after) {
    checkWidget();
}
/**
 * Display an insert marker before or after the specified tab item.
 *
 * A value of -1 will clear the mark.
 *
 * @param index the index of the item with which the mark is associated or null
 *
 * @param after true if the mark should be displayed after the specified item
 *
 * @exception IllegalArgumentException<ul>
 * </ul>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setInsertMark(int index, bool after) {
    checkWidget();
    if (index < -1 || index >= getItemCount()) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
}
bool setItemLocation() {
    bool changed = false;
    if (items.length is 0) return false;
    Point size = getSize();
    int y = onBottom ? Math.max(borderBottom, size.y - borderBottom - tabHeight) : borderTop;
    if (single) {
        int defaultX = getDisplay().getBounds().width + 10; // off screen
        for (int i = 0; i < items.length; i++) {
            CTabItem item = items[i];
            if (i is selectedIndex) {
                firstIndex = selectedIndex;
                int oldX = item.x, oldY = item.y;
                item.x = borderLeft;
                item.y = y;
                item.showing = true;
                if (showClose || item.showClose) {
                    item.closeRect.x = borderLeft + CTabItem.LEFT_MARGIN;
                    item.closeRect.y = onBottom ? size.y - borderBottom - tabHeight + (tabHeight - BUTTON_SIZE)/2: borderTop + (tabHeight - BUTTON_SIZE)/2;
                }
                if (item.x !is oldX || item.y !is oldY) changed = true;
            } else {
                item.x = defaultX;
                item.showing = false;
            }
        }
    } else {
        int rightItemEdge = getRightItemEdge();
        int maxWidth = rightItemEdge - borderLeft;
        int width = 0;
        for (int i = 0; i < priority.length; i++) {
            CTabItem item = items[priority[i]];
            width += item.width;
            item.showing = i is 0 ? true : item.width > 0 && width <= maxWidth;
            if (!simple && priority[i] is selectedIndex) width += curveWidth - 2*curveIndent;
        }
        int x = 0;
        int defaultX = getDisplay().getBounds().width + 10; // off screen
        firstIndex = cast(int)/*64bit*/items.length - 1;
        for (int i = 0; i < items.length; i++) {
            CTabItem item = items[i];
            if (!item.showing) {
                if (item.x !is defaultX) changed = true;
                item.x = defaultX;
            } else {
                firstIndex = Math.min(firstIndex, i);
                if (item.x !is x || item.y !is y) changed = true;
                item.x = x;
                item.y = y;
                if (i is selectedIndex) {
                    int edge = Math.min(item.x + item.width, rightItemEdge);
                    item.closeRect.x = edge - CTabItem.RIGHT_MARGIN - BUTTON_SIZE;
                } else {
                    item.closeRect.x = item.x + item.width - CTabItem.RIGHT_MARGIN - BUTTON_SIZE;
                }
                item.closeRect.y = onBottom ? size.y - borderBottom - tabHeight + (tabHeight - BUTTON_SIZE)/2: borderTop + (tabHeight - BUTTON_SIZE)/2;
                x = x + item.width;
                if (!simple && i is selectedIndex) x += curveWidth - 2*curveIndent;
            }
        }
    }
    return changed;
}
bool setItemSize() {
    bool changed = false;
    if (isDisposed()) return changed;
    Point size = getSize();
    if (size.x <= 0 || size.y <= 0) return changed;
    xClient = borderLeft + marginWidth + highlight_margin;
    if (onBottom) {
        yClient = borderTop + highlight_margin + marginHeight;
    } else {
        yClient = borderTop + tabHeight + highlight_header + marginHeight;
    }
    showChevron = false;
    if (single) {
        showChevron = true;
        if (selectedIndex !is -1) {
            CTabItem tab = items[selectedIndex];
            GC gc = new GC(this);
            int width = tab.preferredWidth(gc, true, false);
            gc.dispose();
            width = Math.min(width, getRightItemEdge() - borderLeft);
            if (tab.height !is tabHeight || tab.width !is width) {
                changed = true;
                tab.shortenedText = null;
                tab.shortenedTextWidth = 0;
                tab.height = tabHeight;
                tab.width = width;
                tab.closeRect.width = tab.closeRect.height = 0;
                if (showClose || tab.showClose) {
                    tab.closeRect.width = BUTTON_SIZE;
                    tab.closeRect.height = BUTTON_SIZE;
                }
            }
        }
        return changed;
    }

    if (items.length is 0) return changed;

    int[] widths;
    GC gc = new GC(this);
    int tabAreaWidth = size.x - borderLeft - borderRight - 3;
    if (showMin) tabAreaWidth -= BUTTON_SIZE;
    if (showMax) tabAreaWidth -= BUTTON_SIZE;
    if (topRightAlignment is SWT.RIGHT && topRight !is null) {
        Point rightSize = topRight.computeSize(SWT.DEFAULT, SWT.DEFAULT, false);
        tabAreaWidth -= rightSize.x + 3;
    }
    if (!simple) tabAreaWidth -= curveWidth - 2*curveIndent;
    tabAreaWidth = Math.max(0, tabAreaWidth);

    // First, try the minimum tab size at full compression.
    int minWidth = 0;
    int[] minWidths = new int[items.length];
    for (int i = 0; i < priority.length; i++) {
        int index = priority[i];
        minWidths[index] = items[index].preferredWidth(gc, index is selectedIndex, true);
        minWidth += minWidths[index];
        if (minWidth > tabAreaWidth) break;
    }
    if (minWidth > tabAreaWidth) {
        // full compression required and a chevron
        showChevron = items.length > 1;
        if (showChevron) tabAreaWidth -= 3*BUTTON_SIZE/2;
        widths = minWidths;
        int index = selectedIndex !is -1 ? selectedIndex : 0;
        if (tabAreaWidth < widths[index]) {
            widths[index] = Math.max(0, tabAreaWidth);
        }
    } else {
        int maxWidth = 0;
        int[] maxWidths = new int[items.length];
        for (int i = 0; i < items.length; i++) {
            maxWidths[i] = items[i].preferredWidth(gc, i is selectedIndex, false);
            maxWidth += maxWidths[i];
        }
        if (maxWidth <= tabAreaWidth) {
            // no compression required
            widths = maxWidths;
        } else {
            // determine compression for each item
            auto extra = (tabAreaWidth - minWidth) / items.length;
            while (true) {
                int large = 0, totalWidth = 0;
                for (int i = 0 ; i < items.length; i++) {
                    if (maxWidths[i] > minWidths[i] + extra) {
                        totalWidth += minWidths[i] + extra;
                        large++;
                    } else {
                        totalWidth += maxWidths[i];
                    }
                }
                if (totalWidth >= tabAreaWidth) {
                    extra--;
                    break;
                }
                if (large is 0 || tabAreaWidth - totalWidth < large) break;
                extra++;
            }
            widths = new int[items.length];
            for (int i = 0; i < items.length; i++) {
                widths[i] = cast(int)/*64bit*/Math.min
                                   (maxWidths[i], minWidths[i] + extra);
            }
        }
    }
    gc.dispose();

    for (int i = 0; i < items.length; i++) {
        CTabItem tab = items[i];
        int width = widths[i];
        if (tab.height !is tabHeight || tab.width !is width) {
            changed = true;
            tab.shortenedText = null;
            tab.shortenedTextWidth = 0;
            tab.height = tabHeight;
            tab.width = width;
            tab.closeRect.width = tab.closeRect.height = 0;
            if (showClose || tab.showClose) {
                if (i is selectedIndex || showUnselectedClose) {
                    tab.closeRect.width = BUTTON_SIZE;
                    tab.closeRect.height = BUTTON_SIZE;
                }
            }
        }
    }
    return changed;
}
/**
 * Marks the receiver's maximize button as visible if the argument is <code>true</code>,
 * and marks it invisible otherwise.
 *
 * @param visible the new visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setMaximizeVisible(bool visible) {
    checkWidget();
    if (showMax is visible) return;
    // display maximize button
    showMax = visible;
    updateItems();
    redraw();
}
/**
 * Sets the layout which is associated with the receiver to be
 * the argument which may be null.
 * <p>
 * Note: No Layout can be set on this Control because it already
 * manages the size and position of its children.
 * </p>
 *
 * @param layout the receiver's new layout or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override void setLayout (Layout layout) {
    checkWidget();
    return;
}
/**
 * Sets the maximized state of the receiver.
 *
 * @param maximize the new maximized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setMaximized(bool maximize) {
    checkWidget ();
    if (this.maximized is maximize) return;
    if (maximize && this.minimized) setMinimized(false);
    this.maximized = maximize;
    redraw(maxRect.x, maxRect.y, maxRect.width, maxRect.height, false);
}
/**
 * Marks the receiver's minimize button as visible if the argument is <code>true</code>,
 * and marks it invisible otherwise.
 *
 * @param visible the new visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setMinimizeVisible(bool visible) {
    checkWidget();
    if (showMin is visible) return;
    // display minimize button
    showMin = visible;
    updateItems();
    redraw();
}
/**
 * Sets the minimized state of the receiver.
 *
 * @param minimize the new minimized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setMinimized(bool minimize) {
    checkWidget ();
    if (this.minimized is minimize) return;
    if (minimize && this.maximized) setMaximized(false);
    this.minimized = minimize;
    redraw(minRect.x, minRect.y, minRect.width, minRect.height, false);
}

/**
 * Sets the minimum number of characters that will
 * be displayed in a fully compressed tab.
 *
 * @param count the minimum number of characters that will be displayed in a fully compressed tab
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_INVALID_RANGE - if the count is less than zero</li>
 * </ul>
 *
 * @since 3.0
 */
public void setMinimumCharacters(int count) {
    checkWidget ();
    if (count < 0) SWT.error(SWT.ERROR_INVALID_RANGE);
    if (minChars is count) return;
    minChars = count;
    if (updateItems()) redrawTabs();
}

/**
 * When there is not enough horizontal space to show all the tabs,
 * by default, tabs are shown sequentially from left to right in
 * order of their index.  When the MRU visibility is turned on,
 * the tabs that are visible will be the tabs most recently selected.
 * Tabs will still maintain their left to right order based on index
 * but only the most recently selected tabs are visible.
 * <p>
 * For example, consider a CTabFolder that contains "Tab 1", "Tab 2",
 * "Tab 3" and "Tab 4" (in order by index).  The user selects
 * "Tab 1" and then "Tab 3".  If the CTabFolder is now
 * compressed so that only two tabs are visible, by default,
 * "Tab 2" and "Tab 3" will be shown ("Tab 3" since it is currently
 * selected and "Tab 2" because it is the previous item in index order).
 * If MRU visibility is enabled, the two visible tabs will be "Tab 1"
 * and "Tab 3" (in that order from left to right).</p>
 *
 * @param show the new visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setMRUVisible(bool show) {
    checkWidget();
    if (mru is show) return;
    mru = show;
    if (!mru) {
        int idx = firstIndex;
        int next = 0;
        for (int i = firstIndex; i < items.length; i++) {
            priority[next++] = i;
        }
        for (int i = 0; i < idx; i++) {
            priority[next++] = i;
        }
        if (updateItems()) redrawTabs();
    }
}
/**
 * Set the selection to the tab at the specified item.
 *
 * @param item the tab item to be selected
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 * </ul>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 */
public void setSelection(CTabItem item) {
    checkWidget();
    if (item is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    int index = indexOf(item);
    setSelection(index);
}
/**
 * Set the selection to the tab at the specified index.
 *
 * @param index the index of the tab item to be selected
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection(int index) {
    checkWidget();
    if (index < 0 || index >= items.length) return;
    CTabItem selection = items[index];
    if (selectedIndex is index) {
        showItem(selection);
        return;
    }

    int oldIndex = selectedIndex;
    selectedIndex = index;
    if (oldIndex !is -1) {
        items[oldIndex].closeImageState = NONE;
    }
    selection.closeImageState = NORMAL;
    selection.showing = false;

    Control newControl = selection.control;
    Control oldControl = null;
    if (oldIndex !is -1) {
        oldControl = items[oldIndex].control;
    }

    if (newControl !is oldControl) {
        if (newControl !is null && !newControl.isDisposed()) {
            newControl.setBounds(getClientArea());
            newControl.setVisible(true);
        }
        if (oldControl !is null && !oldControl.isDisposed()) {
            oldControl.setVisible(false);
        }
    }
    showItem(selection);
    redraw();
}
void setSelection(int index, bool notify) {
    int oldSelectedIndex = selectedIndex;
    setSelection(index);
    if (notify && selectedIndex !is oldSelectedIndex && selectedIndex !is -1) {
        Event event = new Event();
        event.item = getItem(selectedIndex);
        notifyListeners(SWT.Selection, event);
    }
}
/**
 * Sets the receiver's selection background color to the color specified
 * by the argument, or to the default system color for the control
 * if the argument is null.
 *
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setSelectionBackground (Color color) {
    checkWidget();
    setSelectionHighlightGradientColor(null);
    if (selectionBackground is color) return;
    if (color is null) color = getDisplay().getSystemColor(SELECTION_BACKGROUND);
    selectionBackground = color;
    if (selectedIndex > -1) redraw();
}
/**
 * Specify a gradient of colours to be draw in the background of the selected tab.
 * For example to draw a gradient that varies from dark blue to blue and then to
 * white, use the following call to setBackground:
 * <pre>
 *  cfolder.setBackground(new Color[]{display.getSystemColor(SWT.COLOR_DARK_BLUE),
 *                                 display.getSystemColor(SWT.COLOR_BLUE),
 *                                 display.getSystemColor(SWT.COLOR_WHITE),
 *                                 display.getSystemColor(SWT.COLOR_WHITE)},
 *                     new int[] {25, 50, 100});
 * </pre>
 *
 * @param colors an array of Color that specifies the colors to appear in the gradient
 *               in order of appearance left to right.  The value <code>null</code> clears the
 *               background gradient. The value <code>null</code> can be used inside the array of
 *               Color to specify the background color.
 * @param percents an array of integers between 0 and 100 specifying the percent of the width
 *                 of the widget at which the color should change.  The size of the percents array must be one
 *                 less than the size of the colors array.
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public void setSelectionBackground(Color[] colors, int[] percents) {
    setSelectionBackground(colors, percents, false);
}
/**
 * Specify a gradient of colours to be draw in the background of the selected tab.
 * For example to draw a vertical gradient that varies from dark blue to blue and then to
 * white, use the following call to setBackground:
 * <pre>
 *  cfolder.setBackground(new Color[]{display.getSystemColor(SWT.COLOR_DARK_BLUE),
 *                                 display.getSystemColor(SWT.COLOR_BLUE),
 *                                 display.getSystemColor(SWT.COLOR_WHITE),
 *                                 display.getSystemColor(SWT.COLOR_WHITE)},
 *                        new int[] {25, 50, 100}, true);
 * </pre>
 *
 * @param colors an array of Color that specifies the colors to appear in the gradient
 *               in order of appearance left to right.  The value <code>null</code> clears the
 *               background gradient. The value <code>null</code> can be used inside the array of
 *               Color to specify the background color.
 * @param percents an array of integers between 0 and 100 specifying the percent of the width
 *                 of the widget at which the color should change.  The size of the percents array must be one
 *                 less than the size of the colors array.
 *
 * @param vertical indicate the direction of the gradient.  True is vertical and false is horizontal.
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 *
 * @since 3.0
 */
public void setSelectionBackground(Color[] colors, int[] percents, bool vertical) {
    checkWidget();
    int colorsLength;
    Color highlightBeginColor = null;  //null is no highlight

    if (colors !is null) {
        //The colors array can optionally have an extra entry which describes the highlight top color
        //Thus its either one or two larger than the percents array
        if (percents is null ||
                ! ((percents.length is colors.length - 1) || (percents.length is colors.length - 2))){
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        }
        for (int i = 0; i < percents.length; i++) {
            if (percents[i] < 0 || percents[i] > 100) {
                SWT.error(SWT.ERROR_INVALID_ARGUMENT);
            }
            if (i > 0 && percents[i] < percents[i-1]) {
                SWT.error(SWT.ERROR_INVALID_ARGUMENT);
            }
        }
        //If the colors is exactly two more than percents then last is highlight
        //Keep track of *real* colorsLength (minus the highlight)
        if(percents.length is colors.length - 2) {
            highlightBeginColor = colors[colors.length - 1];
            colorsLength = cast(int)/*64bit*/colors.length - 1;
        } else {
            colorsLength = cast(int)/*64bit*/colors.length;
        }
        if (getDisplay().getDepth() < 15) {
            // Don't use gradients on low color displays
            colors = [colors[colorsLength - 1]];
            colorsLength = cast(int)/*64bit*/colors.length;
            percents = null;
        }
    } else {
        colorsLength = 0;
    }

    // Are these settings the same as before?
    if (selectionBgImage is null) {
        if ((selectionGradientColors !is null) && (colors !is null) &&
            (selectionGradientColors.length is colorsLength)) {
            bool same = false;
            for (int i = 0; i < selectionGradientColors.length; i++) {
                if (selectionGradientColors[i] is null) {
                    same = colors[i] is null;
                } else {
                    same = cast(bool)(selectionGradientColors[i]==colors[i]);
                }
                if (!same) break;
            }
            if (same) {
                for (int i = 0; i < selectionGradientPercents.length; i++) {
                    same = selectionGradientPercents[i] is percents[i];
                    if (!same) break;
                }
            }
            if (same && this.selectionGradientVertical is vertical) return;
        }
    } else {
        selectionBgImage = null;
    }
    // Store the new settings
    if (colors is null) {
        selectionGradientColors = null;
        selectionGradientPercents = null;
        selectionGradientVertical = false;
        setSelectionBackground(cast(Color)null);
        setSelectionHighlightGradientColor(null);
    } else {
        selectionGradientColors = new Color[colorsLength];
        for (int i = 0; i < colorsLength; ++i) {
            selectionGradientColors[i] = colors[i];
        }
        selectionGradientPercents = new int[percents.length];
        for (int i = 0; i < percents.length; ++i) {
            selectionGradientPercents[i] = percents[i];
        }
        selectionGradientVertical = vertical;
        setSelectionBackground(selectionGradientColors[selectionGradientColors.length-1]);
        setSelectionHighlightGradientColor(highlightBeginColor);
    }

    // Refresh with the new settings
    if (selectedIndex > -1) redraw();
}

/*
 * Set the color for the highlight start for selected tabs.
 * Update the cache of highlight gradient colors if required.
 */

void setSelectionHighlightGradientColor(Color start) {
    //Set to null to match all the early return cases.
    //For early returns, don't realloc the cache, we may get a cache hit next time we're given the highlight
    selectionHighlightGradientBegin = null;

    if(start is null)
        return;

    //don't bother on low colour
    if (getDisplay().getDepth() < 15)
        return;

    //don't bother if we don't have a background gradient
    if(selectionGradientColors.length < 2)
        return;

    //OK we know its a valid gradient now
    selectionHighlightGradientBegin = start;

    if(! isSelectionHighlightColorsCacheHit(start))
        createSelectionHighlightGradientColors(start);  //if no cache hit then compute new ones
}

/*
 * Return true if given start color, the cache of highlight colors we have
 * would match the highlight colors we'd compute.
 */
bool isSelectionHighlightColorsCacheHit(Color start) {

    if(selectionHighlightGradientColorsCache is null)
        return false;

    //this case should never happen but check to be safe before accessing array indexes
    if(selectionHighlightGradientColorsCache.length < 2)
        return false;

    Color highlightBegin = selectionHighlightGradientColorsCache[0];
    Color highlightEnd = selectionHighlightGradientColorsCache[selectionHighlightGradientColorsCache.length - 1];

    if( highlightBegin!=start)
        return false;

    //Compare number of colours we have vs. we'd compute
    if(selectionHighlightGradientColorsCache.length !is tabHeight)
        return false;

    //Compare existing highlight end to what it would be (selectionBackground)
    if( highlightEnd!=selectionBackground)
        return false;

    return true;
}

/**
 * Set the image to be drawn in the background of the selected tab.  Image
 * is stretched or compressed to cover entire selection tab area.
 *
 * @param image the image to be drawn in the background
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelectionBackground(Image image) {
    checkWidget();
    setSelectionHighlightGradientColor(null);
    if (image is selectionBgImage) return;
    if (image !is null) {
        selectionGradientColors = null;
        selectionGradientPercents = null;
        disposeSelectionHighlightGradientColors();
    }
    selectionBgImage = image;
    if (selectedIndex > -1) redraw();
}
/**
 * Set the foreground color of the selected tab.
 *
 * @param color the color of the text displayed in the selected tab
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelectionForeground (Color color) {
    checkWidget();
    if (selectionForeground is color) return;
    if (color is null) color = getDisplay().getSystemColor(SELECTION_FOREGROUND);
    selectionForeground = color;
    if (selectedIndex > -1) redraw();
}

/*
 * Allocate colors for the highlight line.
 * Colours will be a gradual blend ranging from to.
 * Blend length will be tab height.
 * Recompute this if tab height changes.
 * Could remain null if there'd be no gradient (start=end or low colour display)
 */
void createSelectionHighlightGradientColors(Color start) {
    disposeSelectionHighlightGradientColors(); //dispose if existing

    if(start is null)  //shouldn't happen but just to be safe
        return;

    //alloc colours for entire height to ensure it matches wherever we stop drawing
    int fadeGradientSize = tabHeight;

    RGB from = start.getRGB();
    RGB to = selectionBackground.getRGB();

    selectionHighlightGradientColorsCache = new Color[fadeGradientSize];
    int denom = fadeGradientSize - 1;

    for (int i = 0; i < fadeGradientSize; i++) {
        int propFrom = denom - i;
        int propTo = i;
        int red = (to.red * propTo + from.red * propFrom) / denom;
        int green = (to.green * propTo  + from.green * propFrom) / denom;
        int blue = (to.blue * propTo  + from.blue * propFrom) / denom;
        selectionHighlightGradientColorsCache[i] = new Color(getDisplay(), red, green, blue);
    }
}

void disposeSelectionHighlightGradientColors() {
    if(selectionHighlightGradientColorsCache is null)
        return;
    for (int i = 0; i < selectionHighlightGradientColorsCache.length; i++) {
        selectionHighlightGradientColorsCache[i].dispose();
    }
    selectionHighlightGradientColorsCache = null;
}

/*
 * Return the gradient start color for selected tabs, which is the start of the tab fade
 * (end is selectionBackground).
 */
Color getSelectionBackgroundGradientBegin() {
    if (selectionGradientColors is null)
        return getSelectionBackground();
    if (selectionGradientColors.length is 0)
        return getSelectionBackground();
    return selectionGradientColors[0];
}

/**
 * Sets the shape that the CTabFolder will use to render itself.
 *
 * @param simple <code>true</code> if the CTabFolder should render itself in a simple, traditional style
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setSimple(bool simple) {
    checkWidget();
    if (this.simple !is simple) {
        this.simple = simple;
        Rectangle rectBefore = getClientArea();
        updateItems();
        Rectangle rectAfter = getClientArea();
        if (rectBefore!=rectAfter) {
            notifyListeners(SWT.Resize, new Event());
        }
        redraw();
    }
}
/**
 * Sets the number of tabs that the CTabFolder should display
 *
 * @param single <code>true</code> if only the selected tab should be displayed otherwise, multiple tabs will be shown.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setSingle(bool single) {
    checkWidget();
    if (this.single !is single) {
        this.single = single;
        if (!single) {
            for (int i = 0; i < items.length; i++) {
                if (i !is selectedIndex && items[i].closeImageState is NORMAL) {
                    items[i].closeImageState = NONE;
                }
            }
        }
        Rectangle rectBefore = getClientArea();
        updateItems();
        Rectangle rectAfter = getClientArea();
        if (rectBefore!=rectAfter) {
            notifyListeners(SWT.Resize, new Event());
        }
        redraw();
    }
}
/**
 * Specify a fixed height for the tab items.  If no height is specified,
 * the default height is the height of the text or the image, whichever
 * is greater. Specifying a height of -1 will revert to the default height.
 *
 * @param height the pixel value of the height or -1
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_INVALID_ARGUMENT - if called with a height of less than 0</li>
 * </ul>
 */
public void setTabHeight(int height) {
    checkWidget();
    if (height < -1) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    fixedTabHeight = height;
    updateTabHeight(false);
}
/**
 * Specify whether the tabs should appear along the top of the folder
 * or along the bottom of the folder.
 *
 * @param position <code>SWT.TOP</code> for tabs along the top or <code>SWT.BOTTOM</code> for tabs along the bottom
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the position value is not either SWT.TOP or SWT.BOTTOM</li>
 * </ul>
 *
 * @since 3.0
 */
public void setTabPosition(int position) {
    checkWidget();
    if (position !is SWT.TOP && position !is SWT.BOTTOM) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    if (onBottom !is (position is SWT.BOTTOM)) {
        onBottom = position is SWT.BOTTOM;
        borderTop = onBottom ? borderLeft : 0;
        borderBottom = onBottom ? 0 : borderRight;
        updateTabHeight(true);
        Rectangle rectBefore = getClientArea();
        updateItems();
        Rectangle rectAfter = getClientArea();
        if (rectBefore!=rectAfter) {
            notifyListeners(SWT.Resize, new Event());
        }
        redraw();
    }
}
/**
 * Set the control that appears in the top right corner of the tab folder.
 * Typically this is a close button or a composite with a Menu and close button.
 * The topRight control is optional.  Setting the top right control to null will
 * remove it from the tab folder.
 *
 * @param control the control to be displayed in the top right corner or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the control is not a child of this CTabFolder</li>
 * </ul>
 *
 * @since 2.1
 */
public void setTopRight(Control control) {
    setTopRight(control, SWT.RIGHT);
}
/**
 * Set the control that appears in the top right corner of the tab folder.
 * Typically this is a close button or a composite with a Menu and close button.
 * The topRight control is optional.  Setting the top right control to null
 * will remove it from the tab folder.
 * <p>
 * The alignment parameter sets the layout of the control in the tab area.
 * <code>SWT.RIGHT</code> will cause the control to be positioned on the far
 * right of the folder and it will have its default size.  <code>SWT.FILL</code>
 * will size the control to fill all the available space to the right of the
 * last tab.  If there is no available space, the control will not be visible.
 * </p>
 *
 * @param control the control to be displayed in the top right corner or null
 * @param alignment <code>SWT.RIGHT</code> or <code>SWT.FILL</code>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the control is not a child of this CTabFolder</li>
 * </ul>
 *
 * @since 3.0
 */
public void setTopRight(Control control, int alignment) {
    checkWidget();
    if (alignment !is SWT.RIGHT && alignment !is SWT.FILL) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    if (control !is null && control.getParent() !is this) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    topRight = control;
    topRightAlignment = alignment;
    if (updateItems()) redraw();
}
/**
 * Specify whether the close button appears
 * when the user hovers over an unselected tabs.
 *
 * @param visible <code>true</code> makes the close button appear
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setUnselectedCloseVisible(bool visible) {
    checkWidget();
    if (showUnselectedClose is visible) return;
    // display close button when mouse hovers
    showUnselectedClose = visible;
    updateItems();
    redraw();
}
/**
 * Specify whether the image appears on unselected tabs.
 *
 * @param visible <code>true</code> makes the image appear
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setUnselectedImageVisible(bool visible) {
    checkWidget();
    if (showUnselectedImage is visible) return;
    // display image on unselected items
    showUnselectedImage = visible;
    updateItems();
    redraw();
}
/**
 * Shows the item.  If the item is already showing in the receiver,
 * this method simply returns.  Otherwise, the items are scrolled until
 * the item is visible.
 *
 * @param item the item to be shown
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see CTabFolder#showSelection()
 *
 * @since 2.0
 */
public void showItem (CTabItem item) {
    checkWidget();
    if (item is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    int index = indexOf(item);
    if (index is -1) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    int idx = -1;
    for (int i = 0; i < priority.length; i++) {
        if (priority[i] is index) {
            idx = i;
            break;
        }
    }
    if (mru) {
        // move to front of mru order
        int[] newPriority = new int[priority.length];
        System.arraycopy(priority, 0, newPriority, 1, idx);
        System.arraycopy(priority, idx+1, newPriority, idx+1, priority.length - idx - 1);
        newPriority[0] = index;
        priority = newPriority;
    }
    if (item.isShowing()) return;
    updateItems(index);
    redrawTabs();
}
void showList (Rectangle rect) {
    if (items.length is 0 || !showChevron) return;
    if (showMenu is null || showMenu.isDisposed()) {
        showMenu = new Menu(this);
    } else {
        MenuItem[] items = showMenu.getItems();
        for (int i = 0; i < items.length; i++) {
            items[i].dispose();
        }
    }
    static const String id = "CTabFolder_showList_Index"; //$NON-NLS-1$
    for (int i = 0; i < items.length; i++) {
        CTabItem tab = items[i];
        if (tab.showing) continue;
        MenuItem item = new MenuItem(showMenu, SWT.NONE);
        item.setText(tab.getText());
        item.setImage(tab.getImage());
        item.setData(id, tab);
        item.addSelectionListener(new class() SelectionAdapter {
            override
            public void widgetSelected(SelectionEvent e) {
                MenuItem menuItem = cast(MenuItem)e.widget;
                int index = indexOf(cast(CTabItem)menuItem.getData(id));
                this.outer.setSelection(index, true);
            }
        });
    }
    int x = rect.x;
    int y = rect.y + rect.height;
    Point location = getDisplay().map(this, null, x, y);
    showMenu.setLocation(location.x, location.y);
    showMenu.setVisible(true);
}
/**
 * Shows the selection.  If the selection is already showing in the receiver,
 * this method simply returns.  Otherwise, the items are scrolled until
 * the selection is visible.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see CTabFolder#showItem(CTabItem)
 *
 * @since 2.0
 */
public void showSelection () {
    checkWidget ();
    if (selectedIndex !is -1) {
        showItem(getSelection());
    }
}

void _setToolTipText (int x, int y) {
    String oldTip = getToolTipText();
    String newTip = _getToolTip(x, y);
    if (newTip is null || newTip!=oldTip) {
        setToolTipText(newTip);
    }
}

bool updateItems() {
    return updateItems(selectedIndex);
}

bool updateItems(int showIndex) {
    if (!single && !mru && showIndex !is -1) {
        // make sure selected item will be showing
        int firstIndex = showIndex;
        if (priority[0] < showIndex) {
            int maxWidth = getRightItemEdge() - borderLeft;
            if (!simple) maxWidth -= curveWidth - 2*curveIndent;
            int width = 0;
            int[] widths = new int[items.length];
            GC gc = new GC(this);
            for (int i = priority[0]; i <= showIndex; i++) {
                widths[i] = items[i].preferredWidth(gc, i is selectedIndex, true);
                width += widths[i];
                if (width > maxWidth) break;
            }
            if (width > maxWidth) {
                width = 0;
                for (int i = showIndex; i >= 0; i--) {
                    if (widths[i] is 0) widths[i] = items[i].preferredWidth(gc, i is selectedIndex, true);
                    width += widths[i];
                    if (width > maxWidth) break;
                    firstIndex = i;
                }
            } else {
                firstIndex = priority[0];
                for (int i = showIndex + 1; i < items.length; i++) {
                    widths[i] = items[i].preferredWidth(gc, i is selectedIndex, true);
                    width += widths[i];
                    if (width >= maxWidth) break;
                }
                if (width < maxWidth) {
                    for (int i = priority[0] - 1; i >= 0; i--) {
                        if (widths[i] is 0) widths[i] = items[i].preferredWidth(gc, i is selectedIndex, true);
                        width += widths[i];
                        if (width > maxWidth) break;
                        firstIndex = i;
                    }
                }
            }
            gc.dispose();
        }
        if (firstIndex !is priority[0]) {
            int index = 0;
            for (int i = firstIndex; i < items.length; i++) {
                priority[index++] = i;
            }
            for (int i = 0; i < firstIndex; i++) {
                priority[index++] = i;
            }
        }
    }

    bool oldShowChevron = showChevron;
    bool changed = setItemSize();
    changed |= setItemLocation();
    setButtonBounds();
    changed |= showChevron !is oldShowChevron;
    if (changed && getToolTipText() !is null) {
        Point pt = getDisplay().getCursorLocation();
        pt = toControl(pt);
        _setToolTipText(pt.x, pt.y);
    }
    return changed;
}
bool updateTabHeight(bool force){
    int style = getStyle();
    if (fixedTabHeight is 0 && (style & SWT.FLAT) !is 0 && (style & SWT.BORDER) is 0) highlight_header = 0;
    int oldHeight = tabHeight;
    if (fixedTabHeight !is SWT.DEFAULT) {
        tabHeight = fixedTabHeight is 0 ? 0 : fixedTabHeight + 1; // +1 for line drawn across top of tab
    } else {
        int tempHeight = 0;
        GC gc = new GC(this);
        if (items.length is 0) {
            tempHeight = gc.textExtent("Default", CTabItem.FLAGS).y + CTabItem.TOP_MARGIN + CTabItem.BOTTOM_MARGIN; //$NON-NLS-1$
        } else {
            for (int i=0; i < items.length; i++) {
                tempHeight = Math.max(tempHeight, items[i].preferredHeight(gc));
            }
        }
        gc.dispose();
        tabHeight =  tempHeight;
    }
    if (!force && tabHeight is oldHeight) return false;

    oldSize = null;
    if (onBottom) {
        int d = tabHeight - 12;
        curve = [0,13+d, 0,12+d, 2,12+d, 3,11+d, 5,11+d, 6,10+d, 7,10+d, 9,8+d, 10,8+d,
                          11,7+d, 11+d,7,
                          12+d,6, 13+d,6, 15+d,4, 16+d,4, 17+d,3, 19+d,3, 20+d,2, 22+d,2, 23+d,1];
        curveWidth = 26+d;
        curveIndent = curveWidth/3;
    } else {
        int d = tabHeight - 12;
        curve = [0,0, 0,1, 2,1, 3,2, 5,2, 6,3, 7,3, 9,5, 10,5,
                          11,6, 11+d,6+d,
                          12+d,7+d, 13+d,7+d, 15+d,9+d, 16+d,9+d, 17+d,10+d, 19+d,10+d, 20+d,11+d, 22+d,11+d, 23+d,12+d];
        curveWidth = 26+d;
        curveIndent = curveWidth/3;

        //this could be static but since values depend on curve, better to keep in one place
        topCurveHighlightStart = [
                0, 2,  1, 2,  2, 2,
                3, 3,  4, 3,  5, 3,
                6, 4,  7, 4,
                8, 5,
                9, 6, 10, 6];

        //also, by adding in 'd' here we save some math cost when drawing the curve
        topCurveHighlightEnd = [
                10+d, 6+d,
                11+d, 7+d,
                12+d, 8+d,  13+d, 8+d,
                14+d, 9+d,
                15+d, 10+d,  16+d, 10+d,
                17+d, 11+d,  18+d, 11+d,  19+d, 11+d,
                20+d, 12+d,  21+d, 12+d,  22+d,  12+d ];
    }
    notifyListeners(SWT.Resize, new Event());
    return true;
}
String _getToolTip(int x, int y) {
    if (showMin && minRect.contains(x, y)) return minimized ? SWT.getMessage("SWT_Restore") : SWT.getMessage("SWT_Minimize"); //$NON-NLS-1$ //$NON-NLS-2$
    if (showMax && maxRect.contains(x, y)) return maximized ? SWT.getMessage("SWT_Restore") : SWT.getMessage("SWT_Maximize"); //$NON-NLS-1$ //$NON-NLS-2$
    if (showChevron && chevronRect.contains(x, y)) return SWT.getMessage("SWT_ShowList"); //$NON-NLS-1$
    CTabItem item = getItem(new Point (x, y));
    if (item is null) return null;
    if (!item.showing) return null;
    if ((showClose || item.showClose) && item.closeRect.contains(x, y)) {
        return SWT.getMessage("SWT_Close"); //$NON-NLS-1$
    }
    return item.getToolTipText();
}
}
