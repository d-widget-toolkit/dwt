/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *    John Reimer <terminal.node@gmail.com>
 *    Frank Benoit <benoit@tionex.de>
 *******************************************************************************/

module org.eclipse.swt.internal.gdip.Gdip;

import org.eclipse.swt.internal.gdip.native;

import org.eclipse.swt.internal.Library;
import org.eclipse.swt.internal.Platform;
import org.eclipse.swt.internal.win32.WINTYPES;
import org.eclipse.swt.internal.win32.WINAPI;
import org.eclipse.swt.internal.win32.OS;

import java.lang.all;

version(Tango){
    import tango.sys.win32.UserGdi;
} else { // Phobos
}

alias org.eclipse.swt.internal.gdip.native.GdiplusStartupInput  GdiplusStartupInput;
alias org.eclipse.swt.internal.gdip.native.GdiplusStartupOutput GdiplusStartupOutput;

/******************************************************************************

    Gdip Class: provides access to the Gdi+ interface

/*****************************************************************************/

public class Gdip : Platform
{
    mixin(sharedStaticThis!(`{
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (5, 1)) {
            loadLib_Gdip();
        }
    }`));
    /**************************************************************************

    **************************************************************************/

private:

    static FontFamily GenericSansSerifFontFamily = null;
    static FontFamily GenericSerifFontFamily     = null;
    static FontFamily GenericMonospaceFontFamily = null;

    /**************************************************************************

    **************************************************************************/

    struct FontFamily_T
    {
        Handle  nativeFamily;
        Status  lastResult;
    }

    struct StringFormat_T
    {

        StringFormat format;
        Status  lastError;
    }

    static ubyte[StringFormat_T.sizeof] GenericTypographicStringFormatBuffer = 0;
    static ubyte[StringFormat_T.sizeof] GenericDefaultStringFormatBuffer = 0;
    static ubyte[FontFamily_T.sizeof] GenericSansSerifFontFamilyBuffer = 0;
    static ubyte[FontFamily_T.sizeof] GenericSerifFontFamilyBuffer = 0;
    static ubyte[FontFamily_T.sizeof] GenericMonospaceFontFamilyBuffer = 0;

    /**************************************************************************

    **************************************************************************/

public:

    alias GpPoint           Point;
    alias GpPointF          PointF;
    alias GpRect            Rect;
    alias GpRectF           RectF;
    alias GpBitmapData      BitmapData;
    alias GpColorPalette    ColorPalette;
    alias GpDrawImageAbort  DrawImageAbort;
    alias GpColorMatrix     ColorMatrix;

    alias GpFontFamily          FontFamily;
    alias GpImage               Image;
    alias GpBrush               Brush;
    alias GpFont                Font;
    alias GpFontCollection      FontCollection;
    alias GpGraphics            Graphics;
    alias GpGraphicsPath        GraphicsPath;
    alias GpImageAttributes     ImageAttributes;
    alias GpHatchBrush          HatchBrush;
    alias GpLinearGradientBrush LinearGradientBrush;
    alias GpMatrix              Matrix;
    alias GpPen                 Pen;
    alias GpRegion              Region;
    alias GpSolidBrush          SolidBrush;
    alias GpStringFormat        StringFormat;
    alias GpTextureBrush        TextureBrush;
    alias GpPath                Path;

    alias Image  Bitmap;

    alias  uint  ARGB;

    alias org.eclipse.swt.internal.gdip.native.GdiplusStartupInput  GdiplusStartupInput;
    alias org.eclipse.swt.internal.gdip.native.GdiplusStartupOutput GdiplusStartupOutput;

    /**************************************************************************

        Gdi+ Constants

    **************************************************************************/

    enum {
        BrushTypeSolidColor = 0,
        BrushTypeHatchFill = 1,
        BrushTypeTextureFill = 2,
        BrushTypePathGradient = 3,
        BrushTypeLinearGradient = 4,
        //  ColorAdjustTypeBitmap = 1,
        ColorMatrixFlagsDefault = 0,
        CombineModeReplace = 0,
        CombineModeIntersect = 1,
        CombineModeUnion = 2,
        CombineModeXor = 3,
        CombineModeExclude = 4,
        CombineModeComplement = 5,
        FillModeAlternate = 0,
        FillModeWinding = 1,
        DashCapFlat = 0,
        DashCapRound = 2,
        DashCapTriangle = 3,
        DashStyleSolid = 0,
        DashStyleDash = 1,
        DashStyleDot = 2,
        DashStyleDashDot = 3,
        DashStyleDashDotDot = 4,
        DashStyleCustom = 5,
        FontStyleRegular = 0,
        FontStyleBold = 1,
        FontStyleItalic = 2,
        FontStyleBoldItalic = 3,
        FontStyleUnderline = 4,
        FontStyleStrikeout = 8,
        PaletteFlagsHasAlpha = 0x0001,
        FlushIntentionFlush = 0,
        FlushIntentionSync = 1,
        HotkeyPrefixNone = 0,
        HotkeyPrefixShow = 1,
        HotkeyPrefixHide = 2,
        LineJoinMiter = 0,
        LineJoinBevel = 1,
        LineJoinRound = 2,
        LineCapFlat = 0,
        LineCapSquare = 1,
        LineCapRound = 2,
        MatrixOrderPrepend = 0,
        MatrixOrderAppend = 1,
        QualityModeDefault = 0,
        QualityModeLow = 1,
        QualityModeHigh = 2,
        InterpolationModeInvalid = -1,
        InterpolationModeDefault = QualityModeDefault,
        InterpolationModeLowQuality = QualityModeLow,
        InterpolationModeHighQuality = QualityModeHigh,
        InterpolationModeBilinear = QualityModeHigh + 1,
        InterpolationModeBicubic = QualityModeHigh + 2,
        InterpolationModeNearestNeighbor = QualityModeHigh + 3,
        InterpolationModeHighQualityBilinear = QualityModeHigh + 4,
        InterpolationModeHighQualityBicubic = QualityModeHigh + 5,
        PathPointTypeStart = 0,
        PathPointTypeLine = 1,
        PathPointTypeBezier = 3,
        PathPointTypePathTypeMask = 0x7,
        PathPointTypePathDashMode = 0x10,
        PathPointTypePathMarker = 0x20,
        PathPointTypeCloseSubpath = 0x80,
        PathPointTypeBezier3 = 3,
        PixelFormatIndexed = 0x00010000,
        PixelFormatGDI = 0x00020000,
        PixelFormatAlpha = 0x00040000,
        PixelFormatPAlpha = 0x00080000,
        PixelFormatExtended = 0x00100000,
        PixelFormatCanonical = 0x00200000,
        PixelFormat1bppIndexed = (1 | ( 1 << 8) | PixelFormatIndexed | PixelFormatGDI),
        PixelFormat4bppIndexed = (2 | ( 4 << 8) | PixelFormatIndexed | PixelFormatGDI),
        PixelFormat8bppIndexed = (3 | ( 8 << 8) | PixelFormatIndexed | PixelFormatGDI),
        PixelFormat16bppGrayScale = (4 | (16 << 8) | PixelFormatExtended),
        PixelFormat16bppRGB555 = (5 | (16 << 8) | PixelFormatGDI),
        PixelFormat16bppRGB565 = (6 | (16 << 8) | PixelFormatGDI),
        PixelFormat16bppARGB1555 = (7 | (16 << 8) | PixelFormatAlpha | PixelFormatGDI),
        PixelFormat24bppRGB = (8 | (24 << 8) | PixelFormatGDI),
        PixelFormat32bppRGB = (9 | (32 << 8) | PixelFormatGDI),
        PixelFormat32bppARGB = (10 | (32 << 8) | PixelFormatAlpha | PixelFormatGDI | PixelFormatCanonical),
        PixelFormat32bppPARGB = (11 | (32 << 8) | PixelFormatAlpha | PixelFormatPAlpha | PixelFormatGDI),
        PixelFormat48bppRGB = (12 | (48 << 8) | PixelFormatExtended),
        PixelFormat64bppARGB = (13 | (64 << 8) | PixelFormatAlpha  | PixelFormatCanonical | PixelFormatExtended),
        PixelFormat64bppPARGB = (14 | (64 << 8) | PixelFormatAlpha  | PixelFormatPAlpha | PixelFormatExtended),
        PixelFormatMax = 15,
        PixelOffsetModeNone = QualityModeHigh + 1,
        PixelOffsetModeHalf = QualityModeHigh + 2,
        SmoothingModeInvalid = -1,
        SmoothingModeDefault = QualityModeDefault,
        SmoothingModeHighSpeed = QualityModeLow,
        SmoothingModeHighQuality = QualityModeHigh,
        SmoothingModeNone = 3,
        SmoothingModeAntiAlias8x4 = 4,
        SmoothingModeAntiAlias = SmoothingModeAntiAlias8x4,
        SmoothingModeAntiAlias8x8 = 5,
        StringFormatFlagsDirectionRightToLeft = 0x00000001,
        StringFormatFlagsDirectionVertical = 0x00000002,
        StringFormatFlagsNoFitBlackBox = 0x00000004,
        StringFormatFlagsDisplayFormatControl = 0x00000020,
        StringFormatFlagsNoFontFallback = 0x00000400,
        StringFormatFlagsMeasureTrailingSpaces = 0x00000800,
        StringFormatFlagsNoWrap = 0x00001000,
        StringFormatFlagsLineLimit = 0x00002000,
        StringFormatFlagsNoClip = 0x00004000,
        TextRenderingHintSystemDefault = 0,
        TextRenderingHintSingleBitPerPixelGridFit = 1,
        TextRenderingHintSingleBitPerPixel = 2,
        TextRenderingHintAntiAliasGridFit = 3,
        TextRenderingHintAntiAlias = 4,
        TextRenderingHintClearTypeGridFit = 5,
        //  UnitPixel = 2,
        WrapModeTile = 0,
        WrapModeTileFlipX = 1,
        WrapModeTileFlipY = 2,
        WrapModeTileFlipXY = 3,
        WrapModeClamp = 4
    }

    enum
    {
        PenTypeSolidColor       = BrushTypeSolidColor,
        PenTypeHatchFill        = BrushTypeHatchFill,
        PenTypeTextureFill      = BrushTypeTextureFill,
        PenTypePathGradient     = BrushTypePathGradient,
        PenTypeLinearGradient   = BrushTypeLinearGradient,
        PenTypeUnknown          = -1
    }

    enum
    {
        UnitWorld,      // 0 -- World coordinate (non-physical unit)
        UnitDisplay,    // 1 -- Variable -- for PageTransform only
        UnitPixel,      // 2 -- Each unit is one device pixel.
        UnitPoint,      // 3 -- Each unit is a printer's point, or 1/72 inch.
        UnitInch,       // 4 -- Each unit is 1 inch.
        UnitDocument,   // 5 -- Each unit is 1/300 inch.
        UnitMillimeter  // 6 -- Each unit is 1 millimeter.
    }

    enum
    {
        AliceBlue            = 0xFFF0F8FF,
        AntiqueWhite         = 0xFFFAEBD7,
        Aqua                 = 0xFF00FFFF,
        Aquamarine           = 0xFF7FFFD4,
        Azure                = 0xFFF0FFFF,
        Beige                = 0xFFF5F5DC,
        Bisque               = 0xFFFFE4C4,
        Black                = 0xFF000000,
        BlanchedAlmond       = 0xFFFFEBCD,
        Blue                 = 0xFF0000FF,
        BlueViolet           = 0xFF8A2BE2,
        Brown                = 0xFFA52A2A,
        BurlyWood            = 0xFFDEB887,
        CadetBlue            = 0xFF5F9EA0,
        Chartreuse           = 0xFF7FFF00,
        Chocolate            = 0xFFD2691E,
        Coral                = 0xFFFF7F50,
        CornflowerBlue       = 0xFF6495ED,
        Cornsilk             = 0xFFFFF8DC,
        Crimson              = 0xFFDC143C,
        Cyan                 = 0xFF00FFFF,
        DarkBlue             = 0xFF00008B,
        DarkCyan             = 0xFF008B8B,
        DarkGoldenrod        = 0xFFB8860B,
        DarkGray             = 0xFFA9A9A9,
        DarkGreen            = 0xFF006400,
        DarkKhaki            = 0xFFBDB76B,
        DarkMagenta          = 0xFF8B008B,
        DarkOliveGreen       = 0xFF556B2F,
        DarkOrange           = 0xFFFF8C00,
        DarkOrchid           = 0xFF9932CC,
        DarkRed              = 0xFF8B0000,
        DarkSalmon           = 0xFFE9967A,
        DarkSeaGreen         = 0xFF8FBC8B,
        DarkSlateBlue        = 0xFF483D8B,
        DarkSlateGray        = 0xFF2F4F4F,
        DarkTurquoise        = 0xFF00CED1,
        DarkViolet           = 0xFF9400D3,
        DeepPink             = 0xFFFF1493,
        DeepSkyBlue          = 0xFF00BFFF,
        DimGray              = 0xFF696969,
        DodgerBlue           = 0xFF1E90FF,
        Firebrick            = 0xFFB22222,
        FloralWhite          = 0xFFFFFAF0,
        ForestGreen          = 0xFF228B22,
        Fuchsia              = 0xFFFF00FF,
        Gainsboro            = 0xFFDCDCDC,
        GhostWhite           = 0xFFF8F8FF,
        Gold                 = 0xFFFFD700,
        Goldenrod            = 0xFFDAA520,
        Gray                 = 0xFF808080,
        Green                = 0xFF008000,
        GreenYellow          = 0xFFADFF2F,
        Honeydew             = 0xFFF0FFF0,
        HotPink              = 0xFFFF69B4,
        IndianRed            = 0xFFCD5C5C,
        Indigo               = 0xFF4B0082,
        Ivory                = 0xFFFFFFF0,
        Khaki                = 0xFFF0E68C,
        Lavender             = 0xFFE6E6FA,
        LavenderBlush        = 0xFFFFF0F5,
        LawnGreen            = 0xFF7CFC00,
        LemonChiffon         = 0xFFFFFACD,
        LightBlue            = 0xFFADD8E6,
        LightCoral           = 0xFFF08080,
        LightCyan            = 0xFFE0FFFF,
        LightGoldenrodYellow = 0xFFFAFAD2,
        LightGray            = 0xFFD3D3D3,
        LightGreen           = 0xFF90EE90,
        LightPink            = 0xFFFFB6C1,
        LightSalmon          = 0xFFFFA07A,
        LightSeaGreen        = 0xFF20B2AA,
        LightSkyBlue         = 0xFF87CEFA,
        LightSlateGray       = 0xFF778899,
        LightSteelBlue       = 0xFFB0C4DE,
        LightYellow          = 0xFFFFFFE0,
        Lime                 = 0xFF00FF00,
        LimeGreen            = 0xFF32CD32,
        Linen                = 0xFFFAF0E6,
        Magenta              = 0xFFFF00FF,
        Maroon               = 0xFF800000,
        MediumAquamarine     = 0xFF66CDAA,
        MediumBlue           = 0xFF0000CD,
        MediumOrchid         = 0xFFBA55D3,
        MediumPurple         = 0xFF9370DB,
        MediumSeaGreen       = 0xFF3CB371,
        MediumSlateBlue      = 0xFF7B68EE,
        MediumSpringGreen    = 0xFF00FA9A,
        MediumTurquoise      = 0xFF48D1CC,
        MediumVioletRed      = 0xFFC71585,
        MidnightBlue         = 0xFF191970,
        MintCream            = 0xFFF5FFFA,
        MistyRose            = 0xFFFFE4E1,
        Moccasin             = 0xFFFFE4B5,
        NavajoWhite          = 0xFFFFDEAD,
        Navy                 = 0xFF000080,
        OldLace              = 0xFFFDF5E6,
        Olive                = 0xFF808000,
        OliveDrab            = 0xFF6B8E23,
        Orange               = 0xFFFFA500,
        OrangeRed            = 0xFFFF4500,
        Orchid               = 0xFFDA70D6,
        PaleGoldenrod        = 0xFFEEE8AA,
        PaleGreen            = 0xFF98FB98,
        PaleTurquoise        = 0xFFAFEEEE,
        PaleVioletRed        = 0xFFDB7093,
        PapayaWhip           = 0xFFFFEFD5,
        PeachPuff            = 0xFFFFDAB9,
        Peru                 = 0xFFCD853F,
        Pink                 = 0xFFFFC0CB,
        Plum                 = 0xFFDDA0DD,
        PowderBlue           = 0xFFB0E0E6,
        Purple               = 0xFF800080,
        Red                  = 0xFFFF0000,
        RosyBrown            = 0xFFBC8F8F,
        RoyalBlue            = 0xFF4169E1,
        SaddleBrown          = 0xFF8B4513,
        Salmon               = 0xFFFA8072,
        SandyBrown           = 0xFFF4A460,
        SeaGreen             = 0xFF2E8B57,
        SeaShell             = 0xFFFFF5EE,
        Sienna               = 0xFFA0522D,
        Silver               = 0xFFC0C0C0,
        SkyBlue              = 0xFF87CEEB,
        SlateBlue            = 0xFF6A5ACD,
        SlateGray            = 0xFF708090,
        Snow                 = 0xFFFFFAFA,
        SpringGreen          = 0xFF00FF7F,
        SteelBlue            = 0xFF4682B4,
        Tan                  = 0xFFD2B48C,
        Teal                 = 0xFF008080,
        Thistle              = 0xFFD8BFD8,
        Tomato               = 0xFFFF6347,
        Transparent          = 0x00FFFFFF,
        Turquoise            = 0xFF40E0D0,
        Violet               = 0xFFEE82EE,
        Wheat                = 0xFFF5DEB3,
        White                = 0xFFFFFFFF,
        WhiteSmoke           = 0xFFF5F5F5,
        Yellow               = 0xFFFFFF00,
        YellowGreen          = 0xFF9ACD32
    }

    // Shift count and bit mask for A, R, G, B components

    enum
    {
        AlphaShift  = 24,
        RedShift    = 16,
        GreenShift  = 8,
        BlueShift   = 0
    }

    enum
    {
        AlphaMask   = 0xff000000,
        RedMask     = 0x00ff0000,
        GreenMask   = 0x0000ff00,
        BlueMask    = 0x000000ff
    }

    enum
    {
        ColorAdjustTypeDefault,
        ColorAdjustTypeBitmap,
        ColorAdjustTypeBrush,
        ColorAdjustTypePen,
        ColorAdjustTypeText,
        ColorAdjustTypeCount,
        ColorAdjustTypeAny      // Reserved
    }

    static ARGB MakeARGB( ubyte a,
                          ubyte r,
                          ubyte g,
                          ubyte b )
    {
        return ((cast(ARGB) (b) <<  Gdip.BlueShift) |
                (cast(ARGB) (g) <<  Gdip.GreenShift) |
                (cast(ARGB) (r) <<  Gdip.RedShift) |
                (cast(ARGB) (a) <<  Gdip.AlphaShift));
    }

/**************************************************************************

    Error Status control

**************************************************************************/

    private static Status SetStatus( Status status )
    {
        if (status != Status.OK)
            return ( lastResult = status );
        else
            return status;
    }

    private static Status lastResult;

/**************************************************************************

    GDI+ Bitmap Wrap Interface

**************************************************************************/

public:

    static void BitmapData_delete (BitmapData* bitmapdata)
    {
        delete bitmapdata;
    }

    /**************************************************************************

    **************************************************************************/

    static BitmapData* BitmapData_new()
    {
        return new BitmapData;
    }

    /**************************************************************************

    **************************************************************************/

    static int Bitmap_GetHBITMAP( Bitmap bitmap, ARGB colorBackground,
                                        out HBITMAP hbmReturn                )
    {
        return SetStatus( GdipCreateHBITMAPFromBitmap( bitmap, hbmReturn,
                                                       colorBackground ) );
    }

    /**************************************************************************

    **************************************************************************/

    static int Bitmap_GetHICON( Bitmap bitmap, out HICON hIconReturn)
    {
        return SetStatus( GdipCreateHICONFromBitmap( bitmap, hIconReturn ) );
    }

    /**************************************************************************

    **************************************************************************/

    static int Bitmap_LockBits( Bitmap bitmap, Rect* rect,
                                      uint flags, PixelFormat pixelFormat,
                                    BitmapData* lockedBitmapData        )
    {
        return SetStatus( GdipBitmapLockBits( bitmap, rect, flags,
                                        pixelFormat, lockedBitmapData ) );
    }

    /**************************************************************************

    **************************************************************************/

    static int Bitmap_UnlockBits( Bitmap bitmap, BitmapData* lockedBitmapData )
    {
        return SetStatus( GdipBitmapUnlockBits( bitmap, lockedBitmapData ) );
    }

    /**************************************************************************

    **************************************************************************/

    static void Bitmap_delete( Bitmap bitmap )
    {
        GdipDisposeImage( bitmap );
    }

    /**************************************************************************

    **************************************************************************/

    static Bitmap Bitmap_new( HICON hicon )
    {
        Bitmap bitmap;
        Gdip.lastResult = GdipCreateBitmapFromHICON( hicon, bitmap );
        return bitmap;
    }

    /**************************************************************************

    **************************************************************************/

    static Bitmap Bitmap_new( HBITMAP hbm, HPALETTE hpal )
    {
        Bitmap bitmap;
        Gdip.lastResult = GdipCreateBitmapFromHBITMAP( hbm, hpal, bitmap );
        return bitmap;
    }

    /**************************************************************************

    **************************************************************************/

    static Bitmap Bitmap_new( int width, int height, int stride,
                       PixelFormat format, ubyte* scan0  )
    {
        Bitmap bitmap;
        Gdip.lastResult = GdipCreateBitmapFromScan0( width, height, stride,
                                                    format, scan0,
                                                    bitmap );
        return bitmap;
    }

    /**************************************************************************

    **************************************************************************/

    static Bitmap Bitmap_new( LPCWSTR filename, bool useIcm )
    {
        Bitmap bitmap;
        if (useIcm) {
            Gdip.lastResult = GdipCreateBitmapFromFileICM( filename, bitmap );
        } else {
            Gdip.lastResult = GdipCreateBitmapFromFile( filename, bitmap );
        }
        return bitmap;
    }


/**************************************************************************

    Gdi+ Image Wrap Interface

**************************************************************************/

    static Status Image_GetLastStatus( Image image )
    {
        Status lastStatus = Gdip.lastResult;
        Gdip.lastResult = Status.OK;
        return lastStatus;
    }

    /**************************************************************************

    **************************************************************************/

    static PixelFormat Image_GetPixelFormat( Image image )
    {
        PixelFormat format;
        SetStatus( GdipGetImagePixelFormat( image, format ) );
        return format;
    }

    /**************************************************************************

    **************************************************************************/

    static uint Image_GetWidth( Image image )
    {
        uint width = 0;
        SetStatus( GdipGetImageWidth( image, width ) );
        return width;
    }

    /**************************************************************************

    **************************************************************************/

    static uint Image_GetHeight( Image image )
    {
        uint height = 0;
        SetStatus( GdipGetImageHeight( image, height ) );
        return height;
    }

    /**************************************************************************

    **************************************************************************/

    static Status Image_GetPalette( Image image, ColorPalette* palette, int size )
    {
        return SetStatus( GdipGetImagePalette( image, palette, size ) );
    }

    /**************************************************************************

    **************************************************************************/

    static int Image_GetPaletteSize( Image image )
    {
        int size = 0;
        SetStatus( GdipGetImagePaletteSize( image, size ) );
        return size;
    }

/**************************************************************************

    Gdi+ ImageAttributes Wrap Interface

**************************************************************************/

    static ImageAttributes ImageAttributes_new()
    {
        ImageAttributes ImageAttr = null;
        Gdip.lastResult = GdipCreateImageAttributes( ImageAttr );
        return ImageAttr;
    }

    /**************************************************************************

    **************************************************************************/

    static void ImageAttributes_delete( ImageAttributes attrib )
    {
        GdipDisposeImageAttributes( attrib );
    }

    /**************************************************************************

    **************************************************************************/

    static Status ImageAttributes_SetWrapMode( ImageAttributes attrib,
                                               WrapMode wrap,
                                               ARGB color = Gdip.Black,
                                               bool clamp = false )
    {
        return SetStatus(GdipSetImageAttributesWrapMode(
                           attrib, wrap, color, clamp));
    }


    /**************************************************************************

    **************************************************************************/

    static Status ImageAttributes_SetColorMatrix( ImageAttributes attrib,
                                                  ref ColorMatrix matrix,
                                               ColorMatrixFlag mode = Gdip.ColorMatrixFlagsDefault,
                                               ColorAdjustType type = Gdip.ColorAdjustTypeDefault  )
    {
        return SetStatus( GdipSetImageAttributesColorMatrix(
                                            attrib,
                                            type,
                                            true,
                                            &matrix,
                                            null,
                                            mode));
    }


/**************************************************************************

    Gdi+ Brush Wrap Interface

**************************************************************************/

    static Brush Brush_Clone( Brush brush )
    {
        Brush cloneBrush;
        SetStatus( GdipCloneBrush( brush, cloneBrush ) );
        return cloneBrush;
    }

    /**************************************************************************

    **************************************************************************/

    static BrushType Brush_GetType( Brush brush )
    {
        BrushType brushType = -1;
        SetStatus( GdipGetBrushType( brush, brushType ) );
        return brushType;
    }

/**************************************************************************

    Gdi+ HatchedBrush Wrap Interface

**************************************************************************/

    static void HatchBrush_delete( HatchBrush brush )
    {
        GdipDeleteBrush(brush);
    }

    /**************************************************************************

    **************************************************************************/

    static HatchBrush HatchBrush_new( HatchStyle hatchStyle,
                                      ARGB foreColor, ARGB backColor )
    {
        HatchBrush brush = null;

        Gdip.lastResult = GdipCreateHatchBrush( hatchStyle,
                                                foreColor,
                                                backColor,
                                                brush );
        return brush;
    }

/**************************************************************************

    Gdi+ LinearGradientBrush Wrap Interface

**************************************************************************/

    static LinearGradientBrush LinearGradientBrush_new( ref PointF point1, ref PointF point2,
                                                        ARGB color1, ARGB color2 )
    {
        LinearGradientBrush brush = null;

        lastResult = GdipCreateLineBrush(point1, point2,
                                         color1, color2,
                                         WrapModeTile, brush);
        return brush;

    }

    /**************************************************************************

    **************************************************************************/

    static void LinearGradientBrush_delete( LinearGradientBrush brush )
    {
        GdipDeleteBrush(brush);
    }

    /**************************************************************************

    **************************************************************************/

    static Status LinearGradientBrush_SetInterpolationColors( LinearGradientBrush brush,
                              ARGB* presetColors, float* blendPositions, int count )
    {
        if ((count <= 0) || presetColors is null)
            return SetStatus(Status.InvalidParameter);

        return SetStatus(GdipSetLinePresetBlend(brush, presetColors,
                                                       blendPositions,
                                                       count ) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status LinearGradientBrush_SetWrapMode( LinearGradientBrush brush, WrapMode wrapMode )
    {
        return SetStatus(GdipSetLineWrapMode( brush, wrapMode));
    }

    /**************************************************************************

    **************************************************************************/

    static Status LinearGradientBrush_ResetTransform(LinearGradientBrush brush )
    {
        return SetStatus(GdipResetLineTransform(brush));
    }

    /**************************************************************************

    **************************************************************************/

    static int LinearGradientBrush_ScaleTransform( LinearGradientBrush brush,
                                                   float sx, float sy,
                                                   MatrixOrder order = MatrixOrderPrepend )
    {
        return SetStatus(GdipScaleLineTransform(brush, sx, sy, order));
    }

    /**************************************************************************

    **************************************************************************/

    static int LinearGradientBrush_TranslateTransform( LinearGradientBrush brush,
                                                       float dx, float dy,
                                                       MatrixOrder order = MatrixOrderPrepend )
    {
        return SetStatus(GdipTranslateLineTransform(brush, dx, dy, order));
    }


/**************************************************************************

    GDI+ TextureBrush Wrap Interface

**************************************************************************/

    static TextureBrush TextureBrush_new( Image image, WrapMode wrapMode,
                                          float dstX, float dstY,
                                          float dstWidth, float dstHeight )
    {
        TextureBrush brush = null;

        Gdip.lastResult = GdipCreateTexture2( image,
                                              wrapMode,
                                              dstX, dstY,
                                              dstWidth, dstHeight,
                                              brush  );
        return brush;

    }

    /**************************************************************************

    **************************************************************************/

    static void TextureBrush_delete( TextureBrush brush )
    {
        GdipDeleteBrush( brush );
    }

    /**************************************************************************

    **************************************************************************/

    static Status TextureBrush_SetTransform( TextureBrush brush, Matrix matrix )
    {
        return SetStatus(GdipSetTextureTransform(brush, matrix));
    }

    /**************************************************************************

    **************************************************************************/

    static Status TextureBrush_ResetTransform( TextureBrush brush )
    {
                return SetStatus(GdipResetTextureTransform(brush));
    }

    /**************************************************************************

    **************************************************************************/

    static Status TextureBrush_ScaleTransform( TextureBrush brush,
                                               float sx, float sy,
                                               MatrixOrder order = MatrixOrderPrepend )
    {
        return SetStatus(GdipScaleTextureTransform(brush, sx, sy, order));
    }

    /**************************************************************************

    **************************************************************************/

    static Status TextureBrush_TranslateTransform( TextureBrush brush,
                                                   float dx, float dy,
                                                   MatrixOrder order = MatrixOrderPrepend )
    {
        return SetStatus(GdipTranslateTextureTransform(brush, dx, dy, order));
    }


/**************************************************************************

    GDI+ Pen Wrap Interface

**************************************************************************/

    static SolidBrush SolidBrush_new( ARGB color )
    {
        SolidBrush brush = null;

        Gdip.lastResult = GdipCreateSolidFill( color, brush );

        return brush;
    }

    /**************************************************************************

    **************************************************************************/

    static void SolidBrush_delete( SolidBrush brush )
    {
        GdipDeleteBrush(brush);
    }

/**************************************************************************

    GDI+ Pen Wrap Interface

**************************************************************************/

    static Pen Pen_new( Brush brush, float width )
    {
        Unit unit = UnitWorld;
        Pen pen = null;
        Gdip.lastResult = GdipCreatePen2(brush, width, unit, pen);
        return pen;
    }

    /**************************************************************************

    **************************************************************************/

    static void Pen_delete( Pen pen )
    {
        GdipDeletePen(pen);
    }

    /**************************************************************************

    **************************************************************************/

    static PenType Pen_GetPenType( Pen pen )
    {
       PenType type;
       SetStatus(GdipGetPenFillType( pen, type ));
       return type;
    }

    /**************************************************************************

    **************************************************************************/

    static Brush Pen_GetBrush( Pen pen )
    {
        Brush brush;
        SetStatus(GdipGetPenBrushFill(pen, brush));
        return brush;
    }

    /**************************************************************************

    **************************************************************************/

    static Status Pen_SetBrush( Pen pen, Brush brush )
    {
        return SetStatus(GdipSetPenBrushFill(pen, brush));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Pen_SetDashOffset( Pen pen, float dashOffset )
    {
        return SetStatus(GdipSetPenDashOffset(pen, dashOffset));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Pen_SetDashPattern( Pen pen, in float* dashArray, int count )
    {
        return SetStatus(GdipSetPenDashArray(pen, dashArray, count));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Pen_SetDashStyle( Pen pen, DashStyle dashStyle )
    {
        return SetStatus(GdipSetPenDashStyle(pen, dashStyle));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Pen_SetLineCap( Pen pen, LineCap startCap, LineCap endCap, DashCap dashCap )
    {
        return SetStatus(GdipSetPenLineCap197819(pen, startCap, endCap, dashCap));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Pen_SetLineJoin( Pen pen, LineJoin lineJoin )
    {
        return SetStatus(GdipSetPenLineJoin(pen, lineJoin));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Pen_SetMiterLimit( Pen pen, float miterLimit )
    {
        return SetStatus(GdipSetPenMiterLimit(pen, miterLimit));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Pen_SetWidth( Pen pen, float width )
    {
        return SetStatus(GdipSetPenWidth(pen, width));
    }


/**************************************************************************

    GDI+ Color Wrap Interface

**************************************************************************/

    // The following two color functions appear to serve little use
    // and should probably be replaced with an actual ARGB type assignment
    // wherever they are used.

    // I'm guessing they are being used in case of future adoption of the
    // gdi+ Color class functionality in Swt.

    static void Color_delete( ARGB color )
    {
        // no op
    }

    /**************************************************************************

    **************************************************************************/

    static ARGB Color_new( ARGB color )
    {
        return color;
    }

/**************************************************************************

    GDI+ FontFamily Wrap Interface

**************************************************************************/

    static int FontFamily_GetFamilyName( FontFamily family, LPCWSTR name, int language )
    {
        return SetStatus( GdipGetFamilyName( family, name, language ) );
    }

    /**************************************************************************

    **************************************************************************/

    // CAUTION:  Next two methods need to be tested - JJR

    static void FontFamily_delete( FontFamily family )
    {
        if (family !is null)
            GdipDeleteFontFamily( family );
    }

    /**************************************************************************

        FontFamily_new() returns a null because flat Gdi+ FontFamily is
        internally assigned a null until it is associated with a font
        (see gdi+ C++ wrapper for details).

    **************************************************************************/

    static FontFamily FontFamily_new()
    {
        return null;
    }

/**************************************************************************

    GDI+ Font Wrap Interface

**************************************************************************/


    static int Font_GetFamily( Font font, ref FontFamily family )
    {
        return SetStatus( GdipGetFamily( font, family ) );
    }

    /**************************************************************************

    **************************************************************************/

    static float Font_GetSize( Font font )
    {
        float  size = 0;
        SetStatus( GdipGetFontSize( font, size ) );
        return size;
    }

    /**************************************************************************

    **************************************************************************/

    static int Font_GetStyle( Font font )
    {
        int style;
        SetStatus( GdipGetFontStyle( font, style ) );
        return style;
    }

    /**************************************************************************

    **************************************************************************/

    static bool Font_IsAvailable( Font font )
    {
        return (font !is null);
    }

    /**************************************************************************

    **************************************************************************/

    static void Font_delete( Font font )
    {
        GdipDeleteFont( font );
    }

    /**************************************************************************

    **************************************************************************/

    static Font Font_new( HDC hdc, HFONT hfont )
    {
        Font font = null;

        if (hfont is null) {
            Gdip.lastResult = GdipCreateFontFromDC( hdc, font );
        } else {
            LOGFONTW logfont;
            if (OS.GetObject( hfont, LOGFONTW.sizeof, &logfont ))
                Gdip.lastResult = GdipCreateFontFromLogfontW(hdc, logfont, font);
            else
                Gdip.lastResult = GdipCreateFontFromDC(hdc, font);
        }

        return font;
    }


    /**************************************************************************

    **************************************************************************/

    static Font Font_new( LPCWSTR familyName, float emSize, int style, uint unit,
                          FontCollection fontCollection  )
    {
        Font        nativeFont = null;
        FontFamily  nativeFamily = null;

        Gdip.lastResult = GdipCreateFontFamilyFromName( familyName, fontCollection, nativeFamily );

        if (Gdip.lastResult != Status.OK)
        {
            if (GenericSansSerifFontFamily != null)
            {
                nativeFamily = GenericSansSerifFontFamily;
            }
            //TODO: access buffer via "ptr" property?
            GenericSansSerifFontFamily = cast(FontFamily) GenericSansSerifFontFamilyBuffer;
            Gdip.lastResult = GdipGetGenericFontFamilySansSerif( GenericSansSerifFontFamily );

            nativeFamily = GenericSansSerifFontFamily;

            if (Gdip.lastResult != Status.OK)
                return null;
        }

        Gdip.lastResult = GdipCreateFont( nativeFamily, emSize, style, unit, nativeFont );

        if (Gdip.lastResult != Status.OK)
        {
            if (GenericSansSerifFontFamily != null)
            {
                nativeFamily = GenericSansSerifFontFamily;
            }

            GenericSansSerifFontFamily = cast(FontFamily) GenericSansSerifFontFamilyBuffer;
            Gdip.lastResult = GdipGetGenericFontFamilySansSerif( GenericSansSerifFontFamily );

            nativeFamily = GenericSansSerifFontFamily;

            if (Gdip.lastResult != Status.OK)
                return null;

            Gdip.lastResult = GdipCreateFont( nativeFamily, emSize, style,
                                              unit, nativeFont  );
        }

        return nativeFont;
    }

/**************************************************************************

    GDI+ Startup and Shutdown Wrap Interface

**************************************************************************/

    alias .GdiplusShutdown GdiplusShutdown;

    /**************************************************************************

    **************************************************************************/

    alias .GdiplusStartup GdiplusStartup;


/**************************************************************************

    GDI+ Graphics Path Wrap Interface

**************************************************************************/

    static Path GraphicsPath_new( FillMode fillMode = FillModeAlternate )
    {
        Path path = null;
        lastResult = GdipCreatePath(fillMode, path);
        return path;
    }

    /**************************************************************************

    **************************************************************************/

    static Path GraphicsPath_new( Point* points, ubyte* types, int count,
                                  FillMode fillMode = FillModeAlternate )
    {
        Path path = null;
        lastResult = GdipCreatePath2I(points, types, count, fillMode, path);
        return path;
    }

    /**************************************************************************

    **************************************************************************/

    static void GraphicsPath_delete( Path path )
    {
        GdipDeletePath(path);
    }
    static Path GraphicsPath_Clone( Handle path ){
        Path clonepath = null;
        SetStatus( GdipClonePath(path, clonepath));
        return clonepath;
    }


    static Status GraphicsPath_AddArcF( Path path, float x,     float y,
                                           float width, float height,
                                           float startAngle, float sweepAngle )
    {
        return SetStatus( GdipAddPathArc( path, x, y, width,
                                          height, startAngle, sweepAngle) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_AddArc( Path path, int x, int y,
                                                  int width, int height,
                                                  float startAngle, float sweepAngle )
    {
        return SetStatus(GdipAddPathArcI(   path,
                                            x,
                                            y,
                                            width,
                                            height,
                                            startAngle,
                                            sweepAngle));
    }

    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_AddBezier( Path path, float x1, float y1,
                                                     float x2, float y2,
                                                     float x3, float y3,
                                                     float x4, float y4 )
    {
        return SetStatus( GdipAddPathBezier( path, x1, y1, x2, y2,
                                                   x3, y3, x4, y4 ) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_AddLine( Path path, float x1, float y1,
                                                   float x2, float y2 )
    {
        return SetStatus( GdipAddPathLine( path, x1, y1, x2, y2 ) );
    }


    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_AddPath( Path path, Path addingPath, bool connect )
    {
        return SetStatus( GdipAddPathPath( path, addingPath, connect ) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_AddRectangle( Path path, RectF rect )
    {
        return SetStatus( GdipAddPathRectangle( path,
                                                rect.X,
                                                rect.Y,
                                                rect.Width,
                                                rect.Height ) );
    }


    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_AddString( Path path, LPCWSTR string,
                                          int length, FontFamily family,
                                          int style, float emSize,
                                          ref PointF origin, StringFormat format )
    {
        RectF rect = { origin.X, origin.Y, 0.0f, 0.0f };

        return SetStatus( GdipAddPathString( path, string, length, family,
                                             style, emSize, rect, format ) );
    }


    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_CloseFigure( Path path )
    {
        return SetStatus( GdipClosePathFigure(path) );
    }


    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_Flatten( Path path, Matrix matrix, float flatness )
    {
        return SetStatus( GdipFlattenPath( path, matrix, flatness ) );
    }


    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_GetBounds( Path path, ref RectF bounds,
                                          Matrix matrix, Pen pen )
    {

        return SetStatus( GdipGetPathWorldBounds( path, bounds,
                                                  matrix, pen ) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_GetLastPoint( Path path, out PointF lastPoint )
    {
        return SetStatus( GdipGetPathLastPoint( path, lastPoint) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_GetPathTypes( Path path, byte* types, int count )
    {
        return SetStatus( GdipGetPathTypes( path, types, count) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status GraphicsPath_GetPathPoints( Path path, PointF* points, int count)
    {
        return SetStatus(GdipGetPathPoints(path, points, count));
    }


    /**************************************************************************

    **************************************************************************/

    static int GraphicsPath_GetPointCount( Path path )
    {
        int count = 0;

        SetStatus(GdipGetPointCount(path, count));

        return count;
    }

    /**************************************************************************

    **************************************************************************/

    static bool GraphicsPath_IsOutlineVisible( Path path,
                                float x, float y, Pen pen, Graphics g = null )
    {
        int booln = false;
        SetStatus( GdipIsOutlineVisiblePathPoint( path, x, y,
                                                  pen, g,
                                                  booln )  );
        return (booln == true);
    }

    /**************************************************************************

    **************************************************************************/

    static bool GraphicsPath_IsVisible( Path path, float x, float y, Graphics graphics )
    {
        int booln = false;

        SetStatus(GdipIsVisiblePathPoint(path, x, y, graphics, booln));

        return (booln == true);
    }

    /**************************************************************************

    **************************************************************************/

    static int GraphicsPath_SetFillMode( Path path, FillMode fillmode )
    {
        return SetStatus( GdipSetPathFillMode(path, fillmode) );
    }

    /**************************************************************************

    **************************************************************************/

    static int GraphicsPath_StartFigure( Path path )
    {
        return SetStatus(GdipStartPathFigure(path));
    }

    /**************************************************************************

    **************************************************************************/

    static int GraphicsPath_Transform( Path path, Matrix matrix )
    {
        if(matrix)
            return SetStatus( GdipTransformPath(path, matrix));
        else
            return Status.OK;

    }


/**************************************************************************

    GDI+ Graphics Wrap Interface

**************************************************************************/

    static Graphics Graphics_new( HDC hdc )
    {

        Graphics graphics = null;

        Gdip.lastResult = GdipCreateFromHDC(hdc, graphics);

        return graphics;
    }

    /**************************************************************************

    **************************************************************************/

    static void Graphics_delete( Graphics graphics)
    {
        GdipDeleteGraphics(graphics);
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawArc( Graphics graphics, Pen pen,
                                    int x, int y, int width, int height,
                                    float startAngle, float sweepAngle )
    {
        return SetStatus(GdipDrawArcI(graphics, pen,
                                      x, y, width, height,
                                      startAngle, sweepAngle));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawEllipse(Graphics graphics, Pen pen,
                                       int x, int y,
                                       int width, int height)
    {
        return SetStatus(GdipDrawEllipseI(graphics, pen,
                                          x, y, width, height));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawImage(Graphics graphics, Image image, int x, int y)
    {
        return SetStatus(GdipDrawImageI(graphics,image, x, y));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawImage( Graphics graphics, Image image, ref Rect destRect,
                                        int srcx, int srcy, int srcwidth, int srcheight,
                                        Unit srcUnit, ImageAttributes imageAttributes = null,
                                        DrawImageAbort callback = null, void* callbackData = null )
    {
        return SetStatus(GdipDrawImageRectRectI(graphics, image,
                                                destRect.X, destRect.Y,
                                                destRect.Width, destRect.Height,
                                                srcx, srcy,
                                                srcwidth, srcheight,
                                                srcUnit, imageAttributes,
                                                callback, callbackData));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawLine( Graphics graphics, Pen pen,
                                     int x1, int y1, int x2, int y2 )
    {
        return SetStatus(GdipDrawLineI(graphics, pen, x1, y1, x2, y2));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawLines( Graphics graphics, Pen pen, Point* points, uint count )
    {
        return SetStatus(GdipDrawLinesI(graphics, pen, points, count));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawPath( Graphics graphics, Pen pen, Path path )
    {
        return SetStatus(GdipDrawPath(graphics, pen, path));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawPolygon(Graphics graphics, Pen pen, Point* points, uint count )
    {
        return SetStatus(GdipDrawPolygonI(graphics, pen, points, count));

    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawRectangle( Graphics graphics, Pen pen, int x, int y,
                                                             int width, int height )
    {
        return SetStatus(GdipDrawRectangleI(graphics, pen, x, y, width, height));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawString( Graphics graphics, LPCWSTR string, int length,
                                       Font font, ref PointF origin, Brush brush  )
    {
        RectF rect = {origin.X, origin.Y, 0.0f, 0.0f};

        return SetStatus(GdipDrawString(graphics,string,length, font, rect, null, brush));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_DrawString( Graphics graphics, LPCWSTR string, int length,
                                       Font font, ref PointF origin,
                                       StringFormat format, Brush brush )
    {
        RectF rect = { origin.X, origin.Y, 0.0f, 0.0f };

        return SetStatus(GdipDrawString(graphics, string, length, font, rect, format, brush));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_FillEllipse( Graphics graphics, Brush brush,
                                        int x, int y,
                                        int width, int height )
    {
        return SetStatus(GdipFillEllipseI(graphics, brush, x,y, width, height));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_FillPath( Graphics graphics, Brush brush, Path path )
    {
        return SetStatus(GdipFillPath(graphics,brush,path));
    }

    /**************************************************************************

    **************************************************************************/

    static void Graphics_Flush( Graphics graphics, FlushIntention intention = FlushIntentionFlush )
    {
        GdipFlush(graphics, intention);
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_FillPie( Graphics graphics, Brush brush,
                                    int x, int y,
                                    int width, int height,
                                    float startAngle, float sweepAngle )
    {
        return SetStatus(GdipFillPieI(graphics, brush,
                                      x, y, width, height,
                                      startAngle, sweepAngle));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_FillPolygon( Graphics graphics, Brush brush,
                                        Point* points, int count, FillMode fillMode )
    {
        return SetStatus(GdipFillPolygonI(graphics, brush, points, count, fillMode));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_FillRectangle( Graphics graphics, Brush brush,
                                          int x, int y,
                                          int width, int height )
    {
        return SetStatus(GdipFillRectangleI(graphics, brush,
                                            x, y,
                                            width, height));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_GetClipBounds( Graphics graphics, out RectF rect )
    {
        return SetStatus(GdipGetClipBounds(graphics, rect));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_GetClipBounds( Graphics graphics, out Rect rect )
    {
        return SetStatus(GdipGetClipBoundsI(graphics, rect));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_GetClip( Graphics graphics, Region region )
    {
        return SetStatus(GdipGetClip(graphics, region));
    }

    /**************************************************************************

    **************************************************************************/

    static HDC Graphics_GetHDC(Graphics graphics)
    {
        HDC hdc = null;

        SetStatus(GdipGetDC(graphics, hdc));

        return hdc;
    }

    /**************************************************************************

    **************************************************************************/

    static void Graphics_ReleaseHDC(Graphics graphics, HDC hdc)
    {
        SetStatus(GdipReleaseDC(graphics, hdc));
    }

    /**************************************************************************

    **************************************************************************/

    static InterpolationMode Graphics_GetInterpolationMode( Graphics graphics )
    {
        InterpolationMode mode = InterpolationModeInvalid;

        SetStatus(GdipGetInterpolationMode(graphics, mode));

        return mode;
    }

    /**************************************************************************

    **************************************************************************/

    static SmoothingMode Graphics_GetSmoothingMode( Graphics graphics )
    {
        SmoothingMode smoothingMode = SmoothingModeInvalid;

        SetStatus(GdipGetSmoothingMode(graphics, smoothingMode));

        return smoothingMode;
    }

    /**************************************************************************

    **************************************************************************/

    static TextRenderingHint Graphics_GetTextRenderingHint( Graphics graphics )
    {
        TextRenderingHint hint;

        SetStatus(GdipGetTextRenderingHint(graphics, hint));

        return hint;
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_GetTransform( Graphics graphics, Matrix matrix )
    {
        return SetStatus(GdipGetWorldTransform(graphics, matrix));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_GetVisibleClipBounds( Graphics graphics, out Rect rect )
    {

        return SetStatus(GdipGetVisibleClipBoundsI(graphics, rect));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_MeasureString( Graphics graphics, LPCWSTR string, int length,
                                          Font font, ref PointF origin,
                                          ref RectF boundingBox )
    {
        RectF rect = {origin.X, origin.Y, 0.0f, 0.0f};

        return SetStatus(GdipMeasureString(
            graphics,
            string,
            length,
            font,
            rect,
            null,
            boundingBox,
            null,
            null
        ));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_MeasureString( Graphics graphics, LPCWSTR string, int length,
                                          Font font, ref PointF origin,
                                          StringFormat format, ref RectF boundingBox )
    {
        RectF rect = {origin.X, origin.Y, 0.0f, 0.0f};

        return SetStatus(GdipMeasureString(
            graphics,
            string,
            length,
            font,
            rect,
            format,
            boundingBox,
            null,
            null
        ));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_ResetClip( Graphics graphics )
    {
        return SetStatus(GdipResetClip(graphics));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_Restore( Graphics graphics, GraphicsState gstate )
    {
        return SetStatus(GdipRestoreGraphics(graphics, gstate));
    }

    /**************************************************************************

    **************************************************************************/

    static GraphicsState Graphics_Save( Graphics graphics )
    {
        GraphicsState gstate;

        SetStatus(GdipSaveGraphics(graphics, gstate));

        return gstate;
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_ScaleTransform( Graphics graphics, float sx, float sy,
                                           MatrixOrder order = MatrixOrderPrepend )
    {
        return SetStatus(GdipScaleWorldTransform(graphics, sx, sy, order));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_SetClip( Graphics graphics, HRGN hrgn,
                                    CombineMode combineMode = CombineModeReplace )
    {
        return SetStatus(GdipSetClipHrgn(graphics, hrgn, combineMode));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_SetClipPath( Graphics graphics, Path path,
                                    CombineMode combineMode = CombineModeReplace )
    {
        return SetStatus(GdipSetClipPath(graphics, path, combineMode));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_SetClip( Graphics graphics, ref Rect rect,
                                    CombineMode combineMode = CombineModeReplace )
    {
       return SetStatus( GdipSetClipRectI( graphics,
                                                      rect.X, rect.Y,
                                                      rect.Width, rect.Height,
                                                      combineMode));
    }

    //static Status Graphics_SetClipPath(Graphics graphics, GraphicsPath path ){
    //    return SetStatus( SetClipPath( graphics, path ));
    //}
    /**************************************************************************

    **************************************************************************/

    static Status Graphics_SetCompositingQuality( Graphics graphics,
                                                  CompositingQuality compositingQuality )
    {
        return SetStatus(GdipSetCompositingQuality(graphics, compositingQuality));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_SetPageUnit( Graphics graphics, Unit unit )
    {
        return SetStatus(GdipSetPageUnit(graphics, unit));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_SetPixelOffsetMode( Graphics graphics,
                                               PixelOffsetMode pixelOffsetMode )
    {
        return SetStatus(GdipSetPixelOffsetMode(graphics, pixelOffsetMode));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_SetSmoothingMode( Graphics graphics,
                                             SmoothingMode smoothingMode )
    {
        return SetStatus(GdipSetSmoothingMode(graphics, smoothingMode));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_SetTransform( Graphics graphics, Matrix matrix )
    {
        return SetStatus(GdipSetWorldTransform(graphics, matrix));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_SetInterpolationMode( Graphics graphics,
                                                 InterpolationMode mode )
    {
        return SetStatus(GdipSetInterpolationMode(graphics, mode));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_SetTextRenderingHint( Graphics graphics, TextRenderingHint mode )
    {
        return SetStatus(GdipSetTextRenderingHint(graphics, mode));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Graphics_TranslateTransform( Graphics graphics, float dx, float dy,
                                               MatrixOrder order = MatrixOrderPrepend )
    {
                return SetStatus(GdipTranslateWorldTransform(graphics, dx, dy, order));
    }

/**************************************************************************

    Gdi+ Region Wrap Interface

**************************************************************************/

    static Region Region_new( HRGN hRgn )
    {
        Region region = null;

        Gdip.lastResult = GdipCreateRegionHrgn( hRgn, region);

        return region;
    }

    /**************************************************************************

    **************************************************************************/

    static Region Region_new()
    {
        Region region = null;

        Gdip.lastResult = GdipCreateRegion(region);

        return region;
    }

    /**************************************************************************

    **************************************************************************/

    static void Region_delete( Region region )
    {
        GdipDeleteRegion(region);
    }

    /**************************************************************************

    **************************************************************************/

    static HRGN Region_GetHRGN( Region region, Graphics graphics )
    {
        HRGN hrgn;

        SetStatus(GdipGetRegionHRgn(region, graphics, hrgn));

        return hrgn;
    }

    /**************************************************************************

    **************************************************************************/

    static int Region_IsInfinite( Region region, Graphics graphics )
    {
        int booln = false;

        SetStatus(GdipIsInfiniteRegion(region, graphics, booln));

        return booln;
    }

/**************************************************************************

    Gdi+ Matrix Wrap Interface

**************************************************************************/

    static Matrix Matrix_new(float m11, float m12, float m21, float m22, float dx, float dy)
    {
        Matrix matrix = null;

        Gdip.lastResult = GdipCreateMatrix2(m11, m12, m21, m22, dx, dy, matrix);

        return matrix;
    }

    /**************************************************************************

    **************************************************************************/

    static void Matrix_delete( Matrix matrix )
    {
        GdipDeleteMatrix( matrix );
    }

    /**************************************************************************

    **************************************************************************/

    static Status Matrix_GetElements( Matrix matrix, float* m )
    {
        return SetStatus( GdipGetMatrixElements( matrix, m ) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status Matrix_Invert( Matrix matrix )
    {
        return SetStatus( GdipInvertMatrix( matrix ) );
    }

    /**************************************************************************

    **************************************************************************/

    static int Matrix_IsIdentity( Matrix matrix )
    {
        int result = false;

        SetStatus(GdipIsMatrixIdentity( matrix, result ) );

        return result;
    }

    /**************************************************************************

    **************************************************************************/

    static Status Matrix_Multiply( Matrix nativeMatrix, Matrix matrix,
                                   MatrixOrder order = MatrixOrderPrepend )
    {
        return SetStatus( GdipMultiplyMatrix( nativeMatrix, matrix, order) );
    }

    /**************************************************************************

    **************************************************************************/

    static int  Matrix_Rotate( Matrix matrix, float angle, MatrixOrder order = MatrixOrderPrepend )
    {
        return SetStatus( GdipRotateMatrix( matrix, angle, order ) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status Matrix_Scale( Matrix matrix, float scaleX , float scaleY,
                                MatrixOrder order = MatrixOrderPrepend )
    {
        return SetStatus( GdipScaleMatrix(matrix, scaleX, scaleY, order) );
    }
    static Status Matrix_Shear( Matrix matrix, float shearX, float shearY, MatrixOrder order ){
        return SetStatus( GdipShearMatrix(matrix, shearX, shearY, order));
    }

    /**************************************************************************

    **************************************************************************/

    static Status Matrix_SetElements( Matrix matrix, float m11, float m12,
                                                     float m21, float m22,
                                                     float dx, float dy     )
    {
        return SetStatus( GdipSetMatrixElements( matrix, m11, m12, m21, m22, dx, dy ) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status Matrix_TransformPoints( Matrix matrix, PointF* pts, int count = 1 )
    {
        return SetStatus( GdipTransformMatrixPoints( matrix, pts, count ) );
    }

    /**************************************************************************

    **************************************************************************/

    static Status Matrix_Translate( Matrix matrix, float offsetX, float offsetY,
                                    MatrixOrder order = MatrixOrderPrepend      )
    {
        return SetStatus( GdipTranslateMatrix( matrix, offsetX, offsetY, order ) );
    }


/**************************************************************************

    Gdi+ StringFromat Wrap Interface

**************************************************************************/

    static void StringFormat_delete( StringFormat format )
    {
        GdipDeleteStringFormat( format );
    }

    /**************************************************************************

    **************************************************************************/

    static StringFormat StringFormat_Clone( StringFormat format )
    {
        StringFormat clonedStringFormat = null;

        Gdip.lastResult = GdipCloneStringFormat( format, clonedStringFormat );

        if (Gdip.lastResult == Status.OK)
            return clonedStringFormat;
        else
            return null;
    }

    /**************************************************************************

    **************************************************************************/

    static StringFormat StringFormat_GenericDefault()
    {
        // TODO:  do we need to access buffer through "ptr" property?
        StringFormat genericDefaultStringFormat =
            cast(StringFormat) GenericDefaultStringFormatBuffer;

        Gdip.lastResult = GdipStringFormatGetGenericDefault( genericDefaultStringFormat );

        return genericDefaultStringFormat;
    }

    /**************************************************************************

    **************************************************************************/

    static StringFormat StringFormat_GenericTypographic()
    {
        // TODO:  do we need to access buffer through "ptr" property?
        StringFormat genericTypographicStringFormat =
            cast(StringFormat) GenericTypographicStringFormatBuffer;

        Gdip.lastResult = GdipStringFormatGetGenericTypographic(
            genericTypographicStringFormat );

        return genericTypographicStringFormat;
    }

    /**************************************************************************

    **************************************************************************/

    // TODO: StringFormat class in Gdi+ maintains it's own lastError status
    // Right now all lastError and lastResult status for org.eclipse.swt's gdip objects
    // are combined in one Gdip SetStatus method and lastResult member.
    // Consider if there is a need to maintain per object lastResult
    // monitoring.  For now, this /should/ work as is.

    static int StringFormat_GetFormatFlags(StringFormat format)
    {
        int flags;
        SetStatus( GdipGetStringFormatFlags(format, flags));
        return flags;
    }

    /**************************************************************************

    **************************************************************************/

    static int StringFormat_SetHotkeyPrefix( StringFormat format, int hotkeyPrefix )
    {
       return SetStatus(GdipSetStringFormatHotkeyPrefix(format, hotkeyPrefix));
    }

    /**************************************************************************

    **************************************************************************/

    static int StringFormat_SetFormatFlags( StringFormat format, int flags )
    {
       return SetStatus(GdipSetStringFormatFlags(format, flags));
    }

    /**************************************************************************

    **************************************************************************/

    static int StringFormat_SetTabStops( StringFormat format, float firstTabOffset,
                                         int count, float* tabStops)
    {
        return SetStatus( GdipSetStringFormatTabStops( format, firstTabOffset,
                                                       count, tabStops ) );
    }

    /**************************************************************************

    **************************************************************************/
}
